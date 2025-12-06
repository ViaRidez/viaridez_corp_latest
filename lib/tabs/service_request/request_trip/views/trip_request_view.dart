import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../auth/provider/auth_provider.dart';
import '../../../../utils/styles.dart';
import '../../../../widgets/opt_large_textfield.dart';
import '../../../../widgets/opt_textfield.dart';
import '../providers/trip_request_provider.dart';
import '../providers/route_provider.dart';
import '../services/passenger_selection_widget.dart';
import '../services/pax_provider.dart';
import '../services/route_selection_widget.dart';

class TripRequestView extends StatefulWidget {
  const TripRequestView({super.key});

  @override
  _TripRequestViewState createState() => _TripRequestViewState();
}

class _TripRequestViewState extends State<TripRequestView> {
  final _formKey = GlobalKey<FormState>();
  String? clientName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add listener for trip status changes
    final tripProvider = Provider.of<TripRequestProvider>(context);
    tripProvider.removeListener(_tripStatusListener); // Prevent duplicate
    tripProvider.addListener(_tripStatusListener);
  }

  @override
  void dispose() {
    final tripProvider =
        Provider.of<TripRequestProvider>(context, listen: false);
    tripProvider.removeListener(_tripStatusListener);
    super.dispose();
  }

  void _tripStatusListener() {
    final tripProvider =
        Provider.of<TripRequestProvider>(context, listen: false);
    if (tripProvider.submitStatus == TripSubmitStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip schedule successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (tripProvider.submitStatus == TripSubmitStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(tripProvider.errorMessage ?? 'Failed to save trip schedule'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  DateTime _combineDateAndShiftTime(DateTime baseDate, String shiftTime) {
    final parts = shiftTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final second = int.parse(parts[2]);

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
      second,
    );
  }


  @override
  void initState() {
    super.initState();
    _getClientName();

    // Initialize PaxProvider and RouteProvider and load data after getting client name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (clientName != null) {
        final paxProvider = Provider.of<PaxProvider>(context, listen: false);
        paxProvider.loadPassengersByClient(clientName!);

        final routeProvider =
            Provider.of<RouteProvider>(context, listen: false);
        routeProvider.loadRoutesByClient(clientName!);
      }
    });
  }

  void _getClientName() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    clientName = authProvider.clientName;
    // Note: Data loading is moved to addPostFrameCallback to avoid setState during build
  }

  Future<void> _selectDateTime(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final tripProvider =
    Provider.of<TripRequestProvider>(context, listen: false);

    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (datePicked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (timePicked != null) {
        final DateTime dateTime = DateTime(
          datePicked.year,
          datePicked.month,
          datePicked.day,
          timePicked.hour,
          timePicked.minute,
        );

        if (controller == tripProvider.tripStartDateTimeController) {
          tripProvider.tripStartDateTime = dateTime;
        } else if (controller == tripProvider.tripEndDateTimeController) {
          // ✅ Check validation here
          if (tripProvider.tripStartDateTime != null &&
              dateTime.isBefore(tripProvider.tripStartDateTime!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Trip End Date & Time cannot be before Start Date & Time'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return; // 🚫 don’t set the value
          }
          tripProvider.tripEndDateTime = dateTime;
        }

        // Format for display
        final DateFormat displayFormat =
        DateFormat('MMM d, yyyy \'at\' h:mm a');
        controller.text = displayFormat.format(dateTime);
      }
    }
  }


  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final tripProvider =
        Provider.of<TripRequestProvider>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      // Store the raw time value for backend (24-hour format with seconds)
      final String rawTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      tripProvider.shiftStartTime = rawTime;

      // Format time for display: "3:30 PM"
      // Use MaterialLocalizations for proper localized time format
      final materialLocalizations = MaterialLocalizations.of(context);
      final formattedTime = materialLocalizations.formatTimeOfDay(picked,
          alwaysUse24HourFormat: false // Set to true if you want 24-hour format
          );

      controller.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer3<TripRequestProvider, PaxProvider, RouteProvider>(
        builder: (context, tripProvider, paxProvider, routeProvider, _) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header - Trip Information
                  _buildSectionHeader('Trip Information'),
                  const SizedBox(height: 16),

                  // Route Selection Widget
                  RouteSelectionWidget(
                    selectedClient: clientName,
                    selectedRoute: tripProvider.selectedRoute,
                    onRouteSelected: (route) {
                      tripProvider.setSelectedRoute(route);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section Header - Schedule
                  _buildSectionHeader('Schedule & Time'),
                  const SizedBox(height: 16),

                  // Row 4: Trip Start and End Time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column - Trip Start DateTime
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDateTime(context,
                              tripProvider.tripStartDateTimeController),
                          child: AbsorbPointer(
                            child: OptTextfield(
                              inputText: "Trip Start Date & Time",
                              controller:
                                  tripProvider.tripStartDateTimeController,
                              validator: (p0) => p0!.isEmpty
                                  ? "Trip Start Date & Time cannot be empty"
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right column - Trip End DateTime
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDateTime(
                              context, tripProvider.tripEndDateTimeController),
                          child: AbsorbPointer(
                            child: OptTextfield(
                              inputText: "Trip End Date & Time",
                              controller:
                                  tripProvider.tripEndDateTimeController,
                              validator: (p0) => p0!.isEmpty
                                  ? "Trip End Date & Time cannot be empty"
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Row 5: Shift Start Time and Operating Days
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column - Shift Start Time
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectTime(
                              context, tripProvider.shiftStartTimeController),
                          child: AbsorbPointer(
                            child: OptTextfield(
                              inputText: "Shift Start Time",
                              controller: tripProvider.shiftStartTimeController,
                              validator: (p0) => p0!.isEmpty
                                  ? "Shift Start Time cannot be empty"
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right column - Operating Days

                      // Right column - Operating Days - Custom Implementation
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Days of week selector
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tripProvider.daysOfWeek.map((day) {
                                final isSelected =
                                    tripProvider.operatingDays.contains(day);
                                return InkWell(
                                  onTap: () {
                                    if (isSelected) {
                                      tripProvider.removeOperatingDay(day);
                                    } else {
                                      tripProvider.setOperatingDays(
                                          [...tripProvider.operatingDays, day]);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Styles.primaryColor
                                            : Styles.primaryColor
                                                .withOpacity(0.3),
                                      ),
                                      color: isSelected
                                          ? Styles.primaryColor.withOpacity(0.1)
                                          : Colors.transparent,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Text(
                                        day,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Styles.primaryColor
                                              : Styles.primaryColor
                                                  .withOpacity(0.4),
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            if (tripProvider.operatingDays.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Please select at least one operating day',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section Header - Passengers
                  _buildSectionHeader('Passengers'),
                  const SizedBox(height: 16),

                  // Passenger Selection Widget
                  PassengerSelectionWidget(
                    selectedClient: clientName,
                    onClientChanged: (client) {
                      // Client is already set from auth, no need to change
                    },
                    selectedPassengerIds: tripProvider.selectedPassengerIds,
                    onPassengerToggle: (passengerId) {
                      tripProvider.togglePassengerSelection(passengerId);
                    },
                    onClearAllPassengers: () {
                      tripProvider.clearSelectedPassengers();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Row 9: Notes Textfield
                  Container(
                    height: 120,
                    child: OptLargeTextfield(
                      inputText: 'Add any additional notes here...',
                      controller: tripProvider.noteController,
                      message: true,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (tripProvider.selectedPassengerIds.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Please select at least one passenger'),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            if (tripProvider.tripStartDateTime != null &&
                                tripProvider.tripEndDateTime != null) {
                              final start = tripProvider.tripStartDateTime!;
                              final end = tripProvider.tripEndDateTime!;

                              
                              if (end.isBefore(start)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Trip End Date & Time cannot be before Trip Start Date & Time'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }


                              if (start.year == end.year &&
                                  start.month == end.month &&
                                  start.day == end.day) {
                                final difference = end.difference(start).inMinutes;
                                if (difference < 15) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Trip End Time must be at least 15 minutes after Trip Start Time'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                              }


                              if (tripProvider.shiftStartTime != null) {
                                final shiftDateTime = _combineDateAndShiftTime(
                                  start, // same date
                                  tripProvider.shiftStartTime!, // e.g. "08:30:00"
                                );

                                if (!shiftDateTime.isBefore(start)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Shift Start Time must be strictly before Trip Start Date & Time'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Shift Start Time is required'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                            }

                            tripProvider.submitTripData(clientName!);
                          }




                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: tripProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Request Trip',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  // Helper to build section headers
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Styles.tertiaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 3,
          color: Styles.primaryColor,
        ),
      ],
    );
  }
}
