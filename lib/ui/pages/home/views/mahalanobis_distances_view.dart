import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/ui/pages/home/widgets/app_list_tile.dart';
import 'package:provider/provider.dart';

class MahalanobisDistancesView extends StatelessWidget {
  const MahalanobisDistancesView({super.key});

  @override
  Widget build(BuildContext context) {
    final mahalanobisDistances = context.select(
      (RegressionModelProvider provider) => provider.mahalanobisDistances,
    );
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            'Mahalanobis Distances',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mahalanobisDistances.length,
              itemBuilder: (BuildContext context, int index) {
                final value = mahalanobisDistances[index].toString();
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
