import 'package:flutter/material.dart';
import '../config/uat_config.dart';

class UATBanner extends StatefulWidget {
  final Widget child;

  const UATBanner({
    super.key,
    required this.child,
  });

  @override
  State<UATBanner> createState() => _UATBannerState();
}

class _UATBannerState extends State<UATBanner> {
  bool _isVisible = UATConfig.showUATBanner;

  @override
  void initState() {
    super.initState();

    // Auto-hide banner if configured
    if (UATConfig.autoHideDuration != null && _isVisible) {
      Future.delayed(UATConfig.autoHideDuration!, () {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If UAT banner is disabled in config, just return the child
    if (!UATConfig.showUATBanner) {
      return widget.child;
    }

    return Stack(
      children: [
        // Add top padding to the child content when banner is visible
        Padding(
          padding: EdgeInsets.only(top: _isVisible ? 50 : 0),
          child: widget.child,
        ),
        // UAT Banner positioned at the top
        if (_isVisible)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              child: Container(
                width: double.infinity,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(UATConfig.primaryColor),
                      Color(UATConfig.secondaryColor),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Show shorter text on smaller screens
                          final isSmallScreen = constraints.maxWidth < 600;
                          return Text(
                            isSmallScreen
                                ? 'UAT v1.0.1 - Testing Only'
                                : 'UAT Testing Environment v1.0.1 - Not for Production Use',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              fontFamily: 'Montserrat',
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.science_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
