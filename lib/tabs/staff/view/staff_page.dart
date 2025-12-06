import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../auth/provider/auth_provider.dart';
import '../../../utils/styles.dart';
import '../data/staff_data_grid.dart';
import '../model/staff_modal.dart';
import '../providers/staff_provider.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  StaffDataSource? staffDataSource;
  final TextEditingController _searchController = TextEditingController();

  final List<String> headers = [
    'ID',
    'Username',
    'First Name',
    'Last Name',
    'Email',
    'Phone',
    'Created At',
    'Address',
    'Actions'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStaffData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStaffData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);

    final token = authProvider.token;
    final clientName = authProvider.clientName;

    if (token != null && clientName != null && clientName.isNotEmpty) {
      await staffProvider.fetchStaffByClient(
        clientName: clientName,
        authToken: token,
      );

      // Clear search after refresh
      _searchController.clear();
      staffProvider.searchStaff('');
    }
  }

  // Responsive dialog width calculation
  double _getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return screenWidth * 0.95; // 95% on mobile
    } else if (screenWidth < 1024) {
      return screenWidth * 0.8; // 80% on tablet
    } else {
      return 600; // Fixed width on desktop
    }
  }

  // View details dialog - Made fully responsive
  void _viewStaffDetails(StaffModel staff) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: _getDialogWidth(context),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Responsive Header
              Container(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 16 : 24,
                ),
                decoration: BoxDecoration(
                  color: Styles.primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width < 600 ? 8 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: Styles.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Styles.primaryColor,
                        size: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staff Details',
                            style: TextStyles.cardTitle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Styles.primaryColor,
                              fontSize: MediaQuery.of(context).size.width < 600
                                  ? 16 : 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${staff.firstname} ${staff.lastname}',
                            style: TextStyles.bodyText.copyWith(
                              color: Colors.grey[600],
                              fontSize: MediaQuery.of(context).size.width < 600
                                  ? 12 : 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content - Made responsive
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width < 600 ? 16 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      _buildSectionHeader(
                          'Personal Information', Icons.person_outline),
                      const SizedBox(height: 16),

                      // Responsive layout for personal info
                      MediaQuery.of(context).size.width < 600
                          ? Column(
                        children: [
                          _buildDetailCard("ID", staff.id.toString(), Icons.badge),
                          const SizedBox(height: 12),
                          _buildDetailCard("Username", staff.username, Icons.account_circle),
                          const SizedBox(height: 12),
                          _buildDetailCard("First Name", staff.firstname, Icons.person),
                          const SizedBox(height: 12),
                          _buildDetailCard("Last Name", staff.lastname, Icons.person),
                        ],
                      )
                          : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildDetailCard("ID", staff.id.toString(), Icons.badge)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDetailCard("Username", staff.username, Icons.account_circle)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildDetailCard("First Name", staff.firstname, Icons.person)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDetailCard("Last Name", staff.lastname, Icons.person)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Contact Information Section
                      _buildSectionHeader('Contact Information', Icons.contact_phone_outlined),
                      const SizedBox(height: 16),
                      _buildDetailCard("Email", staff.email, Icons.email_outlined),
                      const SizedBox(height: 16),
                      _buildDetailCard("Phone", staff.phonenumber, Icons.phone_outlined),

                      const SizedBox(height: 24),

                      // Additional Information Section
                      _buildSectionHeader('Additional Information', Icons.info_outline),
                      const SizedBox(height: 16),
                      _buildDetailCard("Created At", _formatDate(staff.createdAt), Icons.calendar_today_outlined),
                      const SizedBox(height: 16),
                      _buildDetailCard("Address", staff.address, Icons.location_on_outlined),
                    ],
                  ),
                ),
              ),

              // Footer Actions - Responsive
              Container(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 16 : 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Styles.primaryColor,
          size: MediaQuery.of(context).size.width < 600 ? 18 : 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyles.formLabel.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
              color: Styles.primaryColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width < 600 ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Styles.primaryColor,
                size: MediaQuery.of(context).size.width < 600 ? 14 : 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyles.formLabel.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyles.inputTextStyle.copyWith(
              fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMainContent(StaffProvider staffProvider) {
    // Loading state
    if (staffProvider.isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Styles.primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading staff data...',
            style: TextStyles.bodyText.copyWith(
              color: Styles.mutedText,
              fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
            ),
          ),
        ],
      );
    }

    // Empty state - no data at all
    if (staffProvider.isEmpty && staffProvider.allStaffList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: MediaQuery.of(context).size.width < 600 ? 60 : 80,
              color: Styles.mutedText,
            ),
            const SizedBox(height: 24),
            Text(
              'No Staff Data Found',
              style: TextStyles.sectionTitle.copyWith(
                fontSize: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                fontWeight: FontWeight.w600,
                color: Styles.mutedText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no staff members available for this client.',
              style: TextStyles.bodyText.copyWith(
                color: Styles.mutedText,
                fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (staffProvider.errorMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 40,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Styles.errorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Styles.errorColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Styles.errorColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        staffProvider.errorMessage!,
                        style: TextStyles.bodyText.copyWith(
                          color: Styles.errorColor,
                          fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _fetchStaffData(),
              icon: const Icon(Icons.refresh),
              label: Text('Try Again', style: TextStyles.primaryButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty search results
    if (staffProvider.filteredStaffList.isEmpty && _searchController.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: MediaQuery.of(context).size.width < 600 ? 60 : 80,
              color: Styles.mutedText,
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: TextStyles.sectionTitle.copyWith(
                fontSize: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                fontWeight: FontWeight.w600,
                color: Styles.mutedText,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No staff members match "${_searchController.text}"',
                style: TextStyles.bodyText.copyWith(
                  color: Styles.mutedText,
                  fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyles.bodyText.copyWith(
                fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 12,
                color: Styles.mutedText,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                staffProvider.searchStaff('');
              },
              icon: const Icon(Icons.clear),
              label: Text('Clear Search', style: TextStyles.secondaryButtonText),
              style: TextButton.styleFrom(
                foregroundColor: Styles.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Data table with horizontal scrolling on mobile
    if (staffProvider.filteredStaffList.isNotEmpty) {
      staffDataSource = StaffDataSource(
        staffList: staffProvider.filteredStaffList,
        onViewDetails: _viewStaffDetails,
        shortenLocation: (address) =>
        address.length > 30 ? '${address.substring(0, 30)}...' : address,
      );

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width < 600
              ? MediaQuery.of(context).size.width * 2 // Make table wider on mobile
              : MediaQuery.of(context).size.width - 48,
          child: SfDataGridTheme(
            data: SfDataGridThemeData(
              headerColor: Styles.lightBackground,
              gridLineColor: Styles.mutedText.withOpacity(0.1),
              gridLineStrokeWidth: 1,
            ),
            child: SfDataGrid(
              allowSorting: true,
              allowFiltering: true,
              allowColumnsResizing: true,
              isScrollbarAlwaysShown: true,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              selectionMode: SelectionMode.single,
              headerRowHeight: MediaQuery.of(context).size.width < 600 ? 45 : 50,
              rowHeight: MediaQuery.of(context).size.width < 600 ? 42 : 48,
              source: staffDataSource!,
              columns: getColumns(),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  List<GridColumn> getColumns() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final columnWidth = isSmallScreen ? 120.0 : MediaQuery.of(context).size.width / headers.length;

    return headers.map((title) {
      // On mobile, hide some columns to prevent overflow
      bool isVisible = true;
      if (isSmallScreen) {
        isVisible = !(title == 'Created At' || title == 'Address' || title == 'ID');
      } else {
        isVisible = !(title == 'Created At' || title == 'Address');
      }

      return GridColumn(
        columnName: title.toLowerCase().replaceAll(' ', ''),
        width: columnWidth,
        visible: isVisible,
        label: Container(
          alignment: Alignment.centerLeft,
          color: Styles.lightBackground,
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            style: TextStyles.formLabel.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();
  }

  // Build responsive header section
  Widget _buildResponsiveHeader(StaffProvider staffProvider) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            "Staff Management",
            style: TextStyles.pageTitle.copyWith(
              fontSize: isSmallScreen ? 20 : (isTablet ? 24 : 28),
              color: Styles.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            height: 3,
            width: isSmallScreen ? 40 : 60,
            color: Styles.primaryColor,
          ),

          // Search and Actions - Responsive Layout
          isSmallScreen
              ? Column(
            children: [
              // Search bar (full width on mobile)
              _buildSearchBar(),
              const SizedBox(height: 12),

              // Counter and refresh button row
              Row(
                children: [
                  Expanded(child: _buildResultCounter(staffProvider)),
                  const SizedBox(width: 12),
                  _buildRefreshButton(),
                ],
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                flex: isTablet ? 2 : 3,
                child: _buildSearchBar(),
              ),
              const SizedBox(width: 16),
              _buildResultCounter(staffProvider),
              const SizedBox(width: 16),
              _buildRefreshButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Styles.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Styles.primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: MediaQuery.of(context).size.width < 600
              ? 'Search staff...'
              : 'Search by name, email, phone, username...',
          hintStyle: TextStyles.inputLabelStyle.copyWith(
            color: Styles.mutedText,
            fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Styles.primaryColor,
            size: MediaQuery.of(context).size.width < 600 ? 18 : 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: Styles.primaryColor,
              size: MediaQuery.of(context).size.width < 600 ? 16 : 18,
            ),
            onPressed: () {
              _searchController.clear();
              Provider.of<StaffProvider>(context, listen: false).searchStaff('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          Provider.of<StaffProvider>(context, listen: false).searchStaff(value);
        },
      ),
    );
  }

  Widget _buildResultCounter(StaffProvider staffProvider) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Styles.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Styles.primaryColor.withOpacity(0.2)),
      ),
      child: Text(
        '${staffProvider.filteredStaffList.length} of ${staffProvider.allStaffList.length}',
        style: TextStyles.dataLabel.copyWith(
          color: Styles.primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 12,
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          _searchController.clear();
          _fetchStaffData();
        },
        icon: Icon(
          Icons.refresh,
          size: MediaQuery.of(context).size.width < 600 ? 16 : 18,
          color: Colors.white,
        ),
        label: Text(
          MediaQuery.of(context).size.width < 600 ? '' : 'Refresh',
          style: TextStyles.primaryButtonText.copyWith(
            fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Styles.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size(
            MediaQuery.of(context).size.width < 600 ? 40 : 100,
            40,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.white,
      body: Consumer<StaffProvider>(
        builder: (context, staffProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive Header Section
              _buildResponsiveHeader(staffProvider),

              // Content Area with proper responsive handling
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width < 600 ? 16 : 24,
                  ),
                  child: staffProvider.filteredStaffList.isNotEmpty
                      ? _buildMainContent(staffProvider)
                      : Center(child: _buildMainContent(staffProvider)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
