import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../utils/styles.dart';

class OptPhonenumbertextfield extends StatelessWidget {
  final String inputText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final FutureOr<String?> Function(PhoneNumber?)? validator;
  final String initialCountryCode;
  final void Function(Country)? onCountryChanged;
  final FocusNode? focusNode;

  const OptPhonenumbertextfield({
    super.key,
    required this.inputText,
    this.controller,
    this.keyboardType = TextInputType.number,
    this.validator,
    required this.initialCountryCode,
    required this.onCountryChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      focusNode: focusNode,
      pickerDialogStyle: PickerDialogStyle(width: 400),
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      initialCountryCode: initialCountryCode,
      onCountryChanged: onCountryChanged,
      decoration: InputDecoration(
        labelText: inputText,
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
      ),
    );
  }
}
