import 'dart:math';

class Algebra {
  double logBase10(double value) {
    if (value <= 0) return 0;
    return log(value) / log(10);
  }

  double average(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  List<List<double>> calculateCovarianceMatrix(List<List<double>> matrix) {
    final n = matrix.length;
    return List.generate(
      4,
      (i) => List.generate(4, (j) {
        final sum = List.generate(
          n,
          (k) =>
              (matrix[i][k] - average(matrix[i])) *
              (matrix[j][k] - average(matrix[j])),
        ).reduce((a, b) => a + b);
        return sum / n;
      }),
    );
  }

  List<List<double>> invertMatrix(List<List<double>> matrix) {
    final size = matrix.length;
    final identityMatrix = List<List<double>>.generate(
      size,
      (i) => List.generate(size, (j) => i == j ? 1.0 : 0.0),
    );
    final workingMatrix = matrix.map((row) => row.toList()).toList();

    for (var i = 0; i < size; i++) {
      final diagElement = workingMatrix[i][i];
      for (var j = 0; j < size; j++) {
        workingMatrix[i][j] /= diagElement;
        identityMatrix[i][j] /= diagElement;
      }

      for (var k = 0; k < size; k++) {
        if (k == i) continue;
        final factor = workingMatrix[k][i];
        for (var j = 0; j < size; j++) {
          workingMatrix[k][j] -= factor * workingMatrix[i][j];
          identityMatrix[k][j] -= factor * identityMatrix[i][j];
        }
      }
    }

    return identityMatrix;
  }

}
