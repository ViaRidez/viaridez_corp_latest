import 'package:flutter/material.dart';

import '../utils/styles.dart';

class OptLargeTextfield extends StatelessWidget {
  final String inputText;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? icon;
  final bool message;

  const OptLargeTextfield({
    super.key,
    required this.inputText,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.icon,
    this.message = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.top,
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: (message) ? null : inputText,
        labelStyle: TextStyle(
          color: Styles.tertiaryColor.withAlpha(150),
          fontWeight: FontWeight.w200,
          fontFamily: 'Lexend',
          // fontSize: 20
        ),
        floatingLabelStyle: TextStyle(
          color: Styles.primaryColor,
        ),
        hintStyle: TextStyle(
          color: Styles.tertiaryColor.withAlpha(180),
          fontWeight: FontWeight.w200,
          fontFamily: 'Lexend',
          // fontSize: 20
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Styles.primaryColor,
            ),
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Styles.primaryColor,
            ),
            borderRadius: BorderRadius.circular(12)),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Styles.primaryColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintText: inputText,
        suffixIcon:
            icon != null ? Icon(icon, color: Styles.primaryColor) : null,
      ),
    );
  }
}
