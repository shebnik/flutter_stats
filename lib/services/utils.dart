import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Utils {
  static String formatNumber(double number) {
    return number.toStringAsFixed(4);
  }

  void loadCsvFile(BuildContext context) {
    final model = context.read<RegressionModelProvider>();
    try {
      context.read<DataHandler>().retrieveData().then(model.setProjects);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid file format'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 1),
        ),
      );
    }
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

  static Future<void> openUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }
}
