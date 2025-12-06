import 'package:flutter/material.dart';

import '../utils/styles.dart';

class OptButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final double? fontSize;
  final bool isLoading;

  const OptButton({
    super.key,
    required this.text,
    required this.onTap,
    this.fontSize = 20,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLoading
            ? Styles.primaryColor.withOpacity(0.7)
            : Styles.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: const Color.fromRGBO(253, 253, 253, 1),
                    fontFamily: 'Lexend',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
