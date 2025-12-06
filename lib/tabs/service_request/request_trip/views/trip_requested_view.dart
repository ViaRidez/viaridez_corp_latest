import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import '../../../../utils/styles.dart';
import '../../../../utils/location_utils.dart';
import '../../../../auth/provider/auth_provider.dart';
import '../providers/trip_requested_provider.dart';
import '../models/journey_model.dart';
import 'trip_details_dialog.dart';

class TripRequestedView extends StatefulWidget {
  const TripRequestedView({super.key});

  @override
  State<TripRequestedView> createState() => _TripRequestedViewState();
}

class _TripRequestedViewState extends State<TripRequestedView> {
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTrips());
  }

  void _fetchTrips() async {
    final provider = Provider.of<TripRequestedProvider>(context, listen: false);
    // Get client name from auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clientName = authProvider.clientName!;
    await provider.fetchAllTrips(clientName: clientName);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper method to get responsive padding
  EdgeInsets _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      // Mobile
      return const EdgeInsets.all(16);
    } else if (screenWidth < 1200) {
      // Tablet
      return const EdgeInsets.all(20);
    } else {
      // Desktop/Web
      return const EdgeInsets.all(24);
    }
  }

  // Helper method to get responsive spacing
  double _getResponsiveSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 8.0; // Mobile
    } else if (screenWidth < 1200) {
      return 10.0; // Tablet
    } else {
      return 12.0; // Desktop/Web
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.white,
      body: Consumer<TripRequestedProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section - Made Responsive
              Container(
                padding: _getResponsivePadding(context),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter Cards - Responsive Layout
                    _buildResponsiveStatusCards(context, provider),

                    SizedBox(height: _getResponsiveSpacing(context) + 8),

                    // Search Row - Responsive Layout
                    _buildResponsiveSearchRow(context, provider),
                  ],
                ),
              ),

              // Main Content - DataGrid unchanged
              Expanded(
                child: _buildMainContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResponsiveStatusCards(BuildContext context, TripRequestedProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = _getResponsiveSpacing(context);

    // Mobile layout - 2x2 grid
    if (screenWidth < 600) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'All Trips',
                  provider.allTrips.length,
                  'All',
                  provider.selectedStatus == 'All',
                  provider,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildStatusCard(
                  'Requested',
                  provider.getTripCountByStatus()['Requested'] ?? 0,
                  'Requested',
                  provider.selectedStatus == 'Requested',
                  provider,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Accepted',
                  provider.getTripCountByStatus()['Accepted'] ?? 0,
                  'Accepted',
                  provider.selectedStatus == 'Accepted',
                  provider,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildStatusCard(
                  'Rejected',
                  provider.getTripCountByStatus()['Rejected'] ?? 0,
                  'Rejected',
                  provider.selectedStatus == 'Rejected',
                  provider,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Tablet and Desktop - Single row
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'All Trips',
            provider.allTrips.length,
            'All',
            provider.selectedStatus == 'All',
            provider,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildStatusCard(
            'Requested',
            provider.getTripCountByStatus()['Requested'] ?? 0,
            'Requested',
            provider.selectedStatus == 'Requested',
            provider,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildStatusCard(
            'Accepted',
            provider.getTripCountByStatus()['Accepted'] ?? 0,
            'Accepted',
            provider.selectedStatus == 'Accepted',
            provider,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildStatusCard(
            'Rejected',
            provider.getTripCountByStatus()['Rejected'] ?? 0,
            'Rejected',
            provider.selectedStatus == 'Rejected',
            provider,
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveSearchRow(BuildContext context, TripRequestedProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = _getResponsiveSpacing(context);

    // Mobile layout - Stack vertically
    if (screenWidth < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Field
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                provider.setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search trips by ID, location, type, branch...',
                hintStyle: TextStyles.hintText.copyWith(
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Styles.primaryColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Styles.primaryColor),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          SizedBox(height: spacing),
          // Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    provider.clearFilters();
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text('Clear Filters',
                      style: TextStyles.primaryButtonText.copyWith(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _fetchTrips,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text('Refresh',
                      style: TextStyles.primaryButtonText.copyWith(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Tablet and Desktop - Single row
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                provider.setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search trips by ID, location, type, branch...',
                hintStyle: TextStyles.hintText.copyWith(
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Styles.primaryColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Styles.primaryColor),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: spacing + 4),
        ElevatedButton.icon(
          onPressed: () {
            _searchController.clear();
            provider.clearFilters();
          },
          icon: const Icon(
            Icons.clear,
            color: Colors.white,
          ),
          label: Text('Clear Filters', style: TextStyles.primaryButtonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: Styles.secondaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 1200 ? 12 : 16,
                vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(width: spacing + 4),
        ElevatedButton.icon(
          onPressed: _fetchTrips,
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          label: Text('Refresh', style: TextStyles.primaryButtonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: Styles.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 1200 ? 12 : 16,
                vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
      String title,
      int count,
      String status,
      bool isSelected,
      TripRequestedProvider provider,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define specific colors for each status
    Color getStatusColor() {
      switch (status) {
        case 'All':
          return Styles.primaryColor;
        case 'Requested':
          return Colors.orange;
        case 'Accepted':
          return Colors.green;
        case 'Rejected':
          return Colors.red;
        default:
          return Styles.primaryColor;
      }
    }

    Color statusColor = getStatusColor();
    Color backgroundColor = isSelected ? statusColor : Colors.white;
    Color textColor = isSelected ? Colors.white : statusColor;
    Color borderColor = isSelected ? statusColor : statusColor.withOpacity(0.3);

    // Responsive font sizes
    double countFontSize = screenWidth < 600 ? 22 : 26;
    double titleFontSize = screenWidth < 600 ? 11 : 12;
    double cardPadding = screenWidth < 600 ? 12 : 16;

    return GestureDetector(
      onTap: () {
        provider.setStatusFilter(status);
      },
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: statusColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: TextStyles.cardTitle.copyWith(
                fontSize: countFontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyles.chipText.copyWith(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Rest of your existing methods remain unchanged
  Widget _buildMainContent(TripRequestedProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Styles.primaryColor),
      );
    }

    if (provider.hasError) {
      return _buildErrorState(provider);
    }

    if (provider.filteredTrips.isEmpty) {
      return _buildEmptyState(provider);
    }

    return _buildDataGrid(provider);
  }

  Widget _buildErrorState(TripRequestedProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 60),
          const SizedBox(height: 16),
          Text(
            'Failed to load trips',
            style: TextStyles.sectionTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? 'Unknown error occurred',
            style: TextStyles.errorText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchTrips,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            label: Text('Try Again', style: TextStyles.primaryButtonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Styles.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TripRequestedProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus, color: Colors.grey[400], size: 60),
          const SizedBox(height: 16),
          Text(
            provider.searchQuery.isNotEmpty || provider.selectedStatus != 'All'
                ? 'No trips found'
                : 'No trips available',
            style: TextStyles.sectionTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.searchQuery.isNotEmpty || provider.selectedStatus != 'All'
                ? 'Try adjusting your filters'
                : 'Trips will appear here when available',
            style: TextStyles.bodyText.copyWith(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (provider.searchQuery.isNotEmpty ||
              provider.selectedStatus != 'All') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                provider.clearFilters();
              },
              icon: const Icon(
                Icons.clear,
                color: Colors.white,
              ),
              label: Text('Clear Filters', style: TextStyles.primaryButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.secondaryColor,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataGrid(TripRequestedProvider provider) {
    final dataSource = TripRequestedDataSource(
      context: context,
      trips: provider.filteredTrips,
      onViewDetails: _viewTripDetails,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Data Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SfDataGridTheme(
              data: SfDataGridThemeData(
                headerColor: Colors.grey[100],
                gridLineColor: Colors.grey[300]!,
                gridLineStrokeWidth: 1.0,
              ),
              child: SfDataGrid(
                allowSorting: true,
                allowFiltering: true,
                allowMultiColumnSorting: true,
                allowTriStateSorting: true,
                showSortNumbers: true,
                frozenColumnsCount: 1,
                source: dataSource,
                columns: _buildColumns(),
                controller: _dataGridController,
                allowColumnsResizing: true,
                isScrollbarAlwaysShown: true,
                rowHeight: 70,
                gridLinesVisibility: GridLinesVisibility.horizontal,
                headerGridLinesVisibility: GridLinesVisibility.both,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<GridColumn> _buildColumns() {
    return [
      GridColumn(
        columnName: 'id',
        width: 100,
        label: _buildHeaderCell('ID'),
      ),
      GridColumn(
          columnName: 'hubLocation',
          width: 150,
          label: _buildHeaderCell('Hub'),
          visible: false),
      GridColumn(
        columnName: 'startDestination',
        width: 200,
        label: _buildHeaderCell('Start'),
      ),
      GridColumn(
        columnName: 'finalDestination',
        width: 200,
        label: _buildHeaderCell('Destination'),
      ),
      GridColumn(
        columnName: 'journeyType',
        width: 120,
        label: _buildHeaderCell('Type'),
      ),
      GridColumn(
        columnName: 'branchName',
        width: 150,
        label: _buildHeaderCell('Branch'),
      ),
      GridColumn(
        columnName: 'totalPassengers',
        width: 120,
        label: _buildHeaderCell('Passengers'),
      ),
      GridColumn(
        columnName: 'distance',
        width: 140,
        label: _buildHeaderCell('Distance (km)'),
      ),
      GridColumn(
        columnName: 'pitStops',
        width: 120,
        label: _buildHeaderCell('Pit Stops'),
      ),
      GridColumn(
        columnName: 'pocClient',
        width: 150,
        label: _buildHeaderCell('POC Client'),
        visible: false,
      ),
      GridColumn(
        columnName: 'createdAt',
        width: 150,
        label: _buildHeaderCell('Created'),
        visible: false,
      ),
      GridColumn(
        columnName: 'status',
        width: 130,
        label: _buildHeaderCell('Status'),
      ),
      GridColumn(
        columnName: 'action',
        width: 150,
        label: _buildHeaderCell('Actions'),
      ),
    ];
  }

  Widget _buildHeaderCell(String title) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyles.tableHeaderText.copyWith(
          fontSize: 14,
          color: Styles.tertiaryColor,
        ),
      ),
    );
  }

  void _viewTripDetails(JourneyModel trip) {
    showTripDetailsDialog(context, trip);
  }
}

// DataSource class remains exactly the same
class TripRequestedDataSource extends DataGridSource {
  final BuildContext context;
  final List<JourneyModel> trips;
  final Function(JourneyModel) onViewDetails;

  TripRequestedDataSource({
    required this.context,
    required this.trips,
    required this.onViewDetails,
  }) {
    // Sort trips by ID in descending order (newest first)
    final sortedTrips = List<JourneyModel>.from(trips)
      ..sort((a, b) => b.id.compareTo(a.id));

    _trips = sortedTrips
        .map<DataGridRow>((trip) => DataGridRow(cells: [
      DataGridCell<int>(columnName: 'id', value: trip.id),
      DataGridCell<String>(
        columnName: 'hubLocation',
        value: trip.hubLocation,
      ),
      DataGridCell<String>(
        columnName: 'startDestination',
        value: LocationUtils.shortenLocation(trip.startDestination),
      ),
      DataGridCell<String>(
        columnName: 'finalDestination',
        value: LocationUtils.shortenLocation(trip.finalDestination),
      ),
      DataGridCell<String>(
        columnName: 'journeyType',
        value: trip.journeyType,
      ),
      DataGridCell<String>(
        columnName: 'branchName',
        value: trip.branchName,
      ),
      DataGridCell<int>(
        columnName: 'totalPassengers',
        value: trip.totalNumberOfPssenger,
      ),
      DataGridCell<double>(
        columnName: 'distance',
        value: trip.totalDistanceInKm,
      ),
      DataGridCell<int>(
        columnName: 'pitStops',
        value: trip.pitStops.length,
      ),
      DataGridCell<String>(
        columnName: 'pocClient',
        value: trip.pocClient,
      ),
      DataGridCell<String>(
        columnName: 'createdAt',
        value: DateFormat('MMM dd, yyyy')
            .format(DateTime.parse(trip.createdAt)),
      ),
      DataGridCell<String>(
        columnName: 'status',
        value: trip.statusName ?? 'Unknown',
      ),
      DataGridCell<JourneyModel>(
        columnName: 'action',
        value: trip,
      ),
    ]))
        .toList();
  }

  List<DataGridRow> _trips = [];

  @override
  List<DataGridRow> get rows => _trips;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        Color? cellColor;
        Color? textColor;

        // Action column
        if (cell.columnName == 'action') {
          final trip = cell.value as JourneyModel;
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => onViewDetails(trip),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(80, 32),
              ),
              child: Text(
                'View',
                style: TextStyles.primaryButtonText.copyWith(fontSize: 12),
              ),
            ),
          );
        }

        // Special handling for location columns to show tooltips
        if (cell.columnName == 'startDestination' ||
            cell.columnName == 'finalDestination') {
          final trip = row
              .getCells()
              .firstWhere((c) => c.columnName == 'action')
              .value as JourneyModel;
          final fullLocation = cell.columnName == 'startDestination'
              ? trip.startDestination
              : trip.finalDestination;

          return Container(
            color: cellColor,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: fullLocation,
              child: Text(
                cell.value.toString(),
                style: TextStyles.tableCellText.copyWith(
                  color: textColor ?? Styles.tertiaryColor.withOpacity(0.9),
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        // Special handling for distance column to show 2 decimal places
        if (cell.columnName == 'distance') {
          final distance = cell.value as double;
          return Container(
            color: cellColor,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              distance.toStringAsFixed(2),
              style: TextStyles.tableCellText.copyWith(
                color: textColor ?? Styles.tertiaryColor.withOpacity(0.9),
                fontWeight: FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        // Special handling for status column to show colored badges
        if (cell.columnName == 'status') {
          final status = cell.value as String;
          Color statusColor;

          switch (status.toLowerCase()) {
            case 'requested':
              statusColor = Colors.orange;
              break;
            case 'accepted':
              statusColor = Colors.green;
              break;
            case 'rejected':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.grey;
          }

          return Container(
            color: cellColor,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                status,
                style: TextStyles.tableCellText.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }

        return Container(
          color: cellColor,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell.value.toString(),
            style: TextStyles.tableCellText.copyWith(
              color: textColor ?? Styles.tertiaryColor.withOpacity(0.9),
              fontWeight: FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}

// Utility function to show the trip details dialog
void showTripDetailsDialog(BuildContext context, JourneyModel trip) {
  showDialog(
    context: context,
    builder: (context) => TripDetailsDialog(trip: trip),
  );
}
