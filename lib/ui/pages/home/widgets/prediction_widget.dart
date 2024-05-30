import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/ui/pages/home/widgets/metrics_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PredictionWidget extends StatefulWidget {
  const PredictionWidget({super.key});

  @override
  State<PredictionWidget> createState() => _PredictionWidgetState();
}

class _PredictionWidgetState extends State<PredictionWidget> {
  late RegressionModelProvider provider;
  final x1Controller = TextEditingController();
  final x2Controller = TextEditingController();
  final x3Controller = TextEditingController();
  num? _prediction;

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
      ),
      onChanged: (_) => makePrediction(),
    );
  }

  Widget _buildPredictionOutput() {
    if (_prediction == null ||
        _prediction!.isNaN ||
        _prediction!.isInfinite ||
        _prediction! < 0) {
      return const SizedBox();
    }
    final formatter = NumberFormat('#,###');
    final formatted = formatter.format(_prediction?.round());

    return MetricsCard(
      title: 'Y Prediction (Lines of Code)',
      value: formatted.replaceAll(',', ' '),
    );
  }

  void makePrediction() {
    final b0 = provider.coefficients[0];
    final b1 = provider.coefficients[1];
    final b2 = provider.coefficients[2];
    final b3 = provider.coefficients[3];
    final x1 = double.tryParse(x1Controller.text) ?? -1;
    final x2 = double.tryParse(x2Controller.text) ?? -1;
    final x3 = double.tryParse(x3Controller.text) ?? -1;
    if (x1 == -1 || x2 == -1 || x3 == -1) {
      _prediction = null;
      setState(() {});
      return;
    }
    _prediction = pow(10, b0) * pow(x1, b1) * pow(x2, b2) * pow(x3, b3) * 1000;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    provider = context.watch<RegressionModelProvider>();
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildTextField(
                  x1Controller,
                  'Enter X1 value (Number of Classes)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  x2Controller,
                  'Enter X2 value (Number of Methods)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  x3Controller,
                  'Enter X3 value (Number of Dependencies)',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildPredictionOutput(),
        const SizedBox(height: 32),
      ],
    );
  }
}
