import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/ui/pages/home/widgets/metrics_card.dart';
import 'package:flutter_stats/ui/pages/home/widgets/prediction_widget.dart';
import 'package:provider/provider.dart';

class RegressionView extends StatelessWidget {
  const RegressionView({super.key});

  String getLinearEquation(String b0, String b1) {
    // ignore: prefer_interpolation_to_compose_strings
    return r'\hat{Z_Y} = \beta_0 + \beta_1 \cdot Z_X=' +
        b0 +
        ' + ' +
        b1 +
        r' \cdot Z_X';
  }

  String getNonlinearEquation(String b0, String b1) {
    // ignore: prefer_interpolation_to_compose_strings
    return r'\hat{Y} = 10^{\beta_0} \cdot X^{\beta_1}=10^{' +
        b0 +
        r'} \cdot X^{' +
        b1 +
        '}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegressionModelProvider>();
    final b0 = provider.coefficients[0].toStringAsFixed(3);
    final b1 = provider.coefficients[1].toStringAsFixed(3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          Text(
            'Regression Analysis',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          MetricsCard(
            title: 'Linear Regression',
            value: getLinearEquation(b0, b1),
            isEquation: true,
          ),
          const SizedBox(height: 20),
          MetricsCard(
            title: 'Nonlinear Regression Equation',
            value: getNonlinearEquation(b0, b1),
            isEquation: true,
          ),
          const SizedBox(height: 20),
          const PredictionWidget(),
          const SizedBox(height: 20),
          MetricsCard(
            title: 'R²',
            value: provider.modelQuality.rSquared.toString(),
          ),
          const SizedBox(height: 20),
          MetricsCard(
            title: 'MMRE',
            value: provider.modelQuality.mmre.toString(),
          ),
          const SizedBox(height: 20),
          MetricsCard(
            title: 'PRED(0.25)',
            value: provider.modelQuality.pred.toString(),
          ),
          const SizedBox(height: 20),
          FutureBuilder(
            future: provider.outliers,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final outliers = snapshot.data;
              if (outliers == null) {
                return const Center(
                  child: Text('Error loading outliers'),
                );
              }
              return MetricsCard(
                title: 'Outliers',
                value: outliers.length.toString(),
              );
            },
          ),
          const SizedBox(height: 20),
          MetricsCard(
            title: 'Total outliers removed',
            value: provider.outliersRemoved.toString(),
          ),
          const SizedBox(height: 40),
          const Text('Good model indicators:\n'
              'R² > 0.7\n'
              'MMRE < 0.25\n'
              'PRED(0.25) > 0.75'),
        ],
      ),
    );
  }
}
