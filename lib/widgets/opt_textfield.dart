import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/styles.dart';

class OptTextfield extends StatelessWidget {
  final String inputText;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? icon;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final Widget? suffix;
  final bool obscureText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final EdgeInsetsGeometry contentPadding;
  final bool enabled;
  final VoidCallback? onTap;
  final String? fontFamily;

  const OptTextfield({
    super.key,
    required this.inputText,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.icon,
    this.readOnly = false,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.nextFocus,
    this.suffix,
    this.obscureText = false,
    this.helperText,
    this.onChanged,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.autofocus = false,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.enabled = true,
    this.onTap,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: isPassword || obscureText ? 1 : maxLines,
      minLines: minLines,
      textAlignVertical: TextAlignVertical.top,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      controller: controller,
      obscureText: isPassword || obscureText,
      keyboardType: keyboardType,
      validator: validator,
      focusNode: focusNode,
      onChanged: onChanged,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction ??
          (nextFocus != null ? TextInputAction.next : TextInputAction.done),
      autofocus: autofocus,
      enabled: enabled,
      onTap: onTap,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          nextFocus!.requestFocus();
        }
      },
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: inputText,
        helperText: helperText,
        contentPadding: contentPadding,
        labelStyle: TextStyle(
          color: Styles.tertiaryColor.withAlpha(150),
          fontWeight: FontWeight.w200,
          fontFamily: 'Lexend',
        ),
        floatingLabelStyle: TextStyle(
          color: Styles.primaryColor,
        ),
        hintStyle: TextStyle(
          color: Styles.tertiaryColor.withAlpha(180),
          fontWeight: FontWeight.w200,
          fontFamily: 'Lexend',
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Styles.primaryColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Styles.primaryColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        hintText: inputText,
        suffixIcon: suffix ??
            (icon != null ? Icon(icon, color: Styles.primaryColor) : null),
        counterText: maxLength != null
            ? null
            : '', // Hide counter text if maxLength is null
      ),
      style: TextStyle(
        fontFamily: fontFamily,
      ),
    );
  }
}
