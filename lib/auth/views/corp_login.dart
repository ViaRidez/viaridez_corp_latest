import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../../utils/styles.dart';
import '../../widgets/title_logo.dart';
import '../../widgets/opt_textfield.dart';
import '../../widgets/opt_button.dart';
import '../provider/auth_provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          bool isMobile = screenWidth < 600;
          bool isTablet = screenWidth >= 600 && screenWidth < 1024;

          double containerWidth;

          if (isMobile) {
            containerWidth = screenWidth * 0.9;
          } else if (isTablet) {
            containerWidth = screenWidth * 0.6;
          } else {
            containerWidth = screenWidth * 0.25;
          }

          return Stack(children: [
            // OpenStreetMap background centered on Kuwait
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(29.4396, 47.1780), // Kuwait
                initialZoom: 10,
                interactiveFlags: InteractiveFlag.none,
                applyPointerTranslucencyToLayers: false,
              ),
              children: [
                TileLayer(
                  urlTemplate: AppConfig.osmTileUrlWithSubdomain,
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.goridez.corp',
                ),
              ],
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Container(
                  width: containerWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color.fromRGBO(253, 253, 253, 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Center(
                                    child: TitleLogo(),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Corporate Login",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Styles.secondaryColor,
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  OptTextfield(
                                    inputText: "Enter Email",
                                    controller: authProvider.usernameController,
                                    validator: (p0) => p0!.isEmpty
                                        ? "Email cannot be empty"
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  OptTextfield(
                                    inputText: "Enter Password",
                                    isPassword: authProvider.hidePassword,
                                    controller: authProvider.passwordController,
                                    validator: (p0) => p0!.isEmpty
                                        ? "Password cannot be empty"
                                        : null,
                                    suffix: IconButton(
                                      icon: Icon(
                                        authProvider.hidePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        authProvider.togglePasswordVisibility();
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => _showForgotPasswordDialog(context),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                          color: Styles.primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OptButton(
                                text: "Sign In",
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
                                          'Welcome back!',
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
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ]);
        }));
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Gradient header decoration
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Styles.primaryColor.withOpacity(0.1),
                              Styles.secondaryColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Animated Icon
                            Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Styles.primaryColor,
                                            Styles.secondaryColor,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Styles.primaryColor.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.lock_reset_rounded,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Title
                            Text(
                              "Reset Password",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Styles.tertiaryColor,
                                fontFamily: 'Lexend',
                                letterSpacing: 0.3,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Description
                            Text(
                              "Don't worry! It happens. Enter your email address and we'll send you a link to reset your password.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                                fontFamily: 'Lexend',
                                letterSpacing: 0.2,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Email Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email Address",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Styles.tertiaryColor,
                                    fontFamily: 'Lexend',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofocus: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Email is required";
                                    }
                                    if (!value.contains('@')) {
                                      return "Please enter a valid email";
                                    }
                                    return null;
                                  },
                                  style: TextStyle(
                                    color: Styles.tertiaryColor,
                                    fontFamily: 'Lexend',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "your.email@company.com",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontFamily: 'Lexend',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Styles.primaryColor.withOpacity(0.15),
                                            Styles.secondaryColor.withOpacity(0.15),
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.email_outlined,
                                        color: Styles.primaryColor,
                                        size: 22,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 2,
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
                                        width: 2,
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
                            ),

                            const SizedBox(height: 36),

                            // Send Button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: [
                                    Styles.primaryColor,
                                    Styles.secondaryColor,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Styles.primaryColor.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (formKey.currentState!.validate()) {
                                      // TODO: Implement password reset logic
                                      Navigator.of(context).pop();

                                      toastification.show(
                                        context: context,
                                        type: ToastificationType.success,
                                        alignment: Alignment.topCenter,
                                        title: const Text(
                                          'Reset Link Sent!',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                            fontFamily: 'Lexend',
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        description: const Text(
                                          'Please check your email for password reset instructions.',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.teal,
                                            fontFamily: 'Lexend',
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        autoCloseDuration: const Duration(seconds: 4),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Send Reset Link",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Lexend',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Cancel Button
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontFamily: 'Lexend',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
