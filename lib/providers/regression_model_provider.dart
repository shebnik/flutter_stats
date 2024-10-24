import 'package:flutter/material.dart';
import 'package:flutter_stats/services/regression_model.dart';

class RegressionModelProvider extends ChangeNotifier {

  RegressionModel? _model;

  RegressionModel? get model => _model;

  void setModel(RegressionModel model) {
    _model = model;
    notifyListeners();
  }
}
