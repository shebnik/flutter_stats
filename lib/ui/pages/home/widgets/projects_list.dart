import 'package:flutter/material.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:provider/provider.dart';

class ProjectsList extends StatelessWidget {
  const ProjectsList({
    required this.metrics,
    this.outliersIndexes,
    super.key,
  });

  final List<Metrics> metrics;
  final List<int>? outliersIndexes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        if (outliersIndexes != null && !outliersIndexes!.contains(index)) {
          return const SizedBox.shrink();
        }
        final metric = metrics[index];
        final y = metric.linesOfCode;
        final x = metric.numberOfClasses?.toStringAsFixed(0);
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ListTile(
            leading: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => Utils.copyToClipboard('y=$y, x=$x', context),
            title: Text(
              '(Y) Lines of code in thousands: $y',
            ),
            subtitle: Text(
              '(X) Number of classes: $x',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<RegressionModelProvider>().removeMetric(index);
              },
            ),
          ),
        );
      },
    );
  }
}
