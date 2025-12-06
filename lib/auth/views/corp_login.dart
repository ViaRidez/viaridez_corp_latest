import '../../utils/styles.dart';
import '../../widgets/opt_button.dart';
import '../../widgets/opt_textfield.dart';
import '../../widgets/title_logo.dart';
import '../provider/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(body: LayoutBuilder(builder: (context, constraints) {
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
              applyPointerTranslucencyToLayers: false),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.app',
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
                child: Form(
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
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return OptTextfield(
                                inputText: "Enter Email",
                                controller: authProvider.usernameController,
                                validator: (p0) => p0!.isEmpty
                                    ? "Email cannot be empty"
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return OptTextfield(
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
                              );
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                      fontFamily: 'Lexend', color: Colors.grey),
                                )),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return OptButton(
                            text: "Submit",
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
                                        // Navigate to home page using named route
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/homepage',
                                        );
                                      } else if (authProvider.errorMessage !=
                                          null) {
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]);
    }));
  }
}
