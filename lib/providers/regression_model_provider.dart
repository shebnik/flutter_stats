import 'package:flutter/foundation.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/services/regression_model.dart';

class RegressionModelProvider with ChangeNotifier {
  List<Metrics> _metrics = [];

  List<Metrics> get metrics => _metrics;
  late final RegressionModel _regressionModel;

  void setMetrics(List<Metrics> metrics) {
    _metrics = metrics;
    _regressionModel = RegressionModel(metrics);
    notifyListeners();
  }

  List<List<double>> get covarianceMatrix =>
      _regressionModel.calculateCovarianceMatrix();

  List<List<double>> get covarianceMatrixInverse =>
      _regressionModel.invertMatrix(covarianceMatrix);
}
