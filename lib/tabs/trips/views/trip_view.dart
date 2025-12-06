import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../auth/provider/auth_provider.dart';
import '../../../utils/styles.dart';
import '../providers/trip_provider.dart';
import '../models/trip_model.dart';
import '../data/trip_data_source.dart';

class TripView extends StatefulWidget {
  const TripView({super.key});

  @override
  State<TripView> createState() => _TripViewState();
}

class _TripViewState extends State<TripView> {
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTrips());
  }

  void _fetchTrips() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final clientName = authProvider.clientName;

    if (clientName != null && clientName.isNotEmpty) {
      await tripProvider.fetchTrips(clientName);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.white,
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive Header Section
              _buildResponsiveHeader(context, provider),

              // Main Content
              Expanded(
                child: _buildMainContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResponsiveHeader(BuildContext context, TripProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isMediumScreen = constraints.maxWidth >= 600 && constraints.maxWidth < 1000;

        double titleFont = isSmallScreen ? 20 : isMediumScreen ? 24 : 28;
        EdgeInsets titlePad = isSmallScreen
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
            : const EdgeInsets.all(24);

        final statusCards = [
          _buildStatusCard('All Trips', provider.trips.length, null, provider.selectedStatus == null, provider),
          _buildStatusCard('Unallocated', provider.unallocatedCount, TripStatus.unallocated, provider.selectedStatus == TripStatus.unallocated, provider),
          _buildStatusCard('Ongoing', provider.ongoingCount, TripStatus.ongoing, provider.selectedStatus == TripStatus.ongoing, provider),
          _buildStatusCard('Pending', provider.pendingCount, TripStatus.pending, provider.selectedStatus == TripStatus.pending, provider),
          _buildStatusCard('Completed', provider.completedCount, TripStatus.completed, provider.selectedStatus == TripStatus.completed, provider),
          _buildStatusCard('Cancelled', provider.cancelledCount, TripStatus.cancel, provider.selectedStatus == TripStatus.cancel, provider),
        ];

        return Container(
          padding: titlePad,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              Text(
                "Trip Management",
                style: TextStyles.pageTitle.copyWith(
                  fontSize: titleFont,
                  color: Styles.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                height: 3,
                width: isSmallScreen ? 40 : 60,
                color: Styles.primaryColor,
              ),

              // Status Filter Cards - Responsive
              isSmallScreen
                  ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: statusCards
                      .map((card) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(width: 140, child: card),
                  ))
                      .toList(),
                ),
              )
                  : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: statusCards
                    .map((card) => SizedBox(
                  width: isMediumScreen
                      ? (constraints.maxWidth / 3 - 16).clamp(150.0, 250.0)
                      : (constraints.maxWidth / 6 - 20).clamp(150.0, double.infinity),
                  child: card,
                ))
                    .toList(),
              ),

              SizedBox(height: isSmallScreen ? 12 : 20),

              // Search Row - Responsive
              isSmallScreen
                  ? Column(
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => provider.searchTrips(value),
                      decoration: InputDecoration(
                        hintText: 'Search trips by ID, destination, driver, vehicle...',
                        hintStyle: TextStyles.hintText.copyWith(fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Styles.primaryColor),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, color: Styles.primaryColor),
                          onPressed: () {
                            _searchController.clear();
                            provider.searchTrips('');
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        provider.clearFilters();
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text('Clear Filters', style: TextStyles.primaryButtonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              )
                  : Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => provider.searchTrips(value),
                        decoration: InputDecoration(
                          hintText: 'Search trips by ID, destination, driver, vehicle...',
                          hintStyle: TextStyles.hintText.copyWith(fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Styles.primaryColor),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear, color: Styles.primaryColor),
                            onPressed: () {
                              _searchController.clear();
                              provider.searchTrips('');
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text('Clear Filters', style: TextStyles.primaryButtonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(
      String title,
      int count,
      TripStatus? status,
      bool isSelected,
      TripProvider provider,
      ) {
    // Define specific colors for each status
    Color getStatusColor() {
      if (status == null) return Styles.primaryColor; // All Trips
      switch (status) {
        case TripStatus.unallocated:
          return Colors.orange;
        case TripStatus.ongoing:
          return Colors.blue;
        case TripStatus.pending:
          return Colors.amber;
        case TripStatus.completed:
          return Colors.green;
        case TripStatus.cancel:
          return Colors.red;
      }
    }

    Color statusColor = getStatusColor();
    Color backgroundColor = isSelected ? statusColor : Colors.white;
    Color textColor = isSelected ? Colors.white : statusColor;
    Color borderColor = isSelected ? statusColor : statusColor.withOpacity(0.3);

    return GestureDetector(
      onTap: () {
        provider.filterByStatus(status);
      },
      child: Container(
        padding: const EdgeInsets.all(6),
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
          children: [
            Text(
              count.toString(),
              style: TextStyles.cardTitle.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyles.chipText.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(TripProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Styles.primaryColor),
      );
    }

    if (provider.error != null) {
      return _buildErrorState(provider);
    }

    if (provider.filteredTrips.isEmpty) {
      return _buildEmptyState(provider);
    }

    return _buildDataGrid(provider);
  }

  Widget _buildErrorState(TripProvider provider) {
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
            provider.error!,
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

  Widget _buildEmptyState(TripProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trip_origin, color: Colors.grey[400], size: 60),
          const SizedBox(height: 16),
          Text(
            provider.searchQuery.isNotEmpty || provider.selectedStatus != null
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
            provider.searchQuery.isNotEmpty || provider.selectedStatus != null
                ? 'Try adjusting your filters'
                : 'Trips will appear here when available',
            style: TextStyles.bodyText.copyWith(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (provider.searchQuery.isNotEmpty ||
              provider.selectedStatus != null) ...[
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

  Widget _buildDataGrid(TripProvider provider) {
    final dataSource = TripDataSource(
      context: context,
      trips: provider.filteredTrips,
      onViewDetails: _viewTripDetails,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Text(
            'Showing ${provider.filteredTrips.length} of ${provider.trips.length} trips',
            style: TextStyles.dataLabel.copyWith(
              fontSize: 14,
            ),
          ),
        ),

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
                // columnWidthMode: ColumnWidthMode.auto,
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
                // headerRowHeight: 100,
                gridLinesVisibility: GridLinesVisibility.horizontal,
                headerGridLinesVisibility: GridLinesVisibility.both,
                // selectionMode: SelectionMode.single,
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
        columnName: 'startDestination',
        width: 250,
        label: _buildHeaderCell('Start Destination'),
      ),
      GridColumn(
        columnName: 'finalDestination',
        width: 250,
        label: _buildHeaderCell('Final Destination'),
      ),
      GridColumn(
        columnName: 'tripType',
        width: 200,
        label: _buildHeaderCell('Type'),
      ),
      GridColumn(
        columnName: 'driver',
        width: 150,
        label: _buildHeaderCell('Driver'),
      ),
      GridColumn(
        columnName: 'vehicle',
        width: 140,
        label: _buildHeaderCell('Vehicle'),
      ),
      GridColumn(
        columnName: 'status',
        width: 160,
        label: _buildHeaderCell('Status'),
      ),
      GridColumn(
        columnName: 'startDate',
        width: 120,
        label: _buildHeaderCell('Start Date'),
      ),
      GridColumn(
        columnName: 'endDate',
        width: 120,
        label: _buildHeaderCell('End Date'),
      ),
      GridColumn(
        columnName: 'startTime',
        width: 120,
        label: _buildHeaderCell('Start Time'),
      ),
      GridColumn(
        columnName: 'endTime',
        width: 120,
        label: _buildHeaderCell('End Time'),
      ),
      GridColumn(
        columnName: 'passengers',
        width: 110,
        label: _buildHeaderCell('Pax'),
      ),
      GridColumn(
        columnName: 'distance',
        width: 140,
        label: _buildHeaderCell('Distance'),
      ),
      GridColumn(
        columnName: 'createdAt',
        width: 140,
        label: _buildHeaderCell('Created'),
      ),
      GridColumn(
        columnName: 'action',
        width: 160,
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

  void _viewTripDetails(TripModel trip) {
    showDialog(
      context: context,
      builder: (context) => _buildTripDetailsDialog(trip),
    );
  }

  Widget _buildTripDetailsDialog(TripModel trip) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Styles.primaryColor,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trip_origin, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    "Trip #${trip.id} Details",
                    style: TextStyles.cardTitle.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info
                    _buildInfoSection("Basic Information", [
                      _buildInfoRow("Trip ID", trip.id.toString()),
                      _buildInfoRow("Trip Type", trip.tripType ?? 'N/A'),
                      _buildInfoRow("Status", trip.tripStatus ?? 'N/A'),
                      _buildInfoRow("Hub Location", trip.hubLocation ?? 'N/A'),
                      _buildInfoRow("Branch", trip.branchName ?? 'N/A'),
                    ]),

                    const SizedBox(height: 24),

                    // Destinations
                    _buildInfoSection("Destinations", [
                      _buildInfoRow(
                          "Start Destination", trip.startDestination ?? 'N/A'),
                      _buildInfoRow(
                          "Final Destination", trip.finalDestination ?? 'N/A'),
                      _buildInfoRow("Pitstops", trip.pitStopsCount),
                    ]),

                    const SizedBox(height: 24),

                    // Driver & Vehicle Info
                    _buildInfoSection("Driver & Vehicle", [
                      _buildInfoRow("Driver", trip.driverFullName),
                      _buildInfoRow(
                          "Driver Phone", trip.driverPhoneNumber ?? 'N/A'),
                      _buildInfoRow(
                          "Vehicle", trip.vehicleRegistrationNumber ?? 'N/A'),
                      _buildInfoRow("Vehicle ID", trip.vehicleOwnId ?? 'N/A'),
                      _buildInfoRow("Brand & Model",
                          "${trip.brand ?? 'N/A'} ${trip.model ?? 'N/A'}"),
                      _buildInfoRow("Seater", trip.seater?.toString() ?? 'N/A'),
                    ]),

                    const SizedBox(height: 24),

                    // Trip Details
                    _buildInfoSection("Trip Details", [
                      _buildInfoRow("Start Time", trip.formattedStartTime),
                      _buildInfoRow("End Time", trip.formattedEndTime),
                      _buildInfoRow("Total Passengers",
                          trip.totalNumberOfPssenger?.toString() ?? 'N/A'),
                      _buildInfoRow("Distance",
                          "${trip.totalDistanceInKm?.toStringAsFixed(2) ?? 'N/A'} km"),
                      _buildInfoRow("Trip Accepted",
                          trip.tripAccepted == true ? 'Yes' : 'No'),
                    ]),

                    const SizedBox(height: 24),

                    // Contact Information
                    _buildInfoSection("Contact Information", [
                      _buildInfoRow("Client POC", trip.pocClient ?? 'N/A'),
                      _buildInfoRow(
                          "Client Phone", trip.pocClientNumber ?? 'N/A'),
                      _buildInfoRow(
                          "Operations POC", trip.pocOperaion ?? 'N/A'),
                      _buildInfoRow(
                          "Operations Phone", trip.pocOperationNumber ?? 'N/A'),
                    ]),

                    if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildInfoSection("Notes", [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            trip.notes!,
                            style: const TextStyle(fontFamily: 'Lexend'),
                          ),
                        ),
                      ]),
                    ],

                    const SizedBox(height: 24),

                    // Created Date
                    _buildInfoSection("Metadata", [
                      _buildInfoRow("Created Date", trip.formattedCreatedDate),
                      _buildInfoRow(
                          "Route ID", trip.routeId?.toString() ?? 'N/A'),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.sectionTitle.copyWith(
            fontSize: 18,
            color: Styles.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyles.formLabel.copyWith(
                fontWeight: FontWeight.w600,
                color: Styles.tertiaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyles.bodyText.copyWith(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
