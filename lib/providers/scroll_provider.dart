import 'package:flutter/material.dart';

class ScrollProvider extends ChangeNotifier {
  ScrollProvider(this.sc) {
    setupListener();
  }

  final ScrollController sc;

  void scrollToTop() {
    sc.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool _showScrollToTopButton = false;
  bool get showScrollToTopButton => _showScrollToTopButton;
  set showScrollToTopButton(bool value) {
    _showScrollToTopButton = value;
    notifyListeners();
  }

  void setupListener() {
    sc.addListener(() {
      if (sc.offset > 100) {
        showScrollToTopButton = true;
      } else {
        showScrollToTopButton = false;
      }
      if (_showScrollToTopButton != showScrollToTopButton) {
        notifyListeners();
      }
    });
  }
}
