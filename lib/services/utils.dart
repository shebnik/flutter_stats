import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:provider/provider.dart';

class Utils {
  void loadCsvFile(BuildContext context) {
    context.read<DataHandler>().retrieveData().then((metrics) {
      context.read<RegressionModelProvider>().setMetrics(metrics);
    });
  }
}
