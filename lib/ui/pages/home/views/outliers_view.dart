import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/ui/pages/home/widgets/projects_list.dart';
import 'package:provider/provider.dart';

class OutliersView extends StatelessWidget {
  const OutliersView({super.key});

  @override
  Widget build(BuildContext context) {
    final outliersIndexes = context.select(
      (RegressionModelProvider provider) => provider.outliers,
    );
    final metrics = context.select(
      (RegressionModelProvider provider) => provider.metrics,
    );
    return Container(
      padding: const EdgeInsets.all(8),
      child: outliersIndexes.isEmpty
          ? Center(
              child: Text(
                'No outliers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            )
          : Column(
              children: [
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
            ),
    );
  }
}
