import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/outliers_provider.dart';
import 'package:flutter_stats/ui/pages/home/widgets/projects_list.dart';
import 'package:provider/provider.dart';

class MetricsView extends StatelessWidget {
  const MetricsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OutliersProvider>();
    return Column(
      children: [
        CheckboxListTile(
          value: provider.useRelativeNOC,
          onChanged: provider.setUseRelativeNOC,
          title: const Text('Use relative NOC (Divide all metrics by NOC)'),
        ),
        ProjectsList(
          projects: provider.projects,
          key: const Key('projects_list'),
        ),
      ],
    );
  }
}
