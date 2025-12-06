import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viaridez_corp/tabs/quotations/views/quotations_view.dart';
import 'package:viaridez_corp/tabs/service_request/views/service_request_view.dart';
import 'package:viaridez_corp/tabs/trips/views/trip_view.dart';
import '../providers/tab_provider.dart';
import '../auth/provider/auth_provider.dart';
import '../tabs/contracts/contracts_view.dart';
import '../tabs/dashboard/views/dashboard_view.dart';
import '../tabs/dashboard/widgets/user_info_card.dart';
import '../tabs/invoices/views/invoices_view.dart';
import '../tabs/invoicing/views/invoicing_view.dart';
import '../tabs/reporting/views/reporting_view.dart';
import '../tabs/routes/view/routes_page.dart';
import '../tabs/staff/view/staff_page.dart';
import '../widgets/title_logo.dart';

// Screen size breakpoints
enum ScreenType { mobile, tablet, desktop }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Track which views have been initialized to prevent unnecessary API calls
  final Set<int> _initializedViews = {};

  // GlobalKey for the Scaffold to control drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize only the first view (Dashboard)
    _initializedViews.add(0);
  }

  // Enhanced screen type detection
  ScreenType _getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenType.mobile;
    } else if (width < 1024) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  // Get sidebar width based on screen type
  double _getSidebarWidth(BuildContext context) {
    final screenType = _getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return MediaQuery.of(context).size.width * 0.85; // 85% on mobile
      case ScreenType.tablet:
        return 280; // Fixed width on tablet
      case ScreenType.desktop:
        return 320; // Larger fixed width on desktop
    }
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.logout, color: Colors.teal),
                  SizedBox(width: 8),
                  Text(
                    'Confirm Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
              content: Text(
                'Are you sure you want to logout?\n\nYou will need to login again to access your account.',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 16,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false (No)
                  },
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Build the sidebar content with responsive design
  Widget _buildSidebarContent() {
    final screenType = _getScreenType(context);
    final isMobile = screenType == ScreenType.mobile;

    return Container(
      width: isMobile ? null : _getSidebarWidth(context),
      decoration: BoxDecoration(
        borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: isMobile
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with responsive padding
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Row(
              children: [
                const Flexible(child: TitleLogo()),
                if (isMobile) ...[
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF35919A),
                      size: 24,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Divider
          Divider(
            color: Colors.grey.shade200,
            thickness: 1,
            height: 1,
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: 16,
              ),
              children: [
                // Dashboard
                _buildTabItem(
                    context, 0, "Dashboard", Icons.dashboard_outlined),
                const SizedBox(height: 8),

                // Staff
                _buildTabItem(context, 1, "Staff", Icons.group_outlined),
                const SizedBox(height: 8),

                // Routes
                _buildTabItem(
                    context, 2, "Routes Report", Icons.route_outlined),
                const SizedBox(height: 8),

                // Trips
                _buildTabItem(
                    context, 3, "Trips", Icons.directions_car_outlined),
                const SizedBox(height: 8),

                // Service Request
                _buildTabItem(context, 4, "Service Request",
                    Icons.miscellaneous_services_outlined),
                const SizedBox(height: 8),

                // Contracts
                _buildTabItem(
                    context, 5, "Contracts", Icons.assignment_outlined),
                const SizedBox(height: 8),

                // Quotations
                _buildTabItem(
                    context, 6, "Quotations", Icons.request_quote_outlined),
                const SizedBox(height: 8),

                // Reports
                _buildTabItem(context, 7, "Reports", Icons.analytics_outlined),
                const SizedBox(height: 8),

                // Invoicing
                _buildTabItem(
                    context, 8, "Invoicing Reports", Icons.receipt_outlined),
                const SizedBox(height: 8),
                _buildTabItem(context, 9, "Invoices", Icons.receipt_rounded),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Bottom section with user profile and logout
          Column(
            children: [
              Divider(
                color: Colors.grey.shade200,
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: 16),
              _buildUserProfile(),
              const SizedBox(height: 16),
              _buildLogoutButton(),
              SizedBox(height: isMobile ? 16 : 24),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced app bar for different screen types
  PreferredSizeWidget? _buildAppBar() {
    final screenType = _getScreenType(context);

    if (screenType == ScreenType.desktop) {
      return null; // No app bar for desktop
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: const Color(0xFF35919A),
          size: screenType == ScreenType.mobile ? 28 : 24,
        ),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        tooltip: 'Open navigation menu',
      ),
      title: const TitleLogo(),
      centerTitle: false,
      actions: [
        // User profile icon for mobile and tablet
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => _showUserProfileDialog(authProvider),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF35919A).withOpacity(0.1),
                  radius: screenType == ScreenType.mobile ? 18 : 20,
                  child: Text(
                    authProvider.username.isNotEmpty
                        ? authProvider.username[0].toUpperCase()
                        : "U",
                    style: TextStyle(
                      color: const Color(0xFF35919A),
                      fontWeight: FontWeight.bold,
                      fontSize: screenType == ScreenType.mobile ? 16 : 18,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Lazy loading method - only builds the currently selected widget
  Widget _buildCurrentView(int index) {
    // Mark this view as initialized
    _initializedViews.add(index);

    switch (index) {
      case 0:
        return const Center(child: DashboardView());
      case 1:
        return const Center(child: StaffPage());
      case 2:
        return const Center(child: RouteTripReportPage());
      case 3:
        return const Center(child: TripView());
      case 4:
        return const Center(child: ServiceRequestView());
      case 5:
        return const Center(child: ContractsView());
      case 6:
        return const Center(child: QuotationsView());
      case 7:
        return const Center(child: ReportingView());
      case 8:
        return const Center(child: InvoicingView());
      case 9:
        return const Center(child: InvoicesView());
      default:
        return const Center(
          child: Text(
            'Page not implemented yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Lexend',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenType = _getScreenType(context);
    final showDrawer = screenType != ScreenType.desktop;

    return WillPopScope(
      onWillPop: () async {
        // Show logout confirmation dialog when back button is pressed
        final shouldLogout = await _showLogoutDialog(context);

        if (shouldLogout) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          await authProvider.logout();

          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/auth',
              (route) => false,
            );
          }
        }

        return false; // Always prevent default back behavior
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color.fromRGBO(253, 253, 253, 1),
        drawer: showDrawer
            ? Drawer(
                backgroundColor: Colors.white,
                width: _getSidebarWidth(context),
                child: _buildSidebarContent(),
              )
            : null,
        appBar: _buildAppBar(),
        body: _buildBody(screenType),
      ),
    );
  }

  Widget _buildBody(ScreenType screenType) {
    final padding = _getBodyPadding(screenType);

    switch (screenType) {
      case ScreenType.desktop:
        // Desktop: Row layout with permanent sidebar
        return Padding(
          padding: padding,
          child: Row(
            children: [
              // Permanent sidebar
              _buildSidebarContent(),
              const SizedBox(width: 24),
              // Main content
              Expanded(child: _buildMainContent()),
            ],
          ),
        );

      case ScreenType.tablet:
      case ScreenType.mobile:
        // Tablet and Mobile: Full width content with drawer
        return Padding(
          padding: padding,
          child: _buildMainContent(),
        );
    }
  }

  EdgeInsets _getBodyPadding(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(8.0);
      case ScreenType.tablet:
        return const EdgeInsets.all(16.0);
      case ScreenType.desktop:
        return const EdgeInsets.all(40.0);
    }
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Consumer<TabProvider>(
          builder: (context, tabProvider, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(0.1, 0.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOut)),
                    ),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey(tabProvider.selectedIndex),
                child: _buildCurrentView(tabProvider.selectedIndex),
              ),
            );
          },
        ),
      ),
    );
  }

  // Enhanced user profile dialog with responsive sizing
  void _showUserProfileDialog(AuthProvider authProvider) {
    final screenType = _getScreenType(context);
    final maxWidth = screenType == ScreenType.mobile
        ? MediaQuery.of(context).size.width * 0.9
        : 500.0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: 700,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF35919A).withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF35919A),
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'User Profile',
                        style: TextStyle(
                          color: Color(0xFF35919A),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF35919A),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              const Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: UserInfoCard(
                    showFullInfo: true,
                    onTap: null, // Disable tap in dialog
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    final screenType = _getScreenType(context);
    final padding = screenType == ScreenType.mobile ? 16.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return InkWell(
            onTap: () => _showUserProfileDialog(authProvider),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF35919A).withOpacity(0.1),
                    radius: 20,
                    child: Text(
                      authProvider.username.isNotEmpty
                          ? authProvider.username[0].toUpperCase()
                          : "U",
                      style: const TextStyle(
                        color: Color(0xFF35919A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.username.isNotEmpty
                              ? authProvider.username
                              : 'Guest',
                          style: const TextStyle(
                            color: Color(0xFF194553),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lexend',
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          authProvider.clientName ?? "Client",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Lexend',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: const Color(0xFF35919A).withOpacity(0.6),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    final screenType = _getScreenType(context);
    final padding = screenType == ScreenType.mobile ? 16.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: const Color(0xFF35919A).withOpacity(0.05),
          onTap: () async {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            await authProvider.logout();

            if (!context.mounted) return;

            Navigator.of(context).pushNamedAndRemoveUntil(
              '/auth',
              (route) => false,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Color(0xFF35919A),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lexend',
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.logout_outlined,
                  color: Color(0xFF35919A),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
      BuildContext context, int index, String title, IconData icon,
      {bool indented = false, bool disabled = false}) {
    final tabProvider = Provider.of<TabProvider>(context);
    final bool isSelected = tabProvider.selectedIndex == index;
    final screenType = _getScreenType(context);

    return Padding(
      padding: EdgeInsets.only(
        left: indented ? 16 : 0,
        bottom: 4,
        right: 8,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: disabled
              ? Colors.transparent
              : const Color(0xFF35919A).withOpacity(0.05),
          splashColor: disabled
              ? Colors.transparent
              : const Color(0xFF35919A).withOpacity(0.1),
          onTap: disabled
              ? null
              : () {
                  tabProvider.selectTab(index);
                  // Close drawer on non-desktop after selection
                  if (screenType != ScreenType.desktop &&
                      _scaffoldKey.currentState?.isDrawerOpen == true) {
                    Navigator.of(context).pop();
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? const Color(0xFF35919A).withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: MouseRegion(
              cursor: disabled
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: disabled
                          ? Colors.grey[400]
                          : isSelected
                              ? const Color(0xFF35919A)
                              : Colors.grey[600],
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: disabled
                              ? Colors.grey[400]
                              : isSelected
                                  ? const Color(0xFF35919A)
                                  : Colors.grey[800],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontFamily: 'Lexend',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
