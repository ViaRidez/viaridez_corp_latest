import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../../../auth/provider/auth_provider.dart';
import '../../../../utils/styles.dart';
import '../../../../widgets/location_picker.dart';
import '../api/route_request_service.dart';
import '../providers/route_request_provider.dart';

class RouteRequestView extends StatefulWidget {
  const RouteRequestView({super.key});

  @override
  State<RouteRequestView> createState() => _RouteRequestViewState();
}

class _RouteRequestViewState extends State<RouteRequestView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Map related variables
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(29.3117, 47.4818);
  LatLng? _startPosition;
  LatLng? _endPosition;
  String? clientName;

  @override
  void initState() {
    super.initState();
    _updateMapPositions();
    _fetchClientName();
  }

  void _fetchClientName() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    clientName = authProvider.clientName;
  }

  void _updateMapIfNeeded() {
    if (_startPosition != null && _endPosition != null) {
      // Find bounds that include both positions
      final bounds = LatLngBounds(
          _startPosition!, _startPosition!); // Initialize with same point
      bounds.extend(_endPosition!); // Then extend with the second point

      // Add some padding around the markers
      _mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
      );
    } else if (_startPosition != null) {
      _mapController.move(_startPosition!, 13.0);
    } else if (_endPosition != null) {
      _mapController.move(_endPosition!, 13.0);
    }
    setState(() {}); // Refresh UI to update markers
  }

  void _updateMapPositions() {
    final provider = Provider.of<RouteRequestProvider>(context, listen: false);

    // Update start position if coordinates are available
    if (provider.startLatController.text.isNotEmpty &&
        provider.startLngController.text.isNotEmpty) {
      try {
        _startPosition = LatLng(
          double.parse(provider.startLatController.text),
          double.parse(provider.startLngController.text),
        );
      } catch (e) {
        _startPosition = null;
      }
    }

    // Update end position if coordinates are available
    if (provider.endLatController.text.isNotEmpty &&
        provider.endLngController.text.isNotEmpty) {
      try {
        _endPosition = LatLng(
          double.parse(provider.endLatController.text),
          double.parse(provider.endLngController.text),
        );
      } catch (e) {
        _endPosition = null;
      }
    }
  }

  void _resetForm() {
    final provider = Provider.of<RouteRequestProvider>(context, listen: false);
    provider.resetForm();
    setState(() {
      _startPosition = null;
      _endPosition = null;
    });
  }

  Future<void> _downloadSampleExcel() async {
    setState(() => _isLoading = true);

    try {
      // Load the Excel file from assets
      final ByteData data =
          await rootBundle.load('assets/excels/sample_pitstops.xlsx');
      final bytes = data.buffer.asUint8List();

      // Create a blob and download link
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create and trigger download
      html.AnchorElement(href: url)
        ..setAttribute('download', 'sample_pitstops.xlsx')
        ..click();

      // Clean up
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        toastification.show(
          context: context,
          title: const Text('Success!'),
          description: const Text('Sample Excel file downloaded successfully'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to download sample Excel: $e',
              style: TextStyles.snackbarText,
            ),
            backgroundColor: Styles.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteRequestProvider>(
      builder: (context, provider, child) {
        return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header

                Row(
                  children: [
                    Text("Route Type:", style: TextStyles.formLabel),
                    const SizedBox(width: 16),
                    Radio<String>(
                      value: 'outbound',
                      groupValue: provider.routeType,
                      onChanged: (value) => provider.setRouteType(value!),
                      activeColor: Styles.primaryColor,
                    ),
                    const Text('Outbound'),
                    const SizedBox(width: 16),
                    Radio<String>(
                      value: 'inbound',
                      groupValue: provider.routeType,
                      onChanged: (value) => provider.setRouteType(value!),
                      activeColor: Styles.primaryColor,
                    ),
                    const Text('Inbound'),
                  ],
                ),
                const SizedBox(height: 16),

                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Start Destination
                        Text("Start Destination",
                            style: TextStyles.sectionTitle),
                        const SizedBox(height: 8),
                        _buildDestinationFields(
                          provider.startNameController,
                          provider.startLatController,
                          provider.startLngController,
                        ),
                        const SizedBox(height: 16),

                        // End Destination
                        Text("End Destination", style: TextStyles.sectionTitle),
                        const SizedBox(height: 8),
                        _buildDestinationFields(
                          provider.endNameController,
                          provider.endLatController,
                          provider.endLngController,
                        ),
                        const SizedBox(height: 16),

                        // Map Preview
                        Text("Route Preview", style: TextStyles.sectionTitle),
                        const SizedBox(height: 8),
                        _buildMapWidget(),
                        const SizedBox(height: 16),

                        // Excel Upload Section
                        Text("Pitstops Excel File",
                            style: TextStyles.sectionTitle),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Styles.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Styles.primaryColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          provider.pitstopsFileController,
                                      decoration: InputDecoration(
                                        labelText: 'Selected File',
                                        labelStyle: TextStyles.inputLabelStyle,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Styles.primaryColor),
                                        ),
                                        suffixIcon:
                                            provider.pitstopsExcelFile != null
                                                ? IconButton(
                                                    icon: Icon(Icons.clear,
                                                        color: Styles
                                                            .tertiaryColor),
                                                    onPressed:
                                                        provider.clearExcelFile,
                                                  )
                                                : null,
                                      ),
                                      readOnly: true,
                                      validator: (value) {
                                        if (provider.pitstopsExcelFile ==
                                            null) {
                                          return 'Please select an Excel file';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed:
                                        (provider.isLoading || _isLoading)
                                            ? null
                                            : provider.pickExcelFile,
                                    icon: (provider.isLoading || _isLoading)
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.upload_file,
                                            color: Colors.white,
                                          ),
                                    label: Text(
                                      'Browse',
                                      style:
                                          TextStyles.primaryButtonText.copyWith(
                                        color:
                                            (provider.isLoading || _isLoading)
                                                ? Colors.white70
                                                : Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (provider.isLoading ||
                                              _isLoading)
                                          ? Styles.primaryColor.withOpacity(0.6)
                                          : Styles.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Upload an Excel file containing pitstop information with columns: Name, Latitude, Longitude',
                                style: TextStyles.hintText,
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: (_isLoading || provider.isLoading)
                                    ? null
                                    : _downloadSampleExcel,
                                icon: (_isLoading || provider.isLoading)
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Styles.primaryColor),
                                        ),
                                      )
                                    : Icon(Icons.download,
                                        color: Styles.primaryColor),
                                label: Text(
                                  'Download Sample Excel',
                                  style:
                                      TextStyles.secondaryButtonText.copyWith(
                                    color: (_isLoading || provider.isLoading)
                                        ? Styles.mutedText
                                        : Styles.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: (_isLoading || provider.isLoading)
                                    ? null
                                    : _resetForm,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Styles.tertiaryColor,
                                  side: BorderSide(color: Styles.tertiaryColor),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('Cancel',
                                    style: TextStyles.secondaryButtonText),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: (_isLoading || provider.isLoading)
                                    ? null
                                    : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Styles.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: (_isLoading || provider.isLoading)
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text('Request Route',
                                        style: TextStyles.primaryButtonText),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinationFields(
    TextEditingController nameController,
    TextEditingController latController,
    TextEditingController lngController,
  ) {
    return Column(
      children: [
        // Location Picker - replaces manual input and map button
        LocationPicker(
          label: 'Destination',
          controller: nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a destination';
            }
            return null;
          },
          enabled: !_isLoading,
          onCoordinatesSelected: (lat, lng) {
            setState(() {
              latController.text = lat.toString();
              lngController.text = lng.toString();
              _updateMapPositions();
              _updateMapIfNeeded();
            });
          },
        ),
        const SizedBox(height: 12),

        // Coordinates row (Read-only display)
        Row(
          children: [
            // Latitude field
            Expanded(
              child: TextFormField(
                controller: latController,
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  labelStyle: TextStyles.inputLabelStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Styles.primaryColor),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),

            // Longitude field
            Expanded(
              child: TextFormField(
                controller: lngController,
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  labelStyle: TextStyles.inputLabelStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Styles.primaryColor),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapWidget() {
    List<Marker> markers = [];

    // Add start marker
    if (_startPosition != null) {
      markers.add(
        Marker(
          point: _startPosition!,
          width: 80,
          height: 80,
          child: Column(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.green[700],
                size: 30,
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  'Start',
                  style: TextStyles.dataLabel.copyWith(
                    color: Styles.tertiaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add end marker
    if (_endPosition != null) {
      markers.add(
        Marker(
          point: _endPosition!,
          width: 80,
          height: 80,
          child: Column(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.red[700],
                size: 30,
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  'End',
                  style: TextStyles.dataLabel.copyWith(
                    color: Styles.tertiaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _startPosition ?? _endPosition ?? _defaultCenter,
            zoom: 13.0,
            interactiveFlags: InteractiveFlag.all,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.viaridez.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final provider = Provider.of<RouteRequestProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      if (provider.pitstopsExcelFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please upload a pitstops Excel file',
              style: TextStyles.snackbarText,
            ),
            backgroundColor: Styles.errorColor,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final result = await provider.submitRoute(clientName: clientName);

        if (mounted) {
          setState(() => _isLoading = false);

          if (result == RouteAddResult.success) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 2),
              title: const Text('Route Added Successfully'),
              description:
                  const Text('The route has been added to the system.'),
            );

            // Refresh route list
            await provider.fetchRoutes();

            // Reset form
            provider.resetForm();
            setState(() {
              _startPosition = null;
              _endPosition = null;
            });
          } else if (result == RouteAddResult.connectionError) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 2),
              title: const Text('Connection Error'),
              description: const Text('Please check your network connection.'),
            );
          } else {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 2),
              title: const Text('Error'),
              description: const Text('Failed to add route. Please try again.'),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error submitting route: $e',
                style: TextStyles.snackbarText,
              ),
              backgroundColor: Styles.errorColor,
            ),
          );
        }
      }
    }
  }
}
