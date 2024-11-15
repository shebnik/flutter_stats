import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/intervals/intervals.dart';
import 'package:flutter_stats/services/utils.dart';

class IntervalsTable extends StatelessWidget {
  const IntervalsTable({
    required this.intervals,
    super.key,
  });

  final Intervals intervals;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidence and Prediction Intervals'),
      ),
      body: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: intervalsHeaders
                  .map(
                    (header) => TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: header.contains(r'\')
                            ? Center(
                                child: Math.tex(
                                  header,
                                  mathStyle: MathStyle.text,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  textScaleFactor: 1.2,
                                ),
                              )
                            : Text(
                                header,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            for (var i = 0; i < intervals.confidenceLower.length; i++) ...[
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        (i + 1).toString(),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        Utils.formatNumber(intervals.confidenceLower[i]),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        Utils.formatNumber(intervals.confidenceUpper[i]),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        Utils.formatNumber(intervals.predictionLower[i]),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        Utils.formatNumber(intervals.predictionUpper[i]),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
