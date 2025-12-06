import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../utils/styles.dart';
import '../model/staff_modal.dart';

class StaffDataSource extends DataGridSource {
  List<StaffModel> staffList = [];
  List<DataGridRow> _staffDataGridRows = [];
  Function(StaffModel) onViewDetails;
  Function(StaffModel)? onEdit;
  Function(StaffModel)? onDelete;
  final String Function(String) shortenLocation;

  StaffDataSource({
    required this.staffList,
    required this.onViewDetails,
    required this.shortenLocation,
    this.onEdit,
    this.onDelete,
  }) {
    _staffDataGridRows = staffList.map<DataGridRow>((staff) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'id', value: staff.id),
        DataGridCell<String>(columnName: 'username', value: staff.username),
        DataGridCell<String>(columnName: 'firstName', value: staff.firstname),
        DataGridCell<String>(columnName: 'lastName', value: staff.lastname),
        DataGridCell<String>(columnName: 'email', value: staff.email),
        DataGridCell<String>(columnName: 'phone', value: staff.phonenumber),
        DataGridCell<DateTime>(columnName: 'createdAt', value: staff.createdAt),
        DataGridCell<String>(columnName: 'address', value: staff.address),
        DataGridCell<StaffModel>(columnName: 'actions', value: staff),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _staffDataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        // Actions column
        if (dataGridCell.columnName == 'actions') {
          final StaffModel staff = dataGridCell.value as StaffModel;
          return Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_red_eye,
                      color: Styles.primaryColor, size: 20),
                  onPressed: () => onViewDetails(staff),
                  tooltip: 'View Details',
                ),
                const SizedBox(width: 8),
                // Edit button (if callback provided)
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: Styles.secondaryColor, size: 20),
                    onPressed: () => onEdit!(staff),
                    tooltip: 'Edit Staff',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => onDelete!(staff),
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
              ],
            ),
          );
        }

        // Address column with tooltip and shortened text
        if (dataGridCell.columnName == 'address') {
          final String fullAddress = dataGridCell.value as String;
          final String shortenedAddress = shortenLocation(fullAddress);
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(minHeight: 48),
            child: Tooltip(
              message: fullAddress,
              child: Text(
                shortenedAddress,
                style: TextStyles.tableCellText,
                overflow: TextOverflow.visible,
                maxLines: null, // Allow unlimited lines
              ),
            ),
          );
        }

        // Email column with tooltip for long emails
        if (dataGridCell.columnName == 'email') {
          final String email = dataGridCell.value as String;
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: email,
              child: Text(
                email,
                style: TextStyles.tableCellText,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        // Created At column with formatted date
        if (dataGridCell.columnName == 'createdAt') {
          final DateTime value = dataGridCell.value as DateTime;
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
              style: TextStyles.tableCellText,
            ),
          );
        }

        // Phone column with better formatting
        if (dataGridCell.columnName == 'phone') {
          final String phone = dataGridCell.value as String;
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              phone,
              style: TextStyles.tableCellText.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        // Default cell for other columns
        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            dataGridCell.value?.toString() ?? '',
            style: TextStyles.tableCellText,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}
