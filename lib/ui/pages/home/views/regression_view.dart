import 'package:flutter/material.dart';
import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/ui/pages/home/widgets/metrics_card.dart';
import 'package:provider/provider.dart';

class RegressionView extends StatelessWidget {
  const RegressionView({super.key});

  String getLinearEquation(Coefficients coefficients) {
    final b0 = Utils.formatNumber(coefficients.b0);
    dynamic b1 = coefficients.b1;
    dynamic b2 = coefficients.b2;
    dynamic b3 = coefficients.b3;

    if ((b1 as double) < 0) {
      b1 = ' - ${Utils.formatNumber(b1.abs())}';
    } else {
      b1 = ' + ${Utils.formatNumber(b1)}';
    }

    if ((b2 as double) < 0) {
      b2 = ' - ${Utils.formatNumber(b2.abs())}';
    } else {
      b2 = ' + ${Utils.formatNumber(b2)}';
    }

    if ((b3 as double) < 0) {
      b3 = ' - ${Utils.formatNumber(b3.abs())}';
    } else {
      b3 = ' + ${Utils.formatNumber(b3)}';
    }

    // ignore: prefer_interpolation_to_compose_strings
    return r'\hat{Z_Y} = \beta_0 + \beta_1 \cdot Z_{X_1} + \beta_2 \cdot Z_{X_2} + \beta_3 \cdot Z_{X_3}=' +
        b0 +
        (b1 as String) +
        r' \cdot Z_{X_1}' +
        (b2 as String) +
        r' \cdot Z_{X_2}' +
        (b3 as String) +
        r' \cdot Z_{X_3}';
  }

  String getNonlinearEquation(Coefficients coefficients) {
    final b0 = Utils.formatNumber(coefficients.b0);
    final b1 = Utils.formatNumber(coefficients.b1);
    final b2 = Utils.formatNumber(coefficients.b2);
    final b3 = Utils.formatNumber(coefficients.b3);
    // ignore: prefer_interpolation_to_compose_strings
    return r'\hat{Y} = 10^{\beta_0} \cdot X_1^{\beta_1} \cdot X_2^{\beta_2} \cdot X_3^{\beta_3}=10^{' +
        b0 +
        r'} \cdot X_1^{' +
        b1 +
        r'} \cdot X_2^{' +
        b2 +
        r'} \cdot X_3^{' +
        b3 +
        '}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegressionModelProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regression Analysis: ',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 20),
          MetricsCard(
            title: 'Linear Regression: ',
            value: getLinearEquation(provider.coefficients),
            isEquation: true,
          ),
          const SizedBox(height: 20),
          MetricsCard(
            title: 'Nonlinear Regression Equation: ',
            value: getNonlinearEquation(provider.coefficients),
            isEquation: true,
          ),
          const SizedBox(height: 16),
          MetricsCard(
            title: 'Data points: ',
            value: provider.yData.length.toString(),
          ),
          const SizedBox(height: 16),
          MetricsCard(
            title: 'Total outliers removed: ',
            value: provider.outliersRemoved.toString(),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: provider.outliers,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox.shrink();
              }
              final outliers = snapshot.data;
              if (outliers == null) {
                return const Center(
                  child: Text('Error loading outliers'),
                );
              }
              return MetricsCard(
                title: 'Outliers left: ',
                value: outliers.length.toString(),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Nonlinear Regression Model Quality',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    const Text(
                      'R² = ',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      Utils.formatNumber(provider.modelQuality.rSquared),
                      style: TextStyle(
                        fontSize: 18,
                        color: Utils.getColor(
                          MetricsType.rSquared,
                          provider.modelQuality.rSquared,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Row(
                  children: [
                    const Text(
                      'MMRE = ',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      Utils.formatNumber(provider.modelQuality.mmre),
                      style: TextStyle(
                        fontSize: 18,
                        color: Utils.getColor(
                          MetricsType.mmre,
                          provider.modelQuality.mmre,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Row(
                  children: [
                    const Text(
                      'PRED(0.25) = ',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      Utils.formatNumber(provider.modelQuality.pred),
                      style: TextStyle(
                        fontSize: 18,
                        color: Utils.getColor(
                          MetricsType.pred,
                          provider.modelQuality.pred,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Good model indicators:\n'
            'R² > 0.7\n'
            'MMRE < 0.25\n'
            'PRED(0.25) > 0.75',
          ),
        ],
      ),
    );
  }
}
