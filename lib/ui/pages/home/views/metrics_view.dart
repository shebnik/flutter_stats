import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/ui/pages/home/widgets/projects_list.dart';
import 'package:provider/provider.dart';

class MetricsView extends StatelessWidget {
  const MetricsView({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = context.watch<RegressionModelProvider>().metrics;
    return ProjectsList(
      metrics: metrics,
      key: const Key('metrics_list'),
    );
  }
}
