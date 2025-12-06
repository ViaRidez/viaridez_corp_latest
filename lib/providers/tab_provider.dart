import 'package:flutter/material.dart';

class TabProvider with ChangeNotifier {
  int _selectedIndex = 0;
  int _tripSelectionIndex = 0;
  int _serviceRequestSelectionIndex = 0;

  int get selectedIndex => _selectedIndex;
  int get tripSelectionIndex => _tripSelectionIndex;
  int get serviceRequestSelectionIndex => _serviceRequestSelectionIndex;

  void selectTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void selectTripsTab(int index) {
    _tripSelectionIndex = index;
    notifyListeners();
  }

  void selectServiceRequestTab(int index) {
    _serviceRequestSelectionIndex = index;
    notifyListeners();
  }
}
