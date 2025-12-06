class PitStop {
  final String name;
  final String latitude;
  final String longitude;

  PitStop(
      {required this.name, required this.latitude, required this.longitude});
}

List<PitStop> parsePitStops(String input) {
  final List<PitStop> result = [];
  final stops = input.split(' | ');
  final regex = RegExp(r'^(.*?)\s*\(([^,]+),\s*([^)]+)\)$');
  for (final s in stops) {
    final match = regex.firstMatch(s.trim());
    if (match != null) {
      result.add(PitStop(
        name: match.group(1)!.trim(),
        latitude: match.group(2)!.trim(),
        longitude: match.group(3)!.trim(),
      ));
    }
  }
  return result;
}
