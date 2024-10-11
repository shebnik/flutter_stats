import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/ui/pages/home/widgets/intervals_table.dart';
import 'package:provider/provider.dart';

class IntervalsView extends StatefulWidget {
  const IntervalsView({super.key});

  @override
  State<IntervalsView> createState() => _IntervalsViewState();
}

class _IntervalsViewState extends State<IntervalsView> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<RegressionModelProvider>();
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: model.linearIntervals,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    final linearIntervals = snapshot.data;
                    if (linearIntervals == null) {
                      return const Center(child: Text('No data'));
                    }
                    return IntervalsTable(
                      headers: const ['#', r'\hat{Z_Y}', ...intervalHeaders],
                      intervals: linearIntervals,
                    );
                  },
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: FutureBuilder(
                  future: model.nonLinearIntervals,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    final nonLinearIntervals = snapshot.data;
                    if (nonLinearIntervals == null) {
                      return const Center(child: Text('No data'));
                    }
                    return IntervalsTable(
                      headers: const ['#', r'\hat{Y}', ...intervalHeaders],
                      intervals: nonLinearIntervals,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
