import 'package:flutter/material.dart';

class RouteStop {
  final TextEditingController nameController;
  final TextEditingController latController;
  final TextEditingController lngController;

  RouteStop({
    required this.nameController,
    required this.latController,
    required this.lngController,
  });

  void dispose() {
    nameController.dispose();
    latController.dispose();
    lngController.dispose();
  }
}
