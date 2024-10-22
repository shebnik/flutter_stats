import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/outliers_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:provider/provider.dart';

class DSquareTSView extends StatelessWidget {
  const DSquareTSView({super.key});

  @override
  Widget build(BuildContext context) {
    final mahalanobisDistances = context.select(
      (OutliersProvider provider) => provider.mahalanobisDistances,
    );
    final testStatistics = context.select(
      (OutliersProvider provider) => provider.testStatistics,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Mahalanobis Square Distances and Test Statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Table(
                border: TableBorder.all(),
                children: [
                  const TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text('№'),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text('D^2'),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text('TS'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var i = 0; i < mahalanobisDistances.length; i++)
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text((i + 1).toString()),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                Utils.formatNumber(mahalanobisDistances[i]),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                Utils.formatNumber(testStatistics[i]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
