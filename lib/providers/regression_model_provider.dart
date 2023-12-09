import 'package:flutter/foundation.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/services/regression_model.dart';

class RegressionModelProvider with ChangeNotifier {
  List<Metrics> _metrics = [];

  List<Metrics> get metrics => _metrics;
  late RegressionModel _regressionModel;

  bool _linesOfCodeInThousands = true;

  bool get linesOfCodeInThousands => _linesOfCodeInThousands;

  // ignore: avoid_positional_boolean_parameters
  void setLinesOfCodeInThousands(bool value) {
    _linesOfCodeInThousands = value;
    if (value) {
      _metrics = _metrics
          .map(
            (e) => e.copyWith(
              linesOfCode: e.linesOfCode! / 1000,
            ),
          )
          .toList();
    } else {
      _metrics = _metrics
          .map(
            (e) => e.copyWith(
              linesOfCode: e.linesOfCode! * 1000,
            ),
          )
          .toList();
    }
    notifyListeners();
  }

  void setMetrics(List<Metrics>? metrics) {
    if (metrics == null) return;
    _metrics = metrics;
    _regressionModel = RegressionModel(metrics);
    notifyListeners();
  }

  void removeMetric(int index) {
    _metrics.removeAt(index);
    _regressionModel = RegressionModel(_metrics);
    notifyListeners();
  }

  List<double> get xData => _regressionModel.Zx;
  List<double> get yData => _regressionModel.Zy;

  List<List<double>> get covarianceMatrix =>
      _regressionModel.calculateCovarianceMatrix();

  List<List<double>> get covarianceMatrixInverse =>
      _regressionModel.invertMatrix(covarianceMatrix);

  List<double> get mahalanobisDistances =>
      _regressionModel.calculateMahalanobisDistances(covarianceMatrixInverse);

  List<double> get testStatistics =>
      _regressionModel.calculateTestStatistics(mahalanobisDistances);

  double get fisherFDistribution =>
      _regressionModel.calculateFisherFDistribution();

  List<int> get outliers => _regressionModel.determineOutliers(testStatistics);

  List<double> get coefficients =>
      _regressionModel.calculateRegressionCoefficients();

  List<double> get predictedValues =>
      _regressionModel.calculatePredictedValues(coefficients);

  ModelQuality get modelQuality =>
      _regressionModel.calculateModelQuality(predictedValues);
}
