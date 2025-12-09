import '../../utils/styles.dart';
import '../../widgets/opt_button.dart';
import '../../widgets/opt_textfield.dart';
import '../../widgets/title_logo.dart';
import '../provider/auth_provider.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          bool isMobile = screenWidth < 600;
          bool isTablet = screenWidth >= 600 && screenWidth < 1024;

          double containerWidth;

          if (isMobile) {
            containerWidth = screenWidth * 0.92;
          } else if (isTablet) {
            containerWidth = screenWidth * 0.65;
          } else {
            containerWidth = 450;
          }

          return Stack(
            children: [
              // OpenStreetMap background
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(29.4396, 47.1780),
                  initialZoom: 10,
                  interactiveFlags: InteractiveFlag.none,
                  applyPointerTranslucencyToLayers: false,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.app',
                  ),
                ],
              ),
              
              // Subtle overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
              
              // Login Card
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 20 : 40,
                    horizontal: isMobile ? 16 : 0,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildLoginCard(
                        context,
                        formKey,
                        containerWidth,
                        isMobile,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginCard(
    BuildContext context,
    GlobalKey<FormState> formKey,
    double containerWidth,
    bool isMobile,
  ) {
    return Container(
      width: containerWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 28.0 : 48.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: child,
                      ),
                    );
                  },
                  child: const TitleLogo(),
                ),
              ),
              
              SizedBox(height: isMobile ? 28 : 36),
              
              // Title
              Text(
                "Corporate Login",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 26 : 30,
                  fontWeight: FontWeight.w700,
                  color: Styles.secondaryColor,
                  fontFamily: 'Lexend',
                  letterSpacing: 0.3,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                "Welcome back! Please login to continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  fontFamily: 'Lexend',
                  letterSpacing: 0.2,
                ),
              ),
              
              SizedBox(height: isMobile ? 32 : 40),
              
              // Email Field
              _buildAnimatedField(
                delay: 100,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return _buildTextField(
                      label: "Email Address",
                      hint: "Enter your email",
                      controller: authProvider.usernameController,
                      validator: (p0) => p0!.isEmpty
                          ? "Email cannot be empty"
                          : null,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Password Field
              _buildAnimatedField(
                delay: 200,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return _buildTextField(
                      label: "Password",
                      hint: "Enter your password",
                      isPassword: authProvider.hidePassword,
                      controller: authProvider.passwordController,
                      validator: (p0) => p0!.isEmpty
                          ? "Password cannot be empty"
                          : null,
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          authProvider.hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[600],
                          size: 22,
                        ),
                        onPressed: () {
                          authProvider.togglePasswordVisibility();
                        },
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Forgot Password
              _buildAnimatedField(
                delay: 300,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        color: Styles.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: isMobile ? 24 : 32),
              
              // Submit Button
              _buildAnimatedField(
                delay: 400,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return _buildSignInButton(
                      context: context,
                      isLoading: authProvider.isLoading,
                      onTap: authProvider.isLoading
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                await authProvider.login();

                                if (!context.mounted) return;

                                if (authProvider.isLoggedIn) {
                                  toastification.show(
                                    context: context,
                                    type: ToastificationType.success,
                                    alignment: Alignment.topCenter,
                                    title: const Text(
                                      'Login Successful',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                        fontFamily: 'Lexend',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    description: const Text(
                                      'Welcome!',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.teal,
                                        fontFamily: 'Lexend',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    autoCloseDuration:
                                        const Duration(seconds: 2),
                                  );
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/homepage',
                                  );
                                } else if (authProvider.errorMessage != null) {
                                  toastification.show(
                                    context: context,
                                    type: ToastificationType.error,
                                    alignment: Alignment.topCenter,
                                    title: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                        fontFamily: 'Lexend',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    description: const Text(
                                      'Please try again.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.redAccent,
                                        fontFamily: 'Lexend',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    autoCloseDuration:
                                        const Duration(seconds: 2),
                                  );
                                }
                              }
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField({
    required int delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController? controller,
    required String? Function(String?)? validator,
    required IconData icon,
    bool isPassword = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Styles.tertiaryColor,
            fontFamily: 'Lexend',
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          keyboardType: keyboardType,
          style: TextStyle(
            color: Styles.tertiaryColor,
            fontFamily: 'Lexend',
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontFamily: 'Lexend',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: Styles.primaryColor,
              size: 20,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Styles.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontFamily: 'Lexend',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton({
    required BuildContext context,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Styles.primaryColor,
                Styles.secondaryColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Styles.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            height: 54,
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lexend',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
