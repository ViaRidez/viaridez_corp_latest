import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../auth/provider/auth_provider.dart';
import '../../../utils/styles.dart';
import '../data/route_trip_data_source.dart';
import '../providers/route_provider.dart';

class RouteTripReportPage extends StatefulWidget {
  const RouteTripReportPage({super.key});

  @override
  State<RouteTripReportPage> createState() => _RouteTripReportPageState();
}

class _RouteTripReportPageState extends State<RouteTripReportPage> {
  final DataGridController _dataGridController = DataGridController();
  String _searchTerm = '';

  // State to control form visibility
  bool _showRouteForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTrips());
  }

  void _fetchTrips() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final routeProvider =
        Provider.of<RouteTripProvider>(context, listen: false);
    final token = authProvider.token;
    final clientName = authProvider.clientName;
    if (token != null && clientName != null && clientName.isNotEmpty) {
      await routeProvider.fetchRouteTrips(
        token: token,
        clientName: clientName,
        startDate: '2025-06-01',
        endDate: '2025-08-01',
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleRouteForm() {
    setState(() {
      _showRouteForm = !_showRouteForm;
    });
  }

  List<GridColumn> _buildColumns() {
    return [
      GridColumn(
        columnName: 'routeId',
        width: 100,
        label: _buildHeaderCell('ID'),
      ),
      GridColumn(
        columnName: 'startLocation',
        width: 340,
        label: _buildHeaderCell('Start Location'),
      ),
      GridColumn(
        columnName: 'endLocation',
        width: 340,
        label: _buildHeaderCell('End Location'),
      ),
      GridColumn(
        columnName: 'routeType',
        // width: 120,
        label: _buildHeaderCell('Route Type'),
      ),
      GridColumn(
        columnName: 'distance',
        // width: 120,
        label: _buildHeaderCell('Distance'),
      ),
      GridColumn(
        columnName: 'pitstopsCount',
        width: 140,
        label: _buildHeaderCell('Pitstops'),
      ),
      GridColumn(
          columnName: 'createdAt',
          // width: 120,
          label: _buildHeaderCell('Created'),
          visible: false),
      GridColumn(
        columnName: 'action',
        // width: 100,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.white,
      body: Consumer<RouteTripProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expandable Route Form
              if (_showRouteForm)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Add New Route",
                              style: TextStyles.pageTitle.copyWith(
                                fontSize: 20,
                                color: Styles.primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: _toggleRouteForm,
                              icon: const Icon(Icons.close),
                              tooltip: 'Close form',
                              color: Styles.tertiaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Route form will be implemented here',
                              style: TextStyles.bodyText.copyWith(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // The route list view when form is not shown
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.error != null
                          ? _buildErrorState(provider)
                          : provider.routeTrips.isEmpty
                              ? _buildEmptyState()
                              : Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color:
                                        //         Colors.black.withOpacity(0.05),
                                        //     blurRadius: 6,
                                        //     offset: const Offset(0, 3),
                                        //   ),
                                        // ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Page title
                                          Text(
                                            "Routes Utilize",
                                            style:
                                                TextStyles.pageTitle.copyWith(
                                              fontSize: 28,
                                              color: Styles.primaryColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 8, bottom: 16),
                                            height: 3,
                                            width: 60,
                                            color: Styles.primaryColor,
                                          ),

                                          // Search and actions row
                                          Row(
                                            children: [
                                              // Search box
                                              Expanded(
                                                child: Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: TextField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _searchTerm = value;
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Search routes...',
                                                      hintStyle: TextStyles
                                                          .hintText
                                                          .copyWith(
                                                        fontSize: 14,
                                                      ),
                                                      prefixIcon: Icon(
                                                        Icons.search,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: _buildFilteredRouteDataGrid(
                                            provider)),
                                  ],
                                ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilteredRouteDataGrid(RouteTripProvider provider) {
    // Filter routes based on search term
    final filteredRoutes = _searchTerm.isEmpty
        ? provider.routeTrips
        : provider.routeTrips.where((route) {
            final searchTermLower = _searchTerm.toLowerCase();
            return route.startLocation
                    .toLowerCase()
                    .contains(searchTermLower) ||
                route.endLocation.toLowerCase().contains(searchTermLower) ||
                route.routeId.toString().contains(searchTermLower) ||
                route.routeType.toLowerCase().contains(searchTermLower);
          }).toList();

    // Show message when no routes match the search
    if (filteredRoutes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.grey[400], size: 60),
            const SizedBox(height: 16),
            Text(
              _searchTerm.isEmpty
                  ? 'Create a new route to get started'
                  : 'Try adjusting your search',
              style: TextStyles.bodyText.copyWith(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            if (_searchTerm.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchTerm = '';
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
          ],
        ),
      );
    }

    // Create data source with filtered routes
    final RouteTripDataSource dataSource = RouteTripDataSource(
      routeTrips: filteredRoutes,
      context: context,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show search result count
        if (_searchTerm.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              'Found ${filteredRoutes.length} ${filteredRoutes.length == 1 ? "route" : "routes"} matching "$_searchTerm"',
              style: TextStyles.dataLabel.copyWith(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Data grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SfDataGrid(
              source: dataSource,
              columns: _buildColumns(),
              controller: _dataGridController,
              allowSorting: true,
              allowFiltering: true,
              allowColumnsResizing: true,
              isScrollbarAlwaysShown: true,
              rowHeight: 60,
              columnWidthMode: ColumnWidthMode.auto,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              selectionMode: SelectionMode.single,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(RouteTripProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 60),
          const SizedBox(height: 16),
          Text(
            'Failed to load routes',
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
            icon: const Icon(Icons.refresh),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route, color: Colors.grey[400], size: 60),
          const SizedBox(height: 16),
          Text(
            'No Routes Found',
            style: TextStyles.sectionTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new route to get started',
            style: TextStyles.bodyText.copyWith(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _toggleRouteForm,
            icon: const Icon(Icons.add),
            label: Text('Add New Route', style: TextStyles.primaryButtonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Styles.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
