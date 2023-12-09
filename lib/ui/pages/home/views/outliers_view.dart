import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/ui/pages/home/widgets/projects_list.dart';
import 'package:provider/provider.dart';

class OutliersView extends StatelessWidget {
  const OutliersView({super.key});

  @override
  Widget build(BuildContext context) {
    final fisherFDistribution = context.select(
      (RegressionModelProvider provider) => provider.fisherFDistribution,
    );
    final outliersIndexes = context.select(
      (RegressionModelProvider provider) => provider.outliers,
    );
    final metrics = context.select(
      (RegressionModelProvider provider) => provider.metrics,
    );
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Fisher F-Distribution: $fisherFDistribution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          if (outliersIndexes.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No outliers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
          ...[
            Text(
              'Outliers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: ProjectsList(
                metrics: metrics,
                outliersIndexes: outliersIndexes,
                key: const Key('outliers_list'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
