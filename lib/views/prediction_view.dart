import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/settings/csv_alias/csv_alias.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/providers/settings_provider.dart';
import 'package:flutter_stats/services/equation_formatter.dart';
import 'package:flutter_stats/services/regression_model.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/widgets/metrics_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PredictionView extends StatefulWidget {
  const PredictionView({super.key});

  @override
  State<PredictionView> createState() => _PredictionViewState();
}

class _PredictionViewState extends State<PredictionView> {
  late RegressionModel model;

  final yController = TextEditingController();
  final x1Controller = TextEditingController();
  final x2Controller = TextEditingController();
  final x3Controller = TextEditingController();
  String? yError;
  String? x1Error;
  String? x2Error;
  String? x3Error;

  num? _prediction;
  double? y;
  double? x1;
  double? x2;
  double? x3;

  bool hasX2 = true;
  bool hasX3 = true;

  MinMaxFactors? minMaxFactors;

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? errorText,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
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

  Widget _buildPredictionOutput(CSVAlias csvAlias) {
    if (_prediction != null &&
        !_prediction!.isNaN &&
        !_prediction!.isInfinite &&
        _prediction! > 0) {
      return Row(
        children: [
          Expanded(
            child: MetricsCard(
              title: 'Ŷ (${csvAlias.y})',
              value: Utils.formatNumber(_prediction?.toDouble() ?? 0),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: FutureBuilder(
              future: model.calculateProjectQuality(
                predictedY: _prediction!.toDouble(),
                y: y!,
                x: [
                  if (x1 != null) x1!,
                  if (x2 != null) x2!,
                  if (x3 != null) x3!,
                ],
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final quality = snapshot.data ?? QualityTypes.unknown;
                  return MetricsCard(
                    title: 'Project Quality',
                    value: quality.name.capitalize(),
                    valueColor: quality.color,
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
    y = double.tryParse(yController.text);
    x1 = double.tryParse(x1Controller.text);
    if (hasX2) {
      x2 = double.tryParse(x2Controller.text);
    }
    if (hasX3) {
      x3 = double.tryParse(x3Controller.text);
    }
    if (x1 == null || (hasX2 && x2 == null) || (hasX3 && x3 == null)) {
      _prediction = null;
      x1Error = null;
      x2Error = null;
      x3Error = null;
      setState(() {});
      return;
    }
    final x = [x1 ?? 0];
    if (hasX2) {
      x.add(x2 ?? 0);
    }
    if (hasX3) {
      x.add(x3 ?? 0);
    }
    _prediction = model.predictY(x);
    final csvAlias =
        Provider.of<SettingsProvider>(context, listen: false).settings.csvAlias;

    if (minMaxFactors != null) {
      if (y! > minMaxFactors!.y.max || y! < minMaxFactors!.y.min) {
        yError = '${csvAlias.y} should be between '
            '${Utils.formatNumber(minMaxFactors!.y.min)}'
            ' and ${Utils.formatNumber(minMaxFactors!.y.max)}';
      } else {
        yError = null;
      }

      if (x1! > minMaxFactors!.x1.max || x1! < minMaxFactors!.x1.min) {
        x1Error = '${csvAlias.x1} should be between '
            '${Utils.formatNumber(minMaxFactors!.x1.min)}'
            ' and ${Utils.formatNumber(minMaxFactors!.x1.max)}';
      } else {
        x1Error = null;
      }

      if (minMaxFactors!.x2 != null) {
        if (x2! > minMaxFactors!.x2!.max || x2! < minMaxFactors!.x2!.min) {
          x2Error = '${csvAlias.x2} should be between '
              '${Utils.formatNumber(minMaxFactors!.x2!.min)}'
              ' and ${Utils.formatNumber(minMaxFactors!.x2!.max)}';
        } else {
          x2Error = null;
        }
      }

      if (minMaxFactors!.x3 != null) {
        if (x3! > minMaxFactors!.x3!.max || x3! < minMaxFactors!.x3!.min) {
          x3Error = '${csvAlias.x3} should be between '
              '${Utils.formatNumber(minMaxFactors!.x3!.min)}'
              ' and ${Utils.formatNumber(minMaxFactors!.x3!.max)}';
        } else {
          x3Error = null;
        }
      }
    }

    setState(() {});
  }

  Widget yField(SettingsProvider provider) => _buildTextField(
        yController,
        'Enter Y (${provider.settings.csvAlias.y})',
        yError,
      );

  Widget x1Field(SettingsProvider provider) => _buildTextField(
        x1Controller,
        'Enter X1 (${provider.settings.csvAlias.x1})',
        x1Error,
      );

  Widget? x2Field(SettingsProvider provider) => provider.hasX2
      ? _buildTextField(
          x2Controller,
          'Enter X2 (${provider.settings.csvAlias.x2})',
          x2Error,
        )
      : null;

  Widget? x3Field(SettingsProvider provider) => provider.hasX3
      ? _buildTextField(
          x3Controller,
          'Enter X3 (${provider.settings.csvAlias.x3})',
          x3Error,
        )
      : null;

  Widget predictionWidget() {
    return Consumer<RegressionModelProvider>(
      builder: (context, provider, child) {
        if (provider.model == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        model = provider.model!;
        return Consumer<SettingsProvider>(
          builder: (context, provider, _) {
            final yField = this.yField(provider);
            final x1Field = this.x1Field(provider);
            final x2Field = this.x2Field(provider);
            final x3Field = this.x3Field(provider);
            hasX2 = provider.hasX2;
            hasX3 = provider.hasX3;
            return ListView(
              shrinkWrap: true,
              children: [
                MetricsCard(
                  value: EquationFormatter.getPredictionEquation(
                    model.coefficients,
                    isMobile: ResponsiveBreakpoints.of(context).isMobile,
                    xValues: [x1, x2, x3],
                    alias: provider.settings.csvAlias,
                  ),
                  isEquation: true,
                ),
                const SizedBox(height: 32),
                if (ResponsiveBreakpoints.of(context).isDesktop)
                  Row(
                    children: [
                      Expanded(child: yField),
                      const SizedBox(width: 16),
                      Expanded(child: x1Field),
                      if (x2Field != null) ...[
                        const SizedBox(width: 16),
                        Expanded(child: x2Field),
                      ],
                      if (x3Field != null) ...[
                        const SizedBox(width: 16),
                        Expanded(child: x3Field),
                      ],
                    ],
                  )
                else
                  Column(
                    children: [
                      yField,
                      const SizedBox(height: 16),
                      x1Field,
                      if (x2Field != null) ...[
                        const SizedBox(height: 16),
                        x2Field,
                      ],
                      if (x3Field != null) ...[
                        const SizedBox(height: 16),
                        x3Field,
                      ],
                    ],
                  ),
                const SizedBox(height: 16),
                _buildPredictionOutput(provider.settings.csvAlias),
                const SizedBox(height: 32),
                _availableFactorsRange(provider),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => context.pushNamed('intervals'),
                  child: const Text('Show Intervals'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _availableFactorsRange(SettingsProvider provider) {
    minMaxFactors = model.minMaxFactors;
    if (minMaxFactors == null) {
      return const SizedBox.shrink();
    }
    final minY = Utils.formatNumber(minMaxFactors!.y.min);
    final maxY = Utils.formatNumber(minMaxFactors!.y.max);

    final minX1 = Utils.formatNumber(minMaxFactors!.x1.min);
    final maxX1 = Utils.formatNumber(minMaxFactors!.x1.max);

    String? minX2;
    String? maxX2;
    if (provider.hasX2 && minMaxFactors!.x2 != null) {
      minX2 = Utils.formatNumber(minMaxFactors!.x2!.min);
      maxX2 = Utils.formatNumber(minMaxFactors!.x2!.max);
    }

    String? minX3;
    String? maxX3;
    if (provider.hasX3 && minMaxFactors!.x3 != null) {
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
                title: provider.settings.csvAlias.y,
                value: '[$minY - $maxY]',
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: MetricsCard(
                title: provider.settings.csvAlias.x1,
                value: '[$minX1 - $maxX1]',
              ),
            ),
            if (provider.hasX2 && minMaxFactors!.x2 != null) ...[
              const SizedBox(width: 16),
              Flexible(
                child: MetricsCard(
                  title: provider.settings.csvAlias.x2,
                  value: '[$minX2 - $maxX2]',
                ),
              ),
            ],
            if (provider.hasX3 && minMaxFactors!.x3 != null) ...[
              const SizedBox(width: 16),
              Flexible(
                child: MetricsCard(
                  title: provider.settings.csvAlias.x3,
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
