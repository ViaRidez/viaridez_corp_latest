import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/dashboard_service.dart';
import '../../../../utils/styles.dart';
import '../../../../auth/provider/auth_provider.dart';
import '../../../../auth/api/secure_tokens.dart';

class UserInfoCard extends StatefulWidget {
  final VoidCallback? onTap;
  final bool showFullInfo;

  const UserInfoCard({
    super.key,
    this.onTap,
    this.showFullInfo = true,
  });

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  final DashboardService _dashboardService = DashboardService();
  UserInfo? _userInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userInfo = await _dashboardService.getUserInfo();
      if (mounted) {
        setState(() {
          _userInfo = userInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Check if error is related to missing Keycloak user ID
      final errorString = e.toString();
      if (errorString.contains('Keycloak user ID not found') ||
          errorString.contains('secure storage') ||
          errorString.contains('not found in tokens')) {
        // Critical authentication error - logout and redirect
        await _handleAuthenticationError();
      } else if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAuthenticationError() async {
    // Clear secure storage
    await deleteTokens();

    if (!mounted) return;

    // Get auth provider and logout
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;

    // Show dialog informing user
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Styles.errorColor),
              const SizedBox(width: 8),
              const Text(
                'Session Expired',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          content: const Text(
            'Your session has expired or authentication data is missing. Please login again to continue.',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 16,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Login Again',
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
    );

    if (!mounted) return;

    // Navigate to auth page
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/auth',
      (route) => false,
    );
  }

  Future<void> _refreshUserInfo() async {
    await _loadUserInfo();
  }

  void _showUserProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Styles.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 700,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Styles.primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      color: Styles.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'User Profile',
                      style: TextStyles.pageTitle.copyWith(
                        color: Styles.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Styles.primaryColor,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Styles.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ??
          (widget.showFullInfo ? null : () => _showUserProfileDialog(context)),
      child: Container(
        decoration: BoxDecoration(
          color: Styles.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Styles.tertiaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Styles.tertiaryColor.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Styles.primaryColor.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return _buildErrorState();
    } else if (_userInfo != null) {
      return widget.showFullInfo
          ? _buildFullUserInfo()
          : _buildCompactUserInfo();
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Styles.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Styles.primaryColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.showFullInfo) ...[
          const SizedBox(height: 16),
          Text(
            'Loading user information...',
            style: TextStyles.hintText.copyWith(
              fontSize: 14,
              color: Styles.textColorMed,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Loading Profile',
                    style: TextStyles.cardTitle.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unable to fetch user data',
                    style: TextStyles.dataValue.copyWith(
                      color: Styles.textColorMed,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.showFullInfo) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.red.shade600, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage ?? 'Unknown error occurred',
                    style: TextStyles.hintText.copyWith(
                      fontSize: 13,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _refreshUserInfo,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Retry', style: TextStyles.primaryButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: Colors.grey.shade600,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No User Data',
                    style: TextStyles.cardTitle.copyWith(
                      color: Styles.tertiaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User information not available',
                    style: TextStyles.dataValue.copyWith(
                      color: Styles.textColorMed,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.showFullInfo) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _refreshUserInfo,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label:
                  Text('Load User Info', style: TextStyles.primaryButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactUserInfo() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _userInfo!.displayName,
                style: TextStyles.cardTitle.copyWith(
                  color: Styles.tertiaryColor,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _userInfo!.email,
                style: TextStyles.dataValue.copyWith(
                  color: Styles.textColorMed,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (widget.onTap != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Styles.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Styles.primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildFullUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with avatar and basic info
        Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userInfo!.displayName,
                    style: TextStyles.sectionTitle.copyWith(
                      color: Styles.tertiaryColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Styles.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Styles.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '@${_userInfo!.username}',
                      style: TextStyles.chipText.copyWith(
                        color: Styles.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Styles.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _refreshUserInfo,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: Styles.primaryColor,
                  size: 22,
                ),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Contact Information
        _buildInfoSection('Contact Information', [
          _buildInfoRow(Icons.email_outlined, 'Email', _userInfo!.email),
          _buildInfoRow(Icons.phone_outlined, 'Phone', _userInfo!.phonenumber),
          _buildInfoRow(
              Icons.location_on_outlined, 'Address', _userInfo!.address),
        ]),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Styles.primaryColor,
            Styles.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Styles.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Styles.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _userInfo!.initials,
          style: TextStyles.primaryButtonText.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.subsectionTitle.copyWith(
            color: Styles.tertiaryColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Styles.primaryColor.withOpacity(0.1),
                  Styles.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Styles.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Styles.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.dataLabel.copyWith(
                    fontSize: 12,
                    color: Styles.textColorMed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  style: TextStyles.dataValue.copyWith(
                    fontSize: 15,
                    color: value.isNotEmpty
                        ? Styles.tertiaryColor
                        : Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
