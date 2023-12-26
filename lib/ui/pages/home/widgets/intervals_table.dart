import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_stats/models/interval/model_interval.dart';

class IntervalsTable extends StatelessWidget {
  const IntervalsTable({
    required this.headers,
    required this.intervals,
    super.key,
  });

  final List<String> headers;
  final List<ModelInterval> intervals;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: headers
              .map(
                (header) => TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
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
        ...intervals.map(
          (interval) => TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    interval.index.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    interval.calculatedValues.toStringAsFixed(6),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    interval.lowerConfidenceLimit.toStringAsFixed(6),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    interval.upperConfidenceLimit.toStringAsFixed(6),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    interval.lowerPredictionLimit.toStringAsFixed(6),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    interval.upperPredictionLimit.toStringAsFixed(6),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
