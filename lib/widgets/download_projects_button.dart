import 'package:flutter/material.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
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
      onPressed: () => context.read<DataHandler>().downloadFile(
            fileName: filename,
            projects: projects ??
                context.read<MetricsNavigationProvider>().getProjects(
                      model: context.read<RegressionModelProvider>().model,
                    ),
          ),
    );
  }
}
