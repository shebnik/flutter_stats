import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/ui/pages/home/widgets/metrics_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PredictionView extends StatefulWidget {
  const PredictionView({super.key});

  @override
  State<PredictionView> createState() => _PredictionViewState();
}

class _PredictionViewState extends State<PredictionView> {
  late RegressionModelProvider provider;
  final x1Controller = TextEditingController();
  final x2Controller = TextEditingController();
  final x3Controller = TextEditingController();
  num? _prediction;
  double? x1;
  double? x2;
  double? x3;

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  makePrediction();
                },
              )
            : null,
      ),
      onChanged: (_) => makePrediction(),
    );
  }

  Widget _buildPredictionOutput() {
    if (_prediction != null &&
        !_prediction!.isNaN &&
        !_prediction!.isInfinite &&
        _prediction! > 0) {
      final formatter = NumberFormat('#,###');
      final formatted = formatter.format(_prediction?.round());
      return MetricsCard(
        title: 'Y Prediction (RFC) = ',
        value: formatted.replaceAll(',', ' '),
      );
    }

    return const MetricsCard(
      title: 'Y Prediction (RFC)',
    );
  }

  void makePrediction() {
    x1 = double.tryParse(x1Controller.text);
    x2 = double.tryParse(x2Controller.text);
    x3 = double.tryParse(x3Controller.text);
    if (x1 == null || x2 == null || x3 == null) {
      _prediction = null;
      setState(() {});
      return;
    }
    _prediction = provider.predictY(x1!, x2!, x3!);
    setState(() {});
  }

  String getPredictionEquation(Coefficients coefficients) {
    // ignore: prefer_interpolation_to_compose_strings
    var x1Str = 'X_1';
    var x2Str = 'X_2';
    var x3Str = 'X_3';

    if (x1 != null) {
      x1Str = x1!.toInt().toString();
    }

    if (x2 != null) {
      x2Str = x2!.toInt().toString();
    }

    if (x3 != null) {
      x3Str = x3!.toInt().toString();
    }
    // ignore: prefer_interpolation_to_compose_strings
    return r'RFC = 10^{\beta_0} \cdot DIT^{\beta_1} \cdot CBO^{\beta_2} \cdot WMC^{\beta_3}=10^{' +
        Utils.formatNumber(coefficients.b0) +
        '} \\cdot $x1Str^{' +
        Utils.formatNumber(coefficients.b1) +
        '} \\cdot $x2Str^{' +
        Utils.formatNumber(coefficients.b2) +
        '} \\cdot $x3Str^{' +
        Utils.formatNumber(coefficients.b3) +
        '}';
  }

  Widget predictionWidget() {
    provider = context.watch<RegressionModelProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetricsCard(
          value: getPredictionEquation(provider.coefficients),
          isEquation: true,
        ),
        const SizedBox(height: 32),
        _buildPredictionOutput(),
        const SizedBox(height: 32),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildTextField(
                  x1Controller,
                  'Enter X1 value (DIT)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  x2Controller,
                  'Enter X2 value (CBO)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  x3Controller,
                  'Enter X3 value (WMC)',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          predictionWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
