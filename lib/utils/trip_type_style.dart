import 'package:flutter/material.dart';

/// Centralized mapping for trip type display names and colors.

class TripTypeStyle {
  static final Map<String, _TripTypeDisplay> _typeMap = {
    'outbound':
        const _TripTypeDisplay('Outbound', Colors.blue, Icons.north_east),
    'inbound':
        const _TripTypeDisplay('Inbound', Colors.orange, Icons.south_west),
    'airport transfer': const _TripTypeDisplay(
        'Airport Transfer', Colors.purple, Icons.flight_takeoff),
    'AirportTransfer': const _TripTypeDisplay(
        'Airport Transfer', Colors.purple, Icons.flight_takeoff),
    // 'airportTransfer pickup drop':
    //     _TripTypeDisplay('pickup drop', Colors.amber, Icons.local_taxi),
    'pickupdrop':
        const _TripTypeDisplay('Pickup Drop', Colors.cyan, Icons.local_taxi),
    'daily/monthly rental': const _TripTypeDisplay(
        'Daily Monthly', Colors.teal, Icons.calendar_today),
    'daily monthly': const _TripTypeDisplay(
        'Daily Monthly', Colors.teal, Icons.calendar_today),
    'dailyMonthlyRental': const _TripTypeDisplay(
        'Daily Monthly', Colors.teal, Icons.calendar_today),
    'dailymonthlyrental': const _TripTypeDisplay(
        'Daily Monthly', Colors.teal, Icons.calendar_today),
    'airporttransfer': const _TripTypeDisplay(
        'Airport Transfer', Colors.purple, Icons.flight_takeoff),
    'flexifleet': const _TripTypeDisplay(
        'Flexi Fleet', Colors.indigo, Icons.directions_car),
    'pickup drop':
        const _TripTypeDisplay('Pickup Drop', Colors.cyan, Icons.local_taxi),
    'journey': const _TripTypeDisplay('Journey', Colors.green, Icons.alt_route),

    'null': const _TripTypeDisplay('null', Colors.red, Icons.error),
    '': const _TripTypeDisplay('', Colors.red, Icons.error_outline),
    'none': const _TripTypeDisplay('none', Colors.red, Icons.error_outline),
  };
  // testing again again
  // Returns a tuple of display name, color, and icon for a given trip type string.
  static _TripTypeDisplay getDisplay(String? type) {
    final key = (type ?? '').toLowerCase();
    return _typeMap[key] ??
        _TripTypeDisplay(type ?? 'N/A', Colors.grey, Icons.help_outline);
  }
}

class _TripTypeDisplay {
  final String displayName;
  final Color color;
  final IconData icon;
  const _TripTypeDisplay(this.displayName, this.color, this.icon);
}
