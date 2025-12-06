class LocationUtils {
  static String shortenLocation(String location) {
    if (location.length < 40) {
      return location;
    }

    final parts = location.split(',');
    if (parts.length <= 3) {
      return parts.take(2).join(',');
    }

    String shortenedLocation = '';
    if (parts.isNotEmpty) {
      shortenedLocation = parts[0].trim();
    }
    if (parts.length > 1) {
      shortenedLocation += ', ${parts[1].trim()}';
    }

    return shortenedLocation;
  }
}
