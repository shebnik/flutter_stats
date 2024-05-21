import 'package:flutter/material.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/providers/scroll_provider.dart';
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
      controller: Provider.of<ScrollProvider>(context, listen: false).sc,
      itemCount: projects.length,
      itemBuilder: (context, index) {
        if (outliersIndexes != null && !outliersIndexes!.contains(index)) {
          return const SizedBox.shrink();
        }
        final project = projects[index];
        final metric = project.metrics!;
        var subtitle = '(Y) Lines of code in thousands: ${metric.linesOfCode}';
        if (metric.numberOfClasses != null) {
          var value = metric.numberOfClasses!.toString();
          if (metric.numberOfClasses! % 1 == 0) {
            value = metric.numberOfClasses!.toStringAsFixed(0);
          }
          subtitle += '\n(X1) Number of classes: $value';
        }
        if (metric.numberOfMethods != null) {
          var value = metric.numberOfMethods!.toString();
          if (metric.numberOfMethods! % 1 == 0) {
            value = metric.numberOfMethods!.toStringAsFixed(0);
          }
          subtitle += '\n(X2) Number of methods: $value';
        }
        if (metric.numberOfDependencies != null) {
          var value = metric.numberOfDependencies!.toString();
          if (metric.numberOfDependencies! % 1 == 0) {
            value = metric.numberOfDependencies!.toStringAsFixed(0);
          }
          subtitle += '\n(X3) Number of dependencies: $value';
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
            onTap: () async {
              if (project.url != null) {
                await Utils.openUrl(project.url!);
              } else {
                Utils.copyToClipboard(subtitle, context);
              }
            },
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
