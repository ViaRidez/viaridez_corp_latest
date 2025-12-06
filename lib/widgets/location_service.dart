import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;

/// Exception thrown when location operations fail
class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}

/// Enum representing different location permission states
enum LocationPermissionStatus {
  /// Permission granted
  granted,

  /// Permission denied
  denied,

  /// Permission not requested yet (will prompt user)
  prompt,

  /// Geolocation not supported
  unsupported,

  /// Unknown permission state
  unknown,
}

/// A position object that represents latitude and longitude
class LocationPosition {
  final double latitude;
  final double longitude;
  final double? accuracy;

  LocationPosition({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  @override
  String toString() {
    return 'LocationPosition(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}

/// Service for handling geolocation in Flutter Web
///
/// Example usage:
/// ```dart
/// try {
///   // Check if location is supported
///   if (LocationService.isLocationSupported()) {
///     // Request permission
///     final hasPermission = await LocationService.requestPermission();
///     if (hasPermission) {
///       // Get current position
///       final position = await LocationService.getCurrentPosition();
///       print('Lat: ${position.latitude}, Lng: ${position.longitude}');
///     }
///   }
/// } catch (e) {
///   print('Location error: $e');
/// }
/// ```
class LocationService {
  /// Get current position using web geolocation API
  static Future<LocationPosition> getCurrentPosition() async {
    try {
      // Check if geolocation is supported
      if (!isLocationSupported()) {
        throw const LocationException(
            'Geolocation is not supported by this browser');
      }

      // Get current position using web geolocation API
      final position =
          await html.window.navigator.geolocation.getCurrentPosition();
      final coords = position.coords!;

      return LocationPosition(
        latitude: coords.latitude!.toDouble(),
        longitude: coords.longitude!.toDouble(),
        accuracy: coords.accuracy?.toDouble(),
      );
    } catch (e) {
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException('Failed to get current position: $e');
    }
  }

  /// Check if geolocation is supported by the browser
  static bool isLocationSupported() {
    try {
      // In modern browsers, geolocation is always available on the navigator object
      // The actual permission check happens when calling getCurrentPosition
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Request location permission using the Permissions API
  static Future<bool> requestPermission() async {
    try {
      if (!isLocationSupported()) {
        return false;
      }

      // Check current permission status
      final permissionStatus = await checkPermissionStatus();

      if (permissionStatus == LocationPermissionStatus.granted) {
        return true;
      }

      if (permissionStatus == LocationPermissionStatus.denied) {
        return false;
      }

      // If permission is prompt, try to get location which will trigger permission request
      try {
        await getCurrentPosition();
        return true;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Check the current permission status
  static Future<LocationPermissionStatus> checkPermissionStatus() async {
    try {
      if (!isLocationSupported()) {
        return LocationPermissionStatus.unsupported;
      }

      // Use the Permissions API if available
      try {
        final permission = await html.window.navigator.permissions
            ?.query({'name': 'geolocation'});
        if (permission != null) {
          switch (permission.state) {
            case 'granted':
              return LocationPermissionStatus.granted;
            case 'denied':
              return LocationPermissionStatus.denied;
            case 'prompt':
              return LocationPermissionStatus.prompt;
            default:
              return LocationPermissionStatus.unknown;
          }
        }
      } catch (e) {
        // Permissions API might not be available
      }

      // Fallback: assume prompt if Permissions API is not available
      return LocationPermissionStatus.prompt;
    } catch (e) {
      return LocationPermissionStatus.unknown;
    }
  }

  /// Watch position changes (simplified for web)
  static Stream<LocationPosition> watchPosition({
    bool enableHighAccuracy = true,
    int timeout = 15000,
    int maximumAge = 60000,
  }) {
    if (!isLocationSupported()) {
      throw const LocationException(
          'Geolocation is not supported by this browser');
    }

    late StreamController<LocationPosition> controller;

    controller = StreamController<LocationPosition>(
      onListen: () {
        // Use a simple polling approach since dart:html watchPosition is complex
        Timer.periodic(const Duration(seconds: 10), (timer) async {
          try {
            final position = await getCurrentPosition();
            if (!controller.isClosed) {
              controller.add(position);
            }
          } catch (e) {
            if (!controller.isClosed) {
              controller.addError(e);
            }
          }

          if (controller.isClosed) {
            timer.cancel();
          }
        });
      },
      onCancel: () {
        // Timer will be cancelled in the periodic callback
      },
    );

    return controller.stream;
  }

  /// Get location from coordinates using OpenStreetMap Nominatim reverse geocoding
  static Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      // OpenStreetMap Nominatim reverse geocoding API
      final url = 'https://nominatim.openstreetmap.org/reverse'
          '?format=json'
          '&lat=$latitude'
          '&lon=$longitude'
          '&zoom=18'
          '&addressdetails=1';

      // Make HTTP request using dart:html
      final request = html.HttpRequest();
      final completer = Completer<String>();

      request.open('GET', url);
      request.setRequestHeader('User-Agent', 'ViaRidez Flutter Web App');

      request.onLoad.listen((event) {
        if (request.status == 200) {
          try {
            final response = jsonDecode(request.responseText!);

            // Extract address components
            final address = response['address'] as Map<String, dynamic>?;
            final displayName = response['display_name'] as String?;

            if (address != null) {
              // Build a readable address from components
              final List<String> addressParts = [];

              // Add house number and road
              if (address['house_number'] != null) {
                addressParts.add(address['house_number']);
              }
              if (address['road'] != null) {
                addressParts.add(address['road']);
              }

              // Add neighborhood or suburb
              if (address['neighbourhood'] != null) {
                addressParts.add(address['neighbourhood']);
              } else if (address['suburb'] != null) {
                addressParts.add(address['suburb']);
              }

              // Add city
              if (address['city'] != null) {
                addressParts.add(address['city']);
              } else if (address['town'] != null) {
                addressParts.add(address['town']);
              } else if (address['village'] != null) {
                addressParts.add(address['village']);
              }

              // Add state/region
              if (address['state'] != null) {
                addressParts.add(address['state']);
              }

              // Add country
              if (address['country'] != null) {
                addressParts.add(address['country']);
              }

              if (addressParts.isNotEmpty) {
                completer.complete(addressParts.join(', '));
                return;
              }
            }

            // Fallback to display name if address components are not available
            if (displayName != null && displayName.isNotEmpty) {
              completer.complete(displayName);
              return;
            }

            // Final fallback to coordinates
            completer.complete(
                'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}');
          } catch (e) {
            completer.complete(
                'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}');
          }
        } else {
          completer.complete(
              'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}');
        }
      });

      request.onError.listen((event) {
        completer.complete(
            'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}');
      });

      request.onTimeout.listen((event) {
        completer.complete(
            'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}');
      });

      // Set a timeout of 10 seconds
      request.timeout = 10000;
      request.send();

      return await completer.future;
    } catch (e) {
      // Return coordinates as fallback if anything goes wrong
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Calculate distance between two points (using Haversine formula)
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(endLatitude - startLatitude);
    final double dLng = _degreesToRadians(endLongitude - startLongitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLatitude)) *
            math.cos(_degreesToRadians(endLatitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
