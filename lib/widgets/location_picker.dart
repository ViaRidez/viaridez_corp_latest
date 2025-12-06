import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../utils/styles.dart';
import 'location_service.dart';

// Location data model
class LocationData {
  final String address;
  final double latitude;
  final double longitude;

  LocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class LocationPicker extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String fontFamily;
  final bool enabled;
  final VoidCallback? onLocationSelected;
  final Function(double lat, double lng)? onCoordinatesSelected;

  const LocationPicker({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.fontFamily = 'Lexend',
    this.enabled = true,
    this.onLocationSelected,
    this.onCoordinatesSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _showLocationPicker(context) : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Styles.tertiaryColor.withAlpha(150),
              fontWeight: FontWeight.w200,
              fontFamily: fontFamily,
            ),
            floatingLabelStyle: TextStyle(
              color: Styles.primaryColor,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Styles.primaryColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Styles.primaryColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Styles.primaryColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            suffixIcon: IconButton(
              onPressed: enabled ? () => _showLocationPicker(context) : null,
              icon: Icon(
                Icons.location_on,
                color: Styles.primaryColor,
              ),
            ),
          ),
          style: TextStyle(
            fontFamily: fontFamily,
          ),
        ),
      ),
    );
  }

  Future<void> _showLocationPicker(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return LocationPickerDialog(
          currentLocation: controller.text,
          onLocationSelected: (locationData) {
            controller.text = locationData['address'] ?? '';
            if (onLocationSelected != null) {
              onLocationSelected!();
            }
            if (onCoordinatesSelected != null &&
                locationData['lat'] != null &&
                locationData['lng'] != null) {
              onCoordinatesSelected!(locationData['lat'], locationData['lng']);
            }
          },
        );
      },
    );

    if (result != null) {
      controller.text = result['address'] ?? '';
      if (onLocationSelected != null) {
        onLocationSelected!();
      }
      if (onCoordinatesSelected != null &&
          result['lat'] != null &&
          result['lng'] != null) {
        onCoordinatesSelected!(result['lat'], result['lng']);
      }
    }
  }
}

class LocationPickerDialog extends StatefulWidget {
  final String currentLocation;
  final Function(Map<String, dynamic>) onLocationSelected;

  const LocationPickerDialog({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  late TextEditingController _searchController;
  late MapController _mapController;
  LocationData _selectedLocation = LocationData(
    address: 'Loading current location...',
    latitude: 29.3759,
    longitude: 47.9774,
  );
  bool _isSearching = false;
  List<LocationData> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mapController = MapController();

    // Automatically get current location on init
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Real location search using OpenStreetMap Nominatim API
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1',
        ),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'ViaridezApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data.map<LocationData>((item) {
            return LocationData(
              address: item['display_name'] ?? '',
              latitude: double.parse(item['lat']),
              longitude: double.parse(item['lon']),
            );
          }).toList();
        });
      } else {
        _showErrorSnackBar('Failed to search location');
      }
    } catch (e) {
      _showErrorSnackBar('Error searching location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _selectSearchResult(LocationData location) {
    setState(() {
      _selectedLocation = location;
      _searchResults = [];
      _searchController.clear();
    });

    // Navigate map to selected location
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      15.0, // Zoom level
    );
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _selectedLocation = LocationData(
        address: 'Getting location details...',
        latitude: point.latitude,
        longitude: point.longitude,
      );
    });

    // Perform reverse geocoding to get address
    _reverseGeocode(point.latitude, point.longitude);
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1',
        ),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'ViaridezApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] ?? 'Unknown Location';

        setState(() {
          _selectedLocation = LocationData(
            address: address,
            latitude: lat,
            longitude: lng,
          );
        });
      } else {
        _showErrorSnackBar('Failed to get address for location');
      }
    } catch (e) {
      // Keep the coordinate-based address if reverse geocoding fails
      _showErrorSnackBar('Error getting address: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isSearching = true;
    });

    try {
      // Get current location using our location service
      final position = await LocationService.getCurrentPosition();

      // Reverse geocode to get address
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';
      final response = await http.get(Uri.parse(url));

      String address = 'Current Location';
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        address = data['display_name'] ?? 'Current Location';
      }

      final currentLocation = LocationData(
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _selectedLocation = currentLocation;
      });

      // Navigate map to current location
      _mapController.move(
        LatLng(currentLocation.latitude, currentLocation.longitude),
        15.0, // Zoom level
      );
    } catch (e) {
      // Fallback to Kuwait City if location detection fails
      final fallbackLocation = LocationData(
        address: 'Kuwait City, Kuwait (Default)',
        latitude: 29.3759,
        longitude: 47.9774,
      );

      setState(() {
        _selectedLocation = fallbackLocation;
      });

      // Navigate map to fallback location
      _mapController.move(
        LatLng(fallbackLocation.latitude, fallbackLocation.longitude),
        13.0, // Zoom level
      );

      _showErrorSnackBar(
          'Could not get current location. Using default location.');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        constraints: const BoxConstraints(
          maxWidth: 1200,
          maxHeight: 800,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Styles.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Select Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Search Bar with current location button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search location...',
                            labelText: 'Search location...',
                            labelStyle: TextStyle(
                              color: Styles.tertiaryColor.withAlpha(150),
                              fontWeight: FontWeight.w200,
                              fontFamily: 'Lexend',
                            ),
                            floatingLabelStyle: TextStyle(
                              color: Styles.primaryColor,
                            ),
                            hintStyle: TextStyle(
                              color: Styles.tertiaryColor.withAlpha(180),
                              fontWeight: FontWeight.w200,
                              fontFamily: 'Lexend',
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            prefixIcon:
                                Icon(Icons.search, color: Styles.primaryColor),
                            suffixIcon: _isSearching
                                ? Container(
                                    width: 20,
                                    height: 20,
                                    padding: const EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      color: Styles.primaryColor,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : null,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Styles.primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Styles.primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Styles.primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Lexend'),
                          onChanged: (value) {
                            // Debounce search to avoid too many API calls
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              if (_searchController.text == value) {
                                _searchLocation(value);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _getCurrentLocation,
                        icon:
                            Icon(Icons.my_location, color: Styles.primaryColor),
                        tooltip: 'Use current location',
                        style: IconButton.styleFrom(
                          backgroundColor: Styles.primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Search Results
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            leading: Icon(Icons.location_on,
                                color: Styles.primaryColor),
                            title: Text(
                              result.address,
                              style: const TextStyle(fontFamily: 'Lexend'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchResult(result),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            // Map Section
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: LatLng(_selectedLocation.latitude,
                              _selectedLocation.longitude),
                          zoom: 13.0,
                          onTap: (tapPosition, point) {
                            _onMapTap(point);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 40,
                                height: 40,
                                point: LatLng(_selectedLocation.latitude,
                                    _selectedLocation.longitude),
                                child: Icon(
                                  Icons.location_on,
                                  color: Styles.primaryColor,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Loading overlay when searching/geocoding
                    if (_isSearching)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Selected Address with better styling
            if (_selectedLocation.address.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Styles.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Styles.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Styles.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Location',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Styles.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedLocation.address,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      widget.onLocationSelected({
                        'address': _selectedLocation.address,
                        'lat': _selectedLocation.latitude,
                        'lng': _selectedLocation.longitude,
                      });
                      Navigator.of(context).pop({
                        'address': _selectedLocation.address,
                        'lat': _selectedLocation.latitude,
                        'lng': _selectedLocation.longitude,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Select Location',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
