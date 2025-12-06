import 'package:flutter/material.dart';

abstract class Styles {
  static Color primaryColor = const Color.fromRGBO(51, 145, 154, 1);
  static Color secondaryColor = const Color.fromRGBO(25, 69, 83, 1);
  static Color tertiaryColor = const Color.fromRGBO(0, 38, 77, 1);
  static Color white = const Color.fromRGBO(253, 253, 253, 1);
  // New color for medium emphasis text
  static Color textColorMed = Colors.grey.shade700;

  // Additional colors for UI consistency
  static Color lightBackground = const Color(0xFFF6F4FF);
  static Color successColor = const Color(0xFF4CAF50);
  static Color successLight = const Color(0xFFEFFAF4);
  static Color warningColor = const Color(0xFFFFC107);
  static Color errorColor = const Color(0xFFF44336);
  static Color errorLight = const Color(0xFFFFF1F1);
  static Color mutedText = Colors.grey.shade600;
}

abstract class TextStyles {
  // Headers

  static final TextStyle subsectionTitle = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade800,
    letterSpacing: 0.15,
  );

  static TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor,
    letterSpacing: 0.5,
  );

  static TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor,
    letterSpacing: 0.25,
  );

  static TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor,
    letterSpacing: 0.15,
  );

  static TextStyle formLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor,
    letterSpacing: 0.15,
  );

  // Inputs
  static TextStyle inputLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor.withOpacity(0.7),
    letterSpacing: 0.15,
  );

  static TextStyle inputTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor,
    letterSpacing: 0.15,
  );

  // Buttons
  static TextStyle primaryButtonText = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Lexend',
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle secondaryButtonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor,
    letterSpacing: 0.5,
  );

  // Data presentation
  static TextStyle dataLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: 'Lexend',
    color: Colors.grey[600],
    letterSpacing: 0.1,
  );

  static TextStyle dataValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor,
    letterSpacing: 0.25,
  );

  // New bodyText style
  static TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor, // Default body text color
    letterSpacing: 0.2,
  );

  static TextStyle tableCellText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor.withOpacity(0.9),
    letterSpacing: 0.1,
  );

  static TextStyle tableHeaderText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFamily: 'Lexend',
    color: Styles.tertiaryColor,
    letterSpacing: 0.25,
  );

  // Status and indicators
  static TextStyle formTag = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Lexend',
    color: Styles.primaryColor,
    letterSpacing: 1.2,
  );

  static TextStyle hintText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
    fontFamily: 'Lexend',
    color: Colors.grey[600],
    letterSpacing: 0.1,
  );

  static TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Kept w500 for error emphasis
    fontFamily: 'Lexend',
    color: Colors.red[700], // Standard error color
    letterSpacing: 0.1,
  );

  static final snackbarText = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.white, // Default snackbar text is often white
  );

  // New chipText style
  static TextStyle chipText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: 'Lexend',
    color: Styles.textColorMed, // Default chip text color
  );

  static TextStyle headingStyle = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}
