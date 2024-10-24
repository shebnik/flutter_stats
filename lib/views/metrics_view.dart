import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/widgets/download_projects_button.dart';
import 'package:flutter_stats/widgets/projects_list.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MetricsView extends StatelessWidget {
  const MetricsView({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RegressionModelProvider>().model;
    if (model == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final navigationProvider = context.watch<MetricsNavigationProvider>();
    final projects = navigationProvider.getProjects(model: model);

    final header = ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  metricsNavigationRoutes.length,
                  (index) {
                    final route = metricsNavigationRoutes[index];
                    final size = navigationProvider
                        .getProjects(model: model, type: route)
                        .length;
                    return FilterChip(
                      label: Text('${route.label} ($size)'),
                      selected: navigationProvider.type == route,
                      onSelected: (selected) {
                        if (selected) {
                          navigationProvider.type = route;
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DownloadProjectsButton(
                  filename: navigationProvider.type.label,
                  projects: projects,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Column(
      children: [
        if (ResponsiveBreakpoints.of(context).isDesktop) header,
        Expanded(child: ProjectsList(projects: projects)),
      ],
    );
  }
}
