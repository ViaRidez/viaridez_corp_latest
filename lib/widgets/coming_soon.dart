import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/styles.dart';

class ComingSoon extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final String? description;
  final VoidCallback? onNotifyMe;

  const ComingSoon({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.onNotifyMe,
  });

  @override
  State<ComingSoon> createState() => _ComingSoonState();
}

class _ComingSoonState extends State<ComingSoon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       Styles.lightBackground,
        //       Styles.white,
        //     ],
        //   ),
        // ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SVG Illustration
                        Container(
                          height: 300,
                          width: 400,
                          margin: const EdgeInsets.only(bottom: 40),
                          child: SvgPicture.asset(
                            'assets/coming_soon.svg',
                            fit: BoxFit.contain,
                            placeholderBuilder: (context) => Container(
                              decoration: BoxDecoration(
                                color: Styles.lightBackground,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.access_time_rounded,
                                size: 100,
                                color: Styles.primaryColor.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),

                        // Main Title
                        Text(
                          widget.title ?? 'Coming Soon',
                          style: TextStyles.pageTitle.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Styles.primaryColor,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        if (widget.subtitle != null) ...[
                          Text(
                            widget.subtitle!,
                            style: TextStyles.sectionTitle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Styles.secondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Description
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Text(
                            widget.description ??
                                'We\'re working hard to bring you something amazing. This feature will be available soon!',
                            style: TextStyles.bodyText.copyWith(
                              fontSize: 16,
                              height: 1.6,
                              color: Styles.mutedText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Action Button
                        if (widget.onNotifyMe != null) ...[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Styles.primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: widget.onNotifyMe,
                              icon: const Icon(Icons.notifications_outlined,
                                  size: 20),
                              label: Text(
                                'Notify Me',
                                style: TextStyles.primaryButtonText.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 60),

                        // Progress Indicator (Animated dots)
                        _buildAnimatedDots(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return SizedBox(
      width: 80,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.2;
              final animation = Tween<double>(
                begin: 0.3,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  delay,
                  delay + 0.4,
                  curve: Curves.easeInOut,
                ),
              ));

              return Transform.scale(
                scale: animation.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Styles.primaryColor.withOpacity(animation.value),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
