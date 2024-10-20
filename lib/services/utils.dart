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

  void loadDataFile(BuildContext context) {
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

  static Color getColor(MetricsType metricsType, double val) {
    // Ensure value is between 0 and 1
    final value = val.clamp(0.0, 1.0);

    switch (metricsType) {
      case MetricsType.rSquared:
        if (value <= 0.7) {
          // Gradient from red (0) to orange (0.7)
          return Color.lerp(Colors.red, Colors.orange, value / 0.7)!;
        } else {
          // Gradient from orange (0.7) to green (1.0)
          return Color.lerp(Colors.orange, Colors.green, (value - 0.7) / 0.3)!;
        }

      case MetricsType.mmre:
        if (value <= 0.25) {
          // Gradient from green (0) to light green (0.25)
          return Color.lerp(Colors.green, Colors.lightGreen, value / 0.25)!;
        } else {
          // Gradient from orange (0.25) to red (1.0)
          return Color.lerp(Colors.orange, Colors.red, (value - 0.25) / 0.75)!;
        }

      case MetricsType.pred:
        if (value >= 0.75) {
          // Gradient from light green (0.75) to green (1.0)
          return Color.lerp(
            Colors.lightGreen,
            Colors.green,
            (value - 0.75) / 0.25,
          )!;
        } else {
          // Gradient from red (0) to orange (0.75)
          return Color.lerp(Colors.red, Colors.orange, value / 0.75)!;
        }
    }
  }
}

enum MetricsType { rSquared, mmre, pred }
