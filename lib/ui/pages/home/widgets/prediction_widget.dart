import 'package:flutter/material.dart';
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
  final textController = TextEditingController();
  double? _prediction;

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegressionModelProvider>();
    final b0 = provider.coefficients[0];
    final b1 = provider.coefficients[1];
    return Column(
      children: [
        _buildPredictionOutput(),
        TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter X value (Number of Classes)',
          ),
          onChanged: (_) {
            final x = double.tryParse(textController.text) ?? 0;
            _prediction = b0 + b1 * x * 100;
            setState(() {});
          },
        ),
      ],
    );
  }
}
