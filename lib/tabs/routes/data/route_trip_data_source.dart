import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:viaridez_corp/utils/location_utils.dart';
import '../model/pit_stop.dart';
import '../model/route_model.dart';
import '../widgets/route_details_dialog.dart';

class RouteTripDataSource extends DataGridSource {
  final BuildContext context;
  final List<RouteTripReportModel> routeTrips;

  RouteTripDataSource({
    required this.context,
    required this.routeTrips,
  }) {
    _dataGridRows = routeTrips.map<DataGridRow>((trip) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'routeId', value: trip.routeId),
        DataGridCell<String>(
            columnName: 'startLocation', value: trip.startLocation),
        DataGridCell<String>(
            columnName: 'endLocation', value: trip.endLocation),
        DataGridCell<String>(columnName: 'routeType', value: trip.routeType),
        DataGridCell<double>(
            columnName: 'distance', value: trip.totalDistanceKm),
        DataGridCell<int>(
            columnName: 'pitstopsCount',
            value: _getPitStopsCount(trip.pitStops)),
        DataGridCell<String>(columnName: 'createdAt', value: 'N/A'),
        DataGridCell<String>(
            columnName: 'action',
            value:
                'view'), // You can add created date from trip model if available
      ]);
    }).toList();
  }

  int _getPitStopsCount(String pitStopsStr) {
    try {
      final pitStops = parsePitStops(pitStopsStr);
      return pitStops.length;
    } catch (e) {
      return 0;
    }
  }

  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int routeId =
        row.getCells().firstWhere((cell) => cell.columnName == 'routeId').value;
    final RouteTripReportModel trip =
        routeTrips.firstWhere((t) => t.routeId == routeId);

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'action') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => RouteDetailsDialog(
                    route: trip,
                    pitStopsStr: trip.pitStops,
                    tripDistance: trip.completedCount,
                    distanceCovered: trip.completedDistanceKm,
                  ),
                );
              },
              icon: const Icon(Icons.remove_red_eye,
                  size: 16, color: Colors.white),
              label: const Text(
                'View',
                style: TextStyle(color: Colors.white, fontFamily: 'Lexend'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F4E5F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          );
        } else if (cell.columnName == 'distance') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFDEE2E6), width: 1),
              ),
            ),
            child: Text(
              '${(cell.value as double).toStringAsFixed(2)} km',
              style: const TextStyle(fontFamily: 'Lexend'),
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else if (cell.columnName == 'startLocation' ||
            cell.columnName == 'endLocation') {
          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFDEE2E6), width: 1),
              ),
            ),
            child: Tooltip(
              message: cell.value.toString(),
              child: Text(
                LocationUtils.shortenLocation(cell.value.toString()),
                style: const TextStyle(fontFamily: 'Lexend'),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          );
        } else {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFDEE2E6), width: 1),
              ),
            ),
            child: Text(
              cell.value.toString(),
              style: const TextStyle(fontFamily: 'Lexend'),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      }).toList(),
    );
  }
}
