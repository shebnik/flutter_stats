import 'package:flutter/material.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
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
    return ListView.separated(
      shrinkWrap: true,
      itemCount: projects.length,
      separatorBuilder: (context, index) {
        if (outliersIndexes != null && !outliersIndexes!.contains(index)) {
          return const SizedBox.shrink();
        }
        return const Divider();
      },
      itemBuilder: (context, index) {
        if (outliersIndexes != null && !outliersIndexes!.contains(index)) {
          return const SizedBox.shrink();
        }
        final project = projects[index];
        final metric = project.metrics!;
        var subtitle = '';
        if (metric.rfc != null) {
          var value = Utils.formatNumber(metric.rfc!);
          if (metric.dit! % 1 == 0) {
            value = metric.rfc!.toStringAsFixed(0);
          }
          subtitle += '(Y) RFC (Response for a Class): $value';
        }
        if (metric.dit != null) {
          var value = Utils.formatNumber(metric.dit!);
          if (metric.dit! % 1 == 0) {
            value = metric.dit!.toStringAsFixed(0);
          }
          subtitle += '\n(X1) DIT (Depth of Inheritance Tree) : $value';
        }
        if (metric.cbo != null) {
          var value = Utils.formatNumber(metric.cbo!);
          if (metric.cbo! % 1 == 0) {
            value = metric.cbo!.toStringAsFixed(0);
          }
          subtitle += '\n(X2) CBO (Coupling Between Object Classes): $value';
        }
        if (metric.wmc != null) {
          var value = Utils.formatNumber(metric.wmc!);
          if (metric.wmc! % 1 == 0) {
            value = metric.wmc!.toStringAsFixed(0);
          }
          subtitle += '\n(X3) WMC (Weighted Methods Per Class): $value';
        }
        if (metric.noc != null) {
          var value = metric.noc!.toString();
          if (metric.noc! % 1 == 0) {
            value = metric.noc!.toStringAsFixed(0);
          }
          subtitle += '\nNOC (Number of Classes): $value';
        }
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(
              horizontal: -4,
              vertical: -4,
            ),
            leading: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 22,
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
                    style: const TextStyle(
                      fontSize: 18,
                      height: 2,
                      color: Colors.blue,
                    ),
                  )
                : null,
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                height: 2,
              ),
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<ProjectsProvider>().removeProject(index);
              },
            ),
          ),
        );
      },
    );
  }
}
