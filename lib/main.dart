import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:viaridez_corp/tabs/service_request/request_trip/services/pax_provider.dart';

import 'auth/provider/auth_provider.dart';
import 'auth/views/corp_login.dart';
import 'providers/tab_provider.dart';
import 'tabs/contracts/providers/contract_provider.dart';
import 'tabs/dashboard/providers/dashboard_provider.dart';
import 'tabs/invoices/providers/invoices_provider.dart';
import 'tabs/invoicing/providers/invoicing_provider.dart';
import 'tabs/quotations/providers/quotations_provider.dart';
import 'tabs/routes/providers/route_provider.dart';
import 'tabs/service_request/request_route/providers/route_request_provider.dart';
import 'tabs/service_request/request_route/providers/route_requested_provider.dart';
import 'tabs/service_request/request_trip/providers/trip_request_provider.dart';
import 'tabs/service_request/request_trip/providers/route_provider.dart'
    as TripRouteProvider;
import 'tabs/service_request/request_trip/providers/trip_requested_provider.dart';
import 'tabs/staff/providers/staff_provider.dart';
import 'tabs/trips/providers/trip_provider.dart';
import 'views/home_page.dart';
import 'widgets/uat_banner.dart';

void setupLogging() {
  Dio dio = Dio();
  dio.interceptors.add(LogInterceptor(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
  ));
}

void main() async {
  setupLogging();
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // await ChatNotificationService.initialize();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => DashboardProvider()),
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => TabProvider()),
      ChangeNotifierProvider(create: (context) => StaffProvider()),
      ChangeNotifierProvider(create: (context) => RouteTripProvider()),
      ChangeNotifierProvider(create: (context) => TripProvider()),
      ChangeNotifierProvider(create: (context) => RouteRequestProvider()),
      ChangeNotifierProvider(create: (context) => TripRequestProvider()),
      ChangeNotifierProvider(create: (context) => PaxProvider()),
      ChangeNotifierProvider(
          create: (context) => TripRouteProvider.RouteProvider()),
      ChangeNotifierProvider(create: (context) => QuotationsProvider()),
      ChangeNotifierProvider(create: (context) => RouteRequestedProvider()),
      ChangeNotifierProvider(create: (context) => TripRequestedProvider()),
      ChangeNotifierProvider(create: (context) => ContractProvider()),
      ChangeNotifierProvider(create: (context) => InvoicingProvider()),
      ChangeNotifierProvider(create: (context) => InvoicesProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Helper method to wrap pages with UAT banner
  Widget _wrapWithUATBanner(Widget page) {
    return UATBanner(child: page);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet Management',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => _wrapWithUATBanner(const SplashPage()),
        '/auth': (context) => _wrapWithUATBanner(const AuthScreen()),
        '/homepage': (context) =>
            _wrapWithUATBanner(ProtectedRoute(child: const HomePage())),
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for the auth provider to initialize
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait a bit more for the auth initialization to complete
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    if (authProvider.isFullyAuthenticated) {
      // User is already logged in, navigate to home page
      Navigator.of(context).pushReplacementNamed('/homepage');
    } else {
      // User is not logged in, navigate to auth screen
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading indicator while checking auth status
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/auth');
          });
          return const SizedBox.shrink();
        }
        return child;
      },
    );
  }
}
