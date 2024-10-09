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
        var subtitle = '(Y) WMC (Weighted Methods Per Class): ${metric.wmc}';
        if (metric.dit != null) {
          var value = metric.dit!.toString();
          if (metric.dit! % 1 == 0) {
            value = metric.dit!.toStringAsFixed(0);
          }
          subtitle += '\n(X1) DIT (Depth of Inheritance Tree) : $value';
        }
        if (metric.rfc != null) {
          var value = metric.rfc!.toString();
          if (metric.rfc! % 1 == 0) {
            value = metric.rfc!.toStringAsFixed(0);
          }
          subtitle += '\n(X2) RFC (Response for a Class): $value';
        }
        if (metric.cbo != null) {
          var value = metric.cbo!.toString();
          if (metric.cbo! % 1 == 0) {
            value = metric.cbo!.toStringAsFixed(0);
          }
          subtitle += '\n(X3) CBO (Coupling Between Object Classes): $value';
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
