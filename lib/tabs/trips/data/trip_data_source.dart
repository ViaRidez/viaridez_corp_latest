import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/trip_model.dart';
import '../../../utils/trip_type_style.dart';
import '../../../utils/styles.dart';

class TripDataSource extends DataGridSource {
  final BuildContext context;
  final List<TripModel> trips;
  final Function(TripModel) onViewDetails;

  TripDataSource({
    required this.context,
    required this.trips,
    required this.onViewDetails,
  }) {
    // Sort trips by ID in descending order (newest first)
    final sortedTrips = List<TripModel>.from(trips)
      ..sort((a, b) => b.id.compareTo(a.id));

    _dataGridRows = sortedTrips.map<DataGridRow>((trip) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'id', value: trip.id),
        DataGridCell<String>(
            columnName: 'startDestination',
            value: trip.startDestination ?? 'N/A'),
        DataGridCell<String>(
            columnName: 'finalDestination',
            value: trip.finalDestination ?? 'N/A'),
        DataGridCell<String>(
            columnName: 'tripType', value: trip.tripType ?? 'N/A'),
        DataGridCell<String>(columnName: 'driver', value: trip.driverFullName),
        DataGridCell<String>(
            columnName: 'vehicle',
            value: trip.vehicleRegistrationNumber ?? 'N/A'),
        DataGridCell<String>(
            columnName: 'status', value: trip.tripStatus ?? 'N/A'),
        DataGridCell<String>(
            columnName: 'startDate', value: trip.formattedStartDate),
        DataGridCell<String>(
            columnName: 'endDate', value: trip.formattedEndDate),
        DataGridCell<String>(
            columnName: 'startTime', value: trip.formattedStartTime),
        DataGridCell<String>(
            columnName: 'endTime', value: trip.formattedEndTime),
        DataGridCell<int>(
            columnName: 'passengers', value: trip.totalNumberOfPssenger ?? 0),
        DataGridCell<double>(
            columnName: 'distance', value: trip.totalDistanceInKm ?? 0.0),
        DataGridCell<String>(
            columnName: 'createdAt', value: trip.formattedCreatedDate),
        DataGridCell<String>(columnName: 'action', value: 'view'),
      ]);
    }).toList();
  }

  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int tripId =
        row.getCells().firstWhere((cell) => cell.columnName == 'id').value;
    final TripModel trip = trips.firstWhere((t) => t.id == tripId);

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'action') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => onViewDetails(trip),
              icon: const Icon(Icons.visibility, size: 16, color: Colors.white),
              label: Text(
                'View',
                style: TextStyles.primaryButtonText.copyWith(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          );
        } else if (cell.columnName == 'tripType') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: _buildTripTypeChip(cell.value.toString()),
          );
        } else if (cell.columnName == 'status') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: _buildStatusChip(cell.value.toString()),
          );
        } else if (cell.columnName == 'startDestination' ||
            cell.columnName == 'finalDestination') {
          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: Tooltip(
              message: cell.value.toString(),
              child: Text(
                cell.value.toString(),
                style: TextStyles.tableCellText,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          );
        } else if (cell.columnName == 'distance') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: Text(
              '${(cell.value as double).toStringAsFixed(2)} km',
              style: TextStyles.tableCellText,
            ),
          );
        } else if (cell.columnName == 'startDate' ||
            cell.columnName == 'endDate' ||
            cell.columnName == 'createdAt') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: Text(
              cell.value.toString(),
              style: TextStyles.tableCellText.copyWith(
                fontWeight: FontWeight.w500,
                color: Styles.primaryColor,
              ),
            ),
          );
        } else {
          return Container(
            alignment:
                cell.columnName == 'id' || cell.columnName == 'passengers'
                    ? Alignment.center
                    : Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: Text(
              cell.value.toString(),
              style: TextStyles.tableCellText,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green;
        break;
      case 'ongoing':
        backgroundColor = Colors.blue;
        break;
      case 'pending':
        backgroundColor = Colors.orange;
        break;
      case 'unallocated':
        backgroundColor = Colors.grey;
        break;
      case 'cancel':
      case 'cancelled':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyles.chipText.copyWith(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTripTypeChip(String tripType) {
    final tripTypeDisplay = TripTypeStyle.getDisplay(tripType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tripTypeDisplay.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tripTypeDisplay.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tripTypeDisplay.icon,
            size: 14,
            color: tripTypeDisplay.color,
          ),
          const SizedBox(width: 4),
          Text(
            tripTypeDisplay.displayName,
            style: TextStyles.chipText.copyWith(
              color: tripTypeDisplay.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
