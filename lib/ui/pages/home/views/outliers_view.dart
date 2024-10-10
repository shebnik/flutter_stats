import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/ui/pages/home/widgets/projects_list.dart';
import 'package:provider/provider.dart';

class OutliersView extends StatelessWidget {
  const OutliersView({super.key});

  @override
  Widget build(BuildContext context) {
    final fisherFDistributionFuture = context.select(
      (RegressionModelProvider provider) => provider.fisherFDistribution,
    );
    final outliersIndexesFuture = context.select(
      (RegressionModelProvider provider) => provider.outliers,
    );
    final metrics = context.select(
      (RegressionModelProvider provider) => provider.projects,
    );
    return FutureBuilder(
      future: outliersIndexesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final outliersIndexes = snapshot.data;
        if (outliersIndexes == null) {
          return const Center(
            child: Text('Error loading outliers'),
          );
        }

        return Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    FutureBuilder(
                      future: fisherFDistributionFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final fisherFDistribution =
                            Utils.formatNumber(snapshot.data ?? 0);
                        return Text(
                          'Fisher F-Distribution: $fisherFDistribution',
                          style: Theme.of(context).textTheme.titleLarge,
                        );
                      },
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
              ] else ...[
                Text(
                  'Outliers',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: ProjectsList(
                    projects: metrics,
                    outliersIndexes: outliersIndexes,
                    key: const Key('outliers_list'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
