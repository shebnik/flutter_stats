import 'package:flutter/material.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:provider/provider.dart';

class ProjectsList extends StatelessWidget {
  const ProjectsList({
    required this.projects,
    this.outliersIndexes,
    super.key,
  });

  final List<Project> projects;
  final List<int>? outliersIndexes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        if (outliersIndexes != null && !outliersIndexes!.contains(index)) {
          return const SizedBox.shrink();
        }
        final project = projects[index];
        final metric = project.metrics!;
        var subtitle = '(Y) Lines of code in thousands: ${metric.linesOfCode}';
        if (metric.numberOfClasses != null) {
          subtitle += '\n(X1) Number of classes: ${metric.numberOfClasses}';
        }
        if (metric.numberOfMethods != null) {
          subtitle += '\n(X2) Number of methods: ${metric.numberOfMethods}';
        }
        if (metric.cyclomaticComplexity != null) {
          subtitle +=
              '\n(X3) Cyclomatic complexity: ${metric.cyclomaticComplexity}';
        }
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
            onTap: () => Utils.copyToClipboard(subtitle, context),
            title: project.url != null
                ? Text(
                    project.url!,
                  )
                : null,
            subtitle: Text(
              subtitle,
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<RegressionModelProvider>().removeProject(index);
              },
            ),
          ),
        );
      },
    );
  }
}
