import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/providers/settings_provider.dart';
import 'package:flutter_stats/services/algebra.dart';
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

  MinMaxFactors? minMaxFactors;
  String? x1Error;
  String? x2Error;
  String? x3Error;

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? errorText,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        counterText: ' ',
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
      return Row(
        children: [
          Expanded(
            child: MetricsCard(
              title: 'Y Prediction (RFC)',
              value: formatted.replaceAll(',', ' '),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: FutureBuilder(
              future: model.calculateProjectQuality(
                Algebra().logBase10(
                  _prediction!.toDouble(),
                ),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final quality = Utils.formatNumber(snapshot.data! * 100);
                  return MetricsCard(
                    title: 'Project Quality',
                    value: '$quality%',
                    valueColor: Utils.getQualityColor(
                      ModelQualityTypes.project,
                      snapshot.data!,
                    ),
                  );
                }
                return const Text('Error calculating project quality');
              },
            ),
          ),
        ],
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
      x1Error = null;
      x2Error = null;
      x3Error = null;
      setState(() {});
      return;
    }
    _prediction = model.predictY([x1!, x2!, x3!]);

    if (minMaxFactors != null) {
      if (x1! > minMaxFactors!.x1.max || x1! < minMaxFactors!.x1.min) {
        x1Error = 'DIT should be between '
            '${Utils.formatNumber(minMaxFactors!.x1.min)}'
            ' and ${Utils.formatNumber(minMaxFactors!.x1.max)}';
      } else {
        x1Error = null;
      }
      if (minMaxFactors!.x2 != null) {
        if (x2! > minMaxFactors!.x2!.max || x2! < minMaxFactors!.x2!.min) {
          x2Error = 'CBO should be between '
              '${Utils.formatNumber(minMaxFactors!.x2!.min)}'
              ' and ${Utils.formatNumber(minMaxFactors!.x2!.max)}';
        } else {
          x2Error = null;
        }
      }

      if (minMaxFactors!.x3 != null) {
        if (x3! > minMaxFactors!.x3!.max || x3! < minMaxFactors!.x3!.min) {
          x3Error = 'WMC should be between '
              '${Utils.formatNumber(minMaxFactors!.x3!.min)}'
              ' and ${Utils.formatNumber(minMaxFactors!.x3!.max)}';
        } else {
          x3Error = null;
        }
      }
    }

    setState(() {});
  }

  String getPredictionEquation(
    Coefficients coefficients, {
    bool useSigma = false,
  }) {
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
    var str = 'RFC = ';
    if (ResponsiveBreakpoints.of(context).isDesktop) {
      if (useSigma) {
        str += r'10^{\beta_0 + \sigma}';
      } else {
        str += r'10^{\beta_0}';
      }
      str += r'\cdot DIT^{\beta_1} \cdot CBO^{\beta_2} \cdot WMC^{\beta_3} =';
    }
    if (useSigma) {
      str += '10^{${Utils.formatNumber(coefficients.b[1])} '
          '+ ${Utils.formatNumber(coefficients.sigma)}}';
    } else {
      str += '10^{${Utils.formatNumber(coefficients.b[1])}}';
    }
    return '$str \\cdot $x1Str^{${Utils.formatNumber(coefficients.b[1])}} \\cdot $x2Str^{${Utils.formatNumber(coefficients.b[2])}} \\cdot $x3Str^{${Utils.formatNumber(coefficients.b[3])}}';
  }

  Widget get x1Field => _buildTextField(
        x1Controller,
        'Enter X1 (DIT)',
        x1Error,
      );

  Widget get x2Field => _buildTextField(
        x2Controller,
        'Enter X2 (CBO)',
        x2Error,
      );

  Widget get x3Field => _buildTextField(
        x3Controller,
        'Enter X3 (WMC)',
        x3Error,
      );

  Widget predictionWidget() {
    return Consumer<RegressionModelProvider>(
      builder: (context, provider, child) {
        if (provider.model == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        model = provider.model!;
        return ListView(
          shrinkWrap: true,
          children: [
            Consumer<SettingsProvider>(
              builder: (context, provider, _) => MetricsCard(
                value: getPredictionEquation(
                  model.coefficients,
                  useSigma: provider.useSigma,
                ),
                isEquation: true,
              ),
            ),
            const SizedBox(height: 32),
            if (ResponsiveBreakpoints.of(context).isDesktop)
              Row(
                children: [
                  Expanded(child: x1Field),
                  const SizedBox(width: 16),
                  Expanded(child: x2Field),
                  const SizedBox(width: 16),
                  Expanded(child: x3Field),
                ],
              )
            else
              Column(
                children: [
                  x1Field,
                  const SizedBox(height: 16),
                  x2Field,
                  const SizedBox(height: 16),
                  x3Field,
                ],
              ),
            const SizedBox(height: 16),
            _buildPredictionOutput(),
            SizedBox(
              height: ResponsiveBreakpoints.of(context).isDesktop ? 64 : 32,
            ),
            _availableFactorsRange(),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _availableFactorsRange() {
    minMaxFactors = model.minMaxFactors;
    if (minMaxFactors == null) {
      return const SizedBox.shrink();
    }
    final minX1 = Utils.formatNumber(minMaxFactors!.x1.min);
    final maxX1 = Utils.formatNumber(minMaxFactors!.x1.max);

    String? minX2;
    String? maxX2;
    if (minMaxFactors!.x2 != null) {
      minX2 = Utils.formatNumber(minMaxFactors!.x2!.min);
      maxX2 = Utils.formatNumber(minMaxFactors!.x2!.max);
    }

    String? minX3;
    String? maxX3;
    if (minMaxFactors!.x3 != null) {
      minX3 = Utils.formatNumber(minMaxFactors!.x3!.min);
      maxX3 = Utils.formatNumber(minMaxFactors!.x3!.max);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available factors range:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: MetricsCard(
                title: 'DIT',
                value: '[$minX1 - $maxX1]',
              ),
            ),
            if (minMaxFactors!.x2 != null) ...[
              const SizedBox(width: 16),
              Flexible(
                child: MetricsCard(
                  title: 'CBO',
                  value: '[$minX2 - $maxX2]',
                ),
              ),
            ],
            if (minMaxFactors!.x3 != null) ...[
              const SizedBox(width: 16),
              Flexible(
                child: MetricsCard(
                  title: 'WMC',
                  value: '[$minX3 - $maxX3]',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            predictionWidget(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
