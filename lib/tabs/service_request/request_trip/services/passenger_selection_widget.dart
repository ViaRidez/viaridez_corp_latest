import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/styles.dart';
import '../services/pax_provider.dart';

class PassengerSelectionWidget extends StatefulWidget {
  final dynamic selectedClient;
  final Function(dynamic) onClientChanged;
  final List<String> selectedPassengerIds;
  final Function(String) onPassengerToggle;
  final Function() onClearAllPassengers;

  const PassengerSelectionWidget({
    Key? key,
    required this.selectedClient,
    required this.onClientChanged,
    required this.selectedPassengerIds,
    required this.onPassengerToggle,
    required this.onClearAllPassengers,
  }) : super(key: key);

  @override
  State<PassengerSelectionWidget> createState() =>
      _PassengerSelectionWidgetState();
}

class _PassengerSelectionWidgetState extends State<PassengerSelectionWidget> {
  final TextEditingController _passengerSearchController =
      TextEditingController();
  int _currentPage = 0;
  final int _itemsPerPage = 50;
  final ScrollController _passengersScrollController = ScrollController();

  @override
  void dispose() {
    _passengerSearchController.dispose();
    _passengersScrollController.dispose();
    super.dispose();
  }

  // Filter passengers based on search query
  List<dynamic> _getFilteredPassengers(PaxProvider paxProvider) {
    List<dynamic> filtered = paxProvider.filteredPassengers;

    if (_passengerSearchController.text.isNotEmpty) {
      final query = _passengerSearchController.text.toLowerCase();
      filtered = paxProvider.filteredPassengers.where((passenger) {
        final fullName = passenger.fullName.toLowerCase();
        final email = passenger.email.toLowerCase();
        final phone = passenger.phonenumber.toLowerCase();
        final boardingPlace = passenger.boardingPlace.toLowerCase();

        return fullName.contains(query) ||
            email.contains(query) ||
            phone.contains(query) ||
            boardingPlace.contains(query);
      }).toList();
    }

    return filtered;
  }

  // Get paginated passengers for display
  List<dynamic> _getPaginatedPassengers(List<dynamic> allPassengers) {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, allPassengers.length);

    if (startIndex >= allPassengers.length) return [];

    return allPassengers.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaxProvider>(
      builder: (context, paxProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Select Passengers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Styles.tertiaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Passenger selection section
            _buildExistingPassengerSection(paxProvider),
          ],
        );
      },
    );
  }

  Widget _buildExistingPassengerSection(PaxProvider paxProvider) {
    return Column(
      children: [
        // Show loading indicator when loading passengers
        if (paxProvider.isLoading)
          Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(
                color: Styles.primaryColor,
              ),
            ),
          )
        else if (paxProvider.error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading passengers: ${paxProvider.error}',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (paxProvider.filteredPassengers.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No passengers found.',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _buildPassengersList(paxProvider),
      ],
    );
  }

  // Build passengers list with enhanced UI/UX
  Widget _buildPassengersList(PaxProvider paxProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected passengers summary
        if (widget.selectedPassengerIds.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.group,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.selectedPassengerIds.length} passenger(s) selected',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showSelectedPassengersDialog(paxProvider),
                  icon: Icon(
                    Icons.visibility,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  label: Text(
                    'View',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onClearAllPassengers,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Passengers list
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Styles.primaryColor.withOpacity(0.08),
                      Styles.primaryColor.withOpacity(0.03),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Styles.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: Styles.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Available Passengers (${_getFilteredPassengers(paxProvider).length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Styles.primaryColor,
                            ),
                          ),
                        ),
                        // Bulk actions for large datasets
                        if (_getFilteredPassengers(paxProvider).length >
                            10) ...[
                          TextButton(
                            onPressed: () {
                              // Select first 20 passengers
                              final passengers =
                                  _getFilteredPassengers(paxProvider);
                              final toSelect = passengers
                                  .take(20)
                                  .map((p) => p.id.toString())
                                  .toList();
                              for (String id in toSelect) {
                                if (!widget.selectedPassengerIds.contains(id)) {
                                  widget.onPassengerToggle(id);
                                }
                              }
                            },
                            child: Text(
                              'Select 20',
                              style: TextStyle(
                                color: Styles.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_getFilteredPassengers(paxProvider).length > 50)
                            TextButton(
                              onPressed: () {
                                // Select first 50 passengers
                                final passengers =
                                    _getFilteredPassengers(paxProvider);
                                final toSelect = passengers
                                    .take(50)
                                    .map((p) => p.id.toString())
                                    .toList();
                                for (String id in toSelect) {
                                  if (!widget.selectedPassengerIds
                                      .contains(id)) {
                                    widget.onPassengerToggle(id);
                                  }
                                }
                              },
                              child: Text(
                                'Select 50',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    TextField(
                      controller: _passengerSearchController,
                      decoration: InputDecoration(
                        hintText:
                            'Search by name, email, phone, or boarding place...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Styles.primaryColor.withOpacity(0.7),
                          size: 20,
                        ),
                        suffixIcon: _passengerSearchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passengerSearchController.clear();
                                    _currentPage = 0; // Reset pagination
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Styles.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) {
                        setState(() {
                          _currentPage = 0; // Reset pagination when searching
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Passengers list
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    final filteredPassengers =
                        _getFilteredPassengers(paxProvider);

                    if (filteredPassengers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _passengerSearchController.text.isNotEmpty
                                  ? 'No passengers found matching your search'
                                  : 'No passengers available',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_passengerSearchController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _passengerSearchController.clear();
                                    _currentPage = 0; // Reset pagination
                                  });
                                },
                                child: Text(
                                  'Clear search',
                                  style: TextStyle(
                                    color: Styles.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Stats header for large datasets
                        if (filteredPassengers.length > 100)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Styles.primaryColor.withOpacity(0.05),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Styles.primaryColor.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Large dataset: ${filteredPassengers.length} passengers. Use search to narrow results.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Styles.primaryColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${widget.selectedPassengerIds.length} selected',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Styles.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Passenger list with improved scrolling
                        Expanded(
                          child: filteredPassengers.length > 1000
                              ? _buildVirtualizedList(filteredPassengers)
                              : _buildRegularList(filteredPassengers),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build regular list for smaller datasets (< 1000 passengers)
  Widget _buildRegularList(List<dynamic> passengers) {
    return ListView.builder(
      controller: _passengersScrollController,
      padding: const EdgeInsets.all(8),
      itemCount: passengers.length,
      itemBuilder: (context, index) {
        return _buildPassengerCard(passengers[index]);
      },
    );
  }

  // Build virtualized list for very large datasets (>= 1000 passengers)
  Widget _buildVirtualizedList(List<dynamic> passengers) {
    final paginatedPassengers = _getPaginatedPassengers(passengers);
    final totalPages = (passengers.length / _itemsPerPage).ceil();

    return Column(
      children: [
        // Page indicator for large datasets
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Text(
                  'Page ${_currentPage + 1} of $totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      icon: Icon(
                        Icons.chevron_left,
                        color: _currentPage > 0
                            ? Styles.primaryColor
                            : Colors.grey.shade400,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _currentPage < totalPages - 1
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      icon: Icon(
                        Icons.chevron_right,
                        color: _currentPage < totalPages - 1
                            ? Styles.primaryColor
                            : Colors.grey.shade400,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Paginated list
        Expanded(
          child: ListView.builder(
            controller: _passengersScrollController,
            padding: const EdgeInsets.all(8),
            itemCount: paginatedPassengers.length,
            itemBuilder: (context, index) {
              return _buildPassengerCard(paginatedPassengers[index]);
            },
          ),
        ),
      ],
    );
  }

  // Build individual passenger card - extracted for reusability
  Widget _buildPassengerCard(dynamic passenger) {
    final isSelected =
        widget.selectedPassengerIds.contains(passenger.id.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected ? Styles.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? Styles.primaryColor.withOpacity(0.3)
              : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            widget.onPassengerToggle(passenger.id.toString());
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Styles.primaryColor : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      passenger.fullName.isNotEmpty
                          ? passenger.fullName[0].toUpperCase()
                          : 'P',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Passenger info - compact layout
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        passenger.fullName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Styles.primaryColor
                              : Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Compact info in single line
                      Text(
                        [
                          if (passenger.email.isNotEmpty) passenger.email,
                          if (passenger.phonenumber.isNotEmpty)
                            passenger.phonenumber,
                          if (passenger.boardingPlace?.isNotEmpty ?? false)
                            passenger.boardingPlace,
                        ].join(' • '),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Styles.primaryColor
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                    color:
                        isSelected ? Styles.primaryColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to show selected passengers dialog
  void _showSelectedPassengersDialog(PaxProvider paxProvider) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final selectedPassengers = paxProvider.filteredPassengers
              .where((passenger) =>
                  widget.selectedPassengerIds.contains(passenger.id.toString()))
              .toList();

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 800,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Styles.primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.group,
                          color: Styles.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Selected Passengers (${selectedPassengers.length})',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Styles.primaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: selectedPassengers.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.group_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No passengers selected',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: selectedPassengers.length,
                            itemBuilder: (context, index) {
                              final passenger = selectedPassengers[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Styles.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          passenger.fullName.isNotEmpty
                                              ? passenger.fullName[0]
                                                  .toUpperCase()
                                              : 'P',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            passenger.fullName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (passenger.email.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              passenger.email,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                          if (passenger
                                              .phonenumber.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              passenger.phonenumber,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        widget.onPassengerToggle(
                                            passenger.id.toString());
                                        setState(
                                            () {}); // Trigger rebuild of the dialog
                                      },
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
