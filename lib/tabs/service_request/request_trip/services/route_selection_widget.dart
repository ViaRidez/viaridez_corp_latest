import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';
import '../models/route_model.dart';
import '../../../../utils/styles.dart';

class RouteSelectionWidget extends StatelessWidget {
  final String? selectedClient;
  final RouteModel? selectedRoute;
  final Function(RouteModel) onRouteSelected;

  const RouteSelectionWidget({
    super.key,
    required this.selectedClient,
    this.selectedRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRouteSelectionDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedRoute != null
                ? Styles.primaryColor.withOpacity(0.6)
                : Colors.grey.shade300,
            width: selectedRoute != null ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedRoute != null
              ? Styles.primaryColor.withOpacity(0.04)
              : Colors.grey.shade50,
          boxShadow: [
            if (selectedRoute != null)
              BoxShadow(
                color: Styles.primaryColor.withOpacity(0.12),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Route Selection',
                  style: TextStyle(
                    fontSize: 12,
                    color: selectedRoute != null
                        ? Styles.primaryColor.withOpacity(0.9)
                        : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: selectedRoute != null
                        ? Styles.primaryColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: selectedRoute != null
                        ? Styles.primaryColor
                        : Colors.grey[500],
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (selectedRoute != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Styles.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Styles.primaryColor,
                      size: 16,
                    ),
                  ),
                Expanded(
                  child: Text(
                    selectedRoute?.displayName ?? 'Tap to select a route',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedRoute != null
                          ? Styles.tertiaryColor
                          : Colors.grey[500],
                      fontWeight: selectedRoute != null
                          ? FontWeight.w600
                          : FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (selectedRoute != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (selectedRoute!.routeType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Styles.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Styles.primaryColor.withOpacity(0.3),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          selectedRoute!.routeTypeDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (selectedRoute!.totalRequests != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Styles.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Styles.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.route,
                              size: 12,
                              color: Styles.primaryColor.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${selectedRoute!.totalRequests} trips',
                              style: TextStyle(
                                color: Styles.primaryColor.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (selectedRoute!.parsedPitStops.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.orange.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stop_circle_outlined,
                              size: 12,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${selectedRoute!.parsedPitStops.length} stops',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Pitstops detail section
              if (selectedRoute!.parsedPitStops.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.orange.shade100,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selectedRoute!.formattedPitStops,
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _showRouteSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RouteSelectionDialog(
          selectedClient: selectedClient,
          selectedRoute: selectedRoute,
          onRouteSelected: (route) {
            Navigator.of(context).pop();
            onRouteSelected(route);
          },
        );
      },
    );
  }
}

class RouteSelectionDialog extends StatefulWidget {
  final String? selectedClient;
  final RouteModel? selectedRoute;
  final Function(RouteModel) onRouteSelected;

  const RouteSelectionDialog({
    super.key,
    required this.selectedClient,
    this.selectedRoute,
    required this.onRouteSelected,
  });

  @override
  State<RouteSelectionDialog> createState() => _RouteSelectionDialogState();
}

class _RouteSelectionDialogState extends State<RouteSelectionDialog> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void didUpdateWidget(RouteSelectionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedClient != oldWidget.selectedClient) {
      _loadRoutes();
    }
  }

  void _loadRoutes() {
    if (widget.selectedClient != null) {
      final routeProvider = Provider.of<RouteProvider>(context, listen: false);
      routeProvider.loadRoutesByClient(widget.selectedClient!);
    }
  }

  List<RouteModel> _getFilteredRoutes(List<RouteModel> routes) {
    if (_searchQuery.isEmpty) return routes;

    final query = _searchQuery.toLowerCase();
    return routes.where((route) {
      final routeName = route.routeName.toLowerCase();
      final startLocation = route.startLocation.toLowerCase();
      final endLocation = route.endLocation.toLowerCase();
      final shortStartLocation = route.shortStartLocation.toLowerCase();
      final shortEndLocation = route.shortEndLocation.toLowerCase();
      final routeType = route.routeType.toLowerCase();

      return routeName.contains(query) ||
          startLocation.contains(query) ||
          endLocation.contains(query) ||
          shortStartLocation.contains(query) ||
          shortEndLocation.contains(query) ||
          routeType.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 6,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Dialog Header with gradient
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Styles.primaryColor,
                    Styles.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Route',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    splashRadius: 18,
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<RouteProvider>(
                  builder: (context, routeProvider, child) {
                    if (routeProvider.isLoading) {
                      return Column(
                        children: [
                          // Search field (disabled during loading)
                          TextField(
                            controller: _searchController,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Loading routes...',
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Styles.primaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Styles.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Loading routes...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (routeProvider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: Colors.red.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Failed to load routes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    routeProvider.error!,
                                    style:
                                        TextStyle(color: Colors.red.shade600),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _loadRoutes,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Try Again'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredRoutes =
                        _getFilteredRoutes(routeProvider.routes);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search field
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'Search routes by name, location, or type...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Styles.primaryColor.withOpacity(0.7),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey.shade400,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Styles.primaryColor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),

                        const SizedBox(height: 14),

                        // Results count
                        if (filteredRoutes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              '${filteredRoutes.length} route${filteredRoutes.length == 1 ? '' : 's'} found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        // Routes list
                        Expanded(
                          child: filteredRoutes.isEmpty
                              ? Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(30),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          child: Icon(
                                            widget.selectedClient == null
                                                ? Icons.people_outline
                                                : _searchQuery.isNotEmpty
                                                    ? Icons.search_off
                                                    : Icons.route_outlined,
                                            size: 36,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          widget.selectedClient == null
                                              ? 'No Client Selected'
                                              : _searchQuery.isNotEmpty
                                                  ? 'No Results Found'
                                                  : 'No Routes Available',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          widget.selectedClient == null
                                              ? 'Please select a client first to view available routes'
                                              : _searchQuery.isNotEmpty
                                                  ? 'Try adjusting your search terms'
                                                  : 'No routes found for this client',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredRoutes.length,
                                  itemBuilder: (context, index) {
                                    final route = filteredRoutes[index];
                                    final isSelected =
                                        widget.selectedRoute?.routeId ==
                                            route.routeId;

                                    return Card(
                                      color: Colors.white,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      elevation: isSelected ? 4 : 2,
                                      shadowColor: isSelected
                                          ? Styles.primaryColor.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Styles.primaryColor
                                              : Colors.grey.shade200,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () =>
                                            widget.onRouteSelected(route),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: isSelected
                                              ? BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Styles.primaryColor
                                                          .withOpacity(0.05),
                                                      Styles.primaryColor
                                                          .withOpacity(0.02),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                )
                                              : null,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      route.routeName,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        color: isSelected
                                                            ? Styles
                                                                .primaryColor
                                                            : Styles
                                                                .tertiaryColor,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  if (isSelected)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Styles.primaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 14,
                                                      color: Styles.primaryColor
                                                          .withOpacity(0.7),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        '${route.shortStartLocation} → ${route.shortEndLocation}',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Pitstops section
                                              if (route.pitStops != null &&
                                                  route.pitStops!.isNotEmpty)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .orange.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        border: Border.all(
                                                          color: Colors
                                                              .orange.shade200,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .stop_circle_outlined,
                                                            size: 14,
                                                            color: Colors.orange
                                                                .shade700,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Pitstops (${route.parsedPitStops.length}):',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .orange
                                                                        .shade800,
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 2),
                                                                Text(
                                                                  route
                                                                      .formattedPitStops,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .orange
                                                                        .shade700,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                  ],
                                                ),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 6,
                                                children: [
                                                  if (route
                                                      .routeType.isNotEmpty)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? Styles
                                                                .primaryColor
                                                            : Colors
                                                                .grey.shade600,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: (isSelected
                                                                    ? Styles
                                                                        .primaryColor
                                                                    : Colors
                                                                        .grey
                                                                        .shade600)
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 1,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        route.routeTypeDisplay,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  if (route.totalRequests !=
                                                      null)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 6,
                                                        vertical: 3,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.blue.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                          color: Colors
                                                              .blue.shade200,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .directions_bus,
                                                            size: 12,
                                                            color: Colors
                                                                .blue.shade600,
                                                          ),
                                                          const SizedBox(
                                                              width: 3),
                                                          Text(
                                                            '${route.totalRequests} trips',
                                                            style: TextStyle(
                                                              color: Colors.blue
                                                                  .shade700,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  if (route.totalDistanceKm !=
                                                      null)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 6,
                                                        vertical: 3,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .green.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                          color: Colors
                                                              .green.shade200,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.straighten,
                                                            size: 12,
                                                            color: Colors
                                                                .green.shade600,
                                                          ),
                                                          const SizedBox(
                                                              width: 3),
                                                          Text(
                                                            '${route.totalDistanceKm!.toStringAsFixed(1)} km',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .green
                                                                  .shade700,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
