import 'package:flutter/material.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/providers/settings_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:provider/provider.dart';

class DownloadProjectsButton extends StatelessWidget {
  const DownloadProjectsButton({
    required this.filename,
    this.projects,
    super.key,
  });

  final List<Project>? projects;
  final String filename;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Download as .csv',
      icon: const Icon(Icons.download),
      onPressed: () {
        final model = context.read<RegressionModelProvider>().model;
        if (model == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No model selected'),
            ),
          );
          return;
        }
        context.read<DataHandler>().downloadFile(
              settings: context.read<SettingsProvider>().settings,
              fileName: filename,
              projects: projects ??
                  context.read<MetricsNavigationProvider>().getProjects(
                        model: model,
                      ),
              mahalanobisDistances:
                  context.read<ProjectsProvider>().mahalanobisDistances,
            );
      },
    );
  }
}
