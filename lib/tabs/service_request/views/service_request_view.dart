import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viaridez_corp/tabs/service_request/request_route/views/route_request_view.dart';
import 'package:viaridez_corp/tabs/service_request/request_trip/views/trip_request_view.dart';

import '../../../providers/tab_provider.dart';
import '../../../utils/styles.dart';
import '../request_route/views/route_requested_view.dart';
import '../request_trip/views/trip_requested_view.dart';

class ServiceRequestView extends StatelessWidget {
  const ServiceRequestView({super.key});

  void _showRouteRequestForm(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
        ),
        child: SizedBox(
          width: _getDialogWidth(screenWidth),
          height: _getDialogHeight(screenWidth, context),
          child: Column(
            children: [
              // Title bar
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : 20,
                  vertical: isWeb ? 20 : 16,
                ),
                decoration: BoxDecoration(
                  color: Styles.primaryColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isWeb ? 20 : 16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_road,
                      color: Colors.white,
                      size: isWeb ? 24 : 20,
                    ),
                    SizedBox(width: isWeb ? 12 : 10),
                    Text(
                      "Request New Route",
                      style: TextStyle(
                        fontSize: _getDialogTitleFontSize(screenWidth),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: isWeb ? 24 : 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              const Expanded(
                child: RouteRequestView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTripRequestForm(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 1200;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
        ),
        child: SizedBox(
          width: _getDialogWidth(screenWidth),
          height: _getDialogHeight(screenWidth, context),
          child: Column(
            children: [
              // Title bar
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24 : 20,
                  vertical: isWeb ? 20 : 16,
                ),
                decoration: BoxDecoration(
                  color: Styles.primaryColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isWeb ? 20 : 16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: isWeb ? 24 : 20,
                    ),
                    SizedBox(width: isWeb ? 12 : 10),
                    Text(
                      "Request New Trip",
                      style: TextStyle(
                        fontSize: _getDialogTitleFontSize(screenWidth),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: isWeb ? 24 : 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              const Expanded(
                child: TripRequestView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isWeb = screenWidth > 1200;
        final isTablet = screenWidth > 768 && screenWidth <= 1200;
        final isMobile = screenWidth <= 768;

        // Responsive padding and spacing
        final horizontalPadding = _getHorizontalPadding(screenWidth);
        final verticalPadding = _getVerticalPadding(screenWidth);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
              color: const Color.fromRGBO(253, 253, 253, 1),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.5),
                  blurRadius: isWeb ? 15 : 10,
                  spreadRadius: isWeb ? 0 : -1,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                children: [
                  // Responsive Tabs
                  Consumer<TabProvider>(
                    builder: (context, tabProvider, child) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: isWeb ? 24.0 : 16.0,
                        ),
                        child: _buildResponsiveTabs(
                          context,
                          tabProvider,
                          screenWidth,
                          isWeb,
                          isTablet,
                          isMobile,
                        ),
                      );
                    },
                  ),
                  // Content Area
                  Expanded(
                    child: Consumer<TabProvider>(
                      builder: (context, tabProvider, child) {
                        return Container(
                          width: double.infinity,
                          child: IndexedStack(
                            index: tabProvider.serviceRequestSelectionIndex,
                            children: const [
                              RouteRequestedView(),
                              TripRequestedView(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Consumer<TabProvider>(
            builder: (context, tabProvider, child) {
              return _buildResponsiveFAB(
                context,
                tabProvider,
                screenWidth,
                isWeb,
                isMobile,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResponsiveTabs(
      BuildContext context,
      TabProvider tabProvider,
      double screenWidth,
      bool isWeb,
      bool isTablet,
      bool isMobile,
      ) {
    final List<String> tabs = [
      'Requested Routes',
      'Request Trips',
    ];

    // For very small mobile screens, use vertical layout
    if (screenWidth < 400) {
      return Column(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: _buildTab(
                  context,
                  tabProvider,
                  i,
                  tabs[i],
                  screenWidth,
                  isVertical: true,
                ),
              ),
            ),
        ],
      );
    }

    // For all other screen sizes, use horizontal layout
    return Row(
      mainAxisAlignment: isWeb
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.center,
      children: [
        for (int i = 0; i < tabs.length; i++) ...[
          if (i > 0) SizedBox(width: _getTabSpacing(screenWidth)),
          Expanded(
            child: _buildTab(
              context,
              tabProvider,
              i,
              tabs[i],
              screenWidth,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTab(
      BuildContext context,
      TabProvider tabProvider,
      int index,
      String title,
      double screenWidth, {
        bool isVertical = false,
      }) {
    final bool isSelected = tabProvider.serviceRequestSelectionIndex == index;
    final bool isWeb = screenWidth > 1200;
    final bool isTablet = screenWidth > 768 && screenWidth <= 1200;
    final bool isMobile = screenWidth <= 768;

    // Responsive font size
    double fontSize = _getFontSize(screenWidth);

    // Responsive padding
    EdgeInsets padding = _getTabPadding(screenWidth, isVertical);

    // Responsive border radius
    double borderRadius = isWeb ? 50 : (isTablet ? 40 : 30);

    return InkWell(
      onTap: () {
        tabProvider.selectServiceRequestTab(index);
      },
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: isVertical ? double.infinity : null,
        constraints: BoxConstraints(
          minWidth: isMobile ? 0 : 120,
          minHeight: _getMinTabHeight(screenWidth),
        ),
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? Styles.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Styles.primaryColor,
            width: isWeb ? 2 : 1,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Styles.primaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontFamily: 'Montserrat',
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveFAB(
      BuildContext context,
      TabProvider tabProvider,
      double screenWidth,
      bool isWeb,
      bool isMobile,
      ) {
    final fabPadding = isWeb
        ? const EdgeInsets.all(16)
        : const EdgeInsets.all(12);

    final fabTextStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontFamily: 'Montserrat',
      fontSize: isMobile ? 14 : 16,
    );

    if (tabProvider.serviceRequestSelectionIndex == 0) {
      // Requested Routes tab
      return FloatingActionButton.extended(
        onPressed: () => _showRouteRequestForm(context),
        backgroundColor: Styles.primaryColor,
        foregroundColor: Colors.white,
        icon: Icon(
          Icons.add_road,
          size: isMobile ? 20 : 24,
        ),
        label: Text(
          'Request Route',
          style: fabTextStyle,
        ),
        extendedPadding: fabPadding,
      );
    } else if (tabProvider.serviceRequestSelectionIndex == 1) {
      // Request Journey tab
      return FloatingActionButton.extended(
        onPressed: () => _showTripRequestForm(context),
        backgroundColor: Styles.primaryColor,
        foregroundColor: Colors.white,
        icon: Icon(
          Icons.directions_bus,
          size: isMobile ? 20 : 24,
        ),
        label: Text(
          'Request Trip',
          style: fabTextStyle,
        ),
        extendedPadding: fabPadding,
      );
    }
    return const SizedBox.shrink();
  }

  // Helper methods for responsive values
  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 1200) return 48.0; // Web
    if (screenWidth > 768) return 32.0;  // Tablet
    if (screenWidth > 400) return 24.0;  // Large mobile
    return 16.0; // Small mobile
  }

  double _getVerticalPadding(double screenWidth) {
    if (screenWidth > 1200) return 40.0; // Web
    if (screenWidth > 768) return 32.0;  // Tablet
    return 24.0; // Mobile
  }

  double _getTabSpacing(double screenWidth) {
    if (screenWidth > 1200) return 24.0; // Web
    if (screenWidth > 768) return 20.0;  // Tablet
    if (screenWidth > 400) return 16.0;  // Large mobile
    return 12.0; // Small mobile
  }

  double _getFontSize(double screenWidth) {
    if (screenWidth > 1200) return 18.0; // Web
    if (screenWidth > 768) return 16.0;  // Tablet
    if (screenWidth > 400) return 15.0;  // Large mobile
    return 14.0; // Small mobile
  }

  EdgeInsets _getTabPadding(double screenWidth, bool isVertical) {
    if (screenWidth > 1200) {
      return const EdgeInsets.symmetric(vertical: 14, horizontal: 24);
    }
    if (screenWidth > 768) {
      return const EdgeInsets.symmetric(vertical: 12, horizontal: 20);
    }
    if (screenWidth > 400) {
      return isVertical
          ? const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
          : const EdgeInsets.symmetric(vertical: 10, horizontal: 16);
    }
    return isVertical
        ? const EdgeInsets.symmetric(vertical: 10, horizontal: 12)
        : const EdgeInsets.symmetric(vertical: 8, horizontal: 12);
  }

  double _getMinTabHeight(double screenWidth) {
    if (screenWidth > 1200) return 50.0; // Web
    if (screenWidth > 768) return 45.0;  // Tablet
    if (screenWidth > 400) return 40.0;  // Large mobile
    return 36.0; // Small mobile
  }

  // Dialog responsive helper methods
  double _getDialogWidth(double screenWidth) {
    if (screenWidth > 1200) return screenWidth * 0.6; // Web
    if (screenWidth > 768) return screenWidth * 0.8;  // Tablet
    return screenWidth * 0.95; // Mobile
  }

  double _getDialogHeight(double screenWidth, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth > 1200) return screenHeight * 0.8; // Web
    if (screenWidth > 768) return screenHeight * 0.85; // Tablet
    return screenHeight * 0.9; // Mobile
  }

  double _getDialogTitleFontSize(double screenWidth) {
    if (screenWidth > 1200) return 20.0; // Web
    if (screenWidth > 768) return 19.0;  // Tablet
    return 18.0; // Mobile
  }
}
