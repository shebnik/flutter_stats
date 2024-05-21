import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/providers/scroll_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/ui/pages/home/widgets/app_list_tile.dart';
import 'package:provider/provider.dart';

class TestStatisticView extends StatelessWidget {
  const TestStatisticView({super.key});

  @override
  Widget build(BuildContext context) {
    final testStatistics = context.select(
      (RegressionModelProvider provider) => provider.testStatistics,
    );
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            'Test Statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Expanded(
            child: ListView.builder(
              controller:
                  Provider.of<ScrollProvider>(context, listen: false).sc,
              itemCount: testStatistics.length,
              itemBuilder: (BuildContext context, int index) {
                final value = testStatistics[index].toString();
                return AppListTile(
                  index: index,
                  title: value,
                  onTap: () => Utils.copyToClipboard(value, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
