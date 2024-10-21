import 'dart:math';

class Algebra {
  double logBase10(double value) {
    if (value <= 0) return 0;
    return log(value) / log(10);
  }

  double average(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;
}
