import 'dart:math';

class Algebra {
  double logBase10(double value) {
    if (value <= 0) return 0;
    return log(value) / log(10);
  }

  double average(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  List<List<double>> calculateCovarianceMatrix(List<List<double>> values) {
    final n = values.first.length;
    final p = values.length;
    return List.generate(
      p,
      (i) => List.generate(p, (j) {
        final sum = List.generate(
          n,
          (k) =>
              (values[i][k] - average(values[i])) *
              (values[j][k] - average(values[j])),
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

  List<List<double>> transposeMatrix(List<List<double>> matrix) {
    final rows = matrix.length;
    final cols = matrix[0].length;

    return List.generate(
      cols,
      (i) => List.generate(rows, (j) => matrix[j][i]),
    );
  }

  List<List<double>> matrixMultiply(
    List<List<double>> a,
    List<List<double>> b,
  ) {
    final rows = a.length;
    final cols = b[0].length;
    final n = b.length;

    return List.generate(
      rows,
      (i) => List.generate(cols, (j) {
        // ignore: omit_local_variable_types
        double sum = 0;
        for (var k = 0; k < n; k++) {
          sum += a[i][k] * b[k][j];
        }
        return sum;
      }),
    );
  }

  List<double> matrixVectorMultiply(
    List<List<double>> matrix,
    List<double> vector,
  ) {
    return List.generate(
      matrix.length,
      (i) => List.generate(vector.length, (j) => matrix[i][j] * vector[j])
          .reduce((a, b) => a + b),
    );
  }
}
