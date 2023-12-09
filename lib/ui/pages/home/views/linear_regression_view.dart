import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/ui/pages/home/widgets/metrics_card.dart';
import 'package:flutter_stats/ui/pages/home/widgets/prediction_widget.dart';
import 'package:provider/provider.dart';

class LinearRegressionView extends StatelessWidget {
  const LinearRegressionView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegressionModelProvider>();
    final b0 = provider.coefficients[0];
    final b1 = provider.coefficients[1];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              'Linear Regression Model',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                MetricsCard(
                  title: 'Equation',
                  value: 'Y = $b0 + $b1 * X',
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
                  title: 'Standard Error',
                  value: provider.modelQuality.sy.toString(),
                ),
                const SizedBox(height: 20),
                MetricsCard(
                  title: 'MMRE',
                  value: provider.modelQuality.mmre.toString(),
                ),
                const SizedBox(height: 20),
                MetricsCard(
                  title: 'Pred(25)',
                  value: provider.modelQuality.pred.toString(),
                ),
                const SizedBox(height: 20),
                MetricsCard(
                  title: 'Outliers',
                  value: provider.outliers.length.toString(),
                ),
                const SizedBox(height: 40),
                const Text('R² > 0.7 indicates a good model\n'
                    'MMRE < 0.25 indicates a good model\n'
                    'Pred(25) > 0.75 indicates a good model'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
