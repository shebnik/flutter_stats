import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/models/settings/csv_alias/csv_alias.dart';
import 'package:flutter_stats/services/utils.dart';

class EquationFormatter {
  static String getLinearEquation(
    Coefficients coefficients, {
    bool isMobile = false,
  }) {
    if (coefficients.b.isEmpty) {
      return r'\hat{Z_Y} = 0';
    }

    String formatCoefficient(double value) {
      return value < 0
          ? ' - ${Utils.formatNumber(value.abs())}'
          : ' + ${Utils.formatNumber(value)}';
    }

    final buffer = StringBuffer(r'\hat{Z_Y} = ');

    // Desktop format includes beta coefficients
    if (!isMobile) {
      buffer.write(r'\beta_0');

      for (var i = 1; i < coefficients.b.length; i++) {
        buffer
          ..write(r' + \beta_')
          ..write(i)
          ..write(r' \cdot Z_{X_')
          ..write(i)
          ..write('}');
      }

      buffer.write(r' + \sigma =');
    }

    // Add constant term
    buffer.write(Utils.formatNumber(coefficients.b[0]));

    // Add variable terms
    for (var i = 1; i < coefficients.b.length; i++) {
      buffer
        ..write(formatCoefficient(coefficients.b[i]))
        ..write(r' \cdot Z_{X_')
        ..write(i)
        ..write('}');
    }

    buffer
      ..write(' + ')
      ..write(Utils.formatNumber(coefficients.epsilon));

    return buffer.toString();
  }

  static String getNonlinearEquation(
    Coefficients coefficients, {
    bool isMobile = false,
  }) {
    if (coefficients.b.isEmpty) {
      return r'\hat{Y} = 1';
    }

    final buffer = StringBuffer(r'\hat{Y} = ');

    if (!isMobile) {
      buffer.write(r'10^{\beta_0 + \sigma}');

      // Add beta terms
      for (var i = 1; i < coefficients.b.length; i++) {
        buffer
          ..write(r' \cdot X_')
          ..write(i)
          ..write(r'^{\beta_')
          ..write(i)
          ..write('}');
      }

      buffer.write(' = ');
    }

    // Add base and sigma
    buffer
      ..write('10^{')
      ..write(Utils.formatNumber(coefficients.b[0]))
      ..write(' + ')
      ..write(Utils.formatNumber(coefficients.epsilon))
      ..write('}');

    // Add variable terms
    for (var i = 1; i < coefficients.b.length; i++) {
      buffer
        ..write(r' \cdot X_')
        ..write(i)
        ..write('^{')
        ..write(Utils.formatNumber(coefficients.b[i]))
        ..write('}');
    }

    return buffer.toString();
  }

  static String getPredictionEquation(
    Coefficients coefficients, {
    List<double?> xValues = const [],
    bool isMobile = false,
    CSVAlias alias = CSVAlias.defaultAlias,
  }) {
    if (coefficients.b.isEmpty) {
      return 'Error: No coefficients provided';
    }

    final buffer = StringBuffer('${alias.y} = ');

    // Desktop format includes beta coefficients
    if (!isMobile) {
      // Add base with optional sigma
      buffer.write(r'10^{\beta_0 + \sigma}');

      // Add beta terms dynamically
      for (var i = 1; i < coefficients.b.length; i++) {
        buffer
          ..write(r'\cdot ')
          ..write(alias.x(i))
          ..write(r'^{\beta_')
          ..write(i)
          ..write('}');
      }
      buffer.write('=');
    }

    // Add base value with sigma
    buffer
      ..write('10^{')
      ..write(Utils.formatNumber(coefficients.b[0]))
      ..write(' + ')
      ..write(Utils.formatNumber(coefficients.epsilon))
      ..write('}');

    // Add variable terms dynamically
    for (var i = 1; i < coefficients.b.length; i++) {
      buffer.write(r'\cdot ');

      // Use provided X value if available, otherwise use X_i notation
      if (i - 1 < xValues.length && xValues[i - 1] != null) {
        buffer.write(Utils.formatNumber(xValues[i - 1]));
      } else {
        buffer
          ..write('X_')
          ..write(i);
      }

      buffer
        ..write('^{')
        ..write(Utils.formatNumber(coefficients.b[i]))
        ..write('}');
    }

    return buffer.toString();
  }
}
