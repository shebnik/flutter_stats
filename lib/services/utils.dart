import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:provider/provider.dart';

class Utils {
  void loadCsvFile(BuildContext context) {
    context.read<DataHandler>().retrieveData().then((metrics) {
      context.read<RegressionModelProvider>().setMetrics(metrics);
    });
  }

  static void copyToClipboard(String value, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 1),
      ),
    );
    Clipboard.setData(ClipboardData(text: value));
  }
}
