import 'package:flutter/material.dart';

class AppThemeProvider extends ChangeNotifier {
  AppThemeProvider(BuildContext context)
      : _isDarkMode =
            MediaQuery.of(context).platformBrightness == Brightness.dark;

  bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
