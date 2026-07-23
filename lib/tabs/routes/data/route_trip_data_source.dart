import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:viaridez_corp/utils/location_utils.dart';
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
            value: trip.pitStopsCount), // ✅ use getter, not old string method
        DataGridCell<String>(columnName: 'createdAt', value: 'N/A'),
        DataGridCell<String>(columnName: 'action', value: 'view'),
      ]);
    }).toList();
  }

  // ✅ Removed _getPitStopsCount(String) — pitStops is now List<dynamic>
  //    Use trip.pitStopsCount (getter on model) instead

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
                    pitStopsStr: trip.pitStopsStr,       // ✅ was trip.pitStops (List)
                    tripDistance: trip.completedCount,   // ✅ resolves (defaults to 0)
                    distanceCovered: trip.completedDistanceKm, // ✅ resolves (defaults to 0.0)
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