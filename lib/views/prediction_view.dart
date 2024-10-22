import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/regression_model.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/widgets/metrics_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PredictionView extends StatefulWidget {
  const PredictionView({super.key});

  @override
  State<PredictionView> createState() => _PredictionViewState();
}

class _PredictionViewState extends State<PredictionView> {
  late RegressionModel model;

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
        title: 'Y Prediction (RFC)',
        value: formatted.replaceAll(',', ' '),
      );
    }

    return const SizedBox.shrink();
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
    _prediction = model.predictY([x1!, x2!, x3!]);
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
        Utils.formatNumber(coefficients.b[0]) +
        '} \\cdot $x1Str^{' +
        Utils.formatNumber(coefficients.b[1]) +
        '} \\cdot $x2Str^{' +
        Utils.formatNumber(coefficients.b[2]) +
        '} \\cdot $x3Str^{' +
        Utils.formatNumber(coefficients.b[3]) +
        '}';
  }

  Widget predictionWidget() {
    model = context.watch<RegressionModelProvider>().model;
    return ListView(
      shrinkWrap: true,
      children: [
        MetricsCard(
          value: getPredictionEquation(model.coefficients),
          isEquation: true,
        ),
        const SizedBox(height: 32),
        if (ResponsiveBreakpoints.of(context).isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  x1Controller,
                  'Enter X1 (DIT)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  x2Controller,
                  'Enter X2 (CBO)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  x3Controller,
                  'Enter X3 (WMC)',
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildTextField(
                x1Controller,
                'Enter X1 (DIT)',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                x2Controller,
                'Enter X2 (CBO)',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                x3Controller,
                'Enter X3 (WMC)',
              ),
            ],
          ),
        const SizedBox(height: 32),
        _buildPredictionOutput(),
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
