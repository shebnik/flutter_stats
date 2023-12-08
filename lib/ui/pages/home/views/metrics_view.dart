import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:provider/provider.dart';

class MetricsView extends StatelessWidget {
  const MetricsView({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = context.watch<RegressionModelProvider>().metrics;
    return ListView.builder(
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return ListTile(
          leading: Text(
            '${index + 1}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          title: Text(
            '(Y) Lines of code in thousands: ${metric.linesOfCode}',
          ),
          subtitle: Text(
            '(X) Number of classes: ${metric.numberOfClasses?.toStringAsFixed(0)}',
          ),
        );
      },
    );
  }
}
