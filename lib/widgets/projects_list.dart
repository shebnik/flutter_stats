import 'package:flutter/material.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/models/settings/settings.dart';
import 'package:flutter_stats/providers/settings_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:provider/provider.dart';

class ProjectsList extends StatefulWidget {
  const ProjectsList({
    required this.projects,
    this.whyOutliers,
    super.key,
  });

  final List<Project> projects;
  final List<String>? whyOutliers;

  @override
  State<ProjectsList> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  String getSubtitle(Project project, Metrics metrics, Settings settings) {
    final alias = settings.csvAlias;
    final subtitle = StringBuffer();

    String formatMetricValue(num? value) {
      if (value == null) return '';
      return value % 1 == 0
          ? value.toStringAsFixed(0)
          : Utils.formatNumber(value.toDouble());
    }

    void addMetricLine(
      String label,
      String aliasValue,
      num? value,
    ) {
      if (value != null) {
        if (subtitle.isNotEmpty) subtitle.write('\n');
        subtitle.write('$label $aliasValue: ${formatMetricValue(value)}');
      }
    }

    addMetricLine('(Y)', alias.y, metrics.y);
    addMetricLine('(X1)', alias.x1, metrics.x1);

    if (settings.hasX2) {
      addMetricLine('(X2)', alias.x2, metrics.x2);
    }

    if (settings.hasX3) {
      addMetricLine('(X3)', alias.x3, metrics.x3);
    }

    if (metrics.noc != null) {
      addMetricLine('NOC', '(Number of Classes)', metrics.noc);
    }

    return subtitle.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.projects.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final project = widget.projects[index];
        final metrics = project.metrics;
        final whyOutlier =
            widget.whyOutliers != null ? widget.whyOutliers![index] : null;
        final title = project.url != null || whyOutlier != null
            ? RichText(
                text: TextSpan(
                  children: [
                    if (whyOutlier != null)
                      TextSpan(
                        text: whyOutlier,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          color: Colors.red,
                        ),
                      ),
                    if (project.url != null && whyOutlier != null)
                      const TextSpan(text: '\n'),
                    if (project.url != null)
                      TextSpan(
                        text: project.url,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              )
            : null;
        final subtitle = getSubtitle(
          project,
          metrics,
          context.watch<SettingsProvider>().settings,
        );
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
            title: title,
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                height: 2,
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
