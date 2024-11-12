import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:provider/provider.dart';

class UploadProjectsButton extends StatelessWidget {
  const UploadProjectsButton({
    required this.type,
    super.key,
  });

  final MetricsNavigationType type;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Upload ${type.label} as .csv',
      icon: const Icon(Icons.upload_file),
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
        context.read<DataHandler>().uploadFile(
              context: context,
              type: type,
            );
      },
    );
  }
}
