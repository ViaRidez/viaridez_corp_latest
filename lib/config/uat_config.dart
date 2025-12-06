class UATConfig {
  // Controls whether UAT banner is shown
  static const bool showUATBanner = true;

  // UAT banner message for different screen sizes
  static const String fullMessage =
      'UAT Testing Environment - Not for Production Use';
  static const String shortMessage = 'UAT Environment - Testing Only';

  // UAT banner colors
  static const int primaryColor = 0xFFFF6B35;
  static const int secondaryColor = 0xFFFF8E53;

  // Environment type
  static const String environment = 'UAT';

  // Auto-hide banner after duration (null = never auto-hide)
  static const Duration? autoHideDuration = null;
}
