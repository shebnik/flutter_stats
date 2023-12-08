import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:provider/provider.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.index,
    required this.title,
    this.subtitle,
    this.isRemovable = false,
    this.onTap,
    super.key,
  });

  final int index;
  final String title;
  final String? subtitle;
  final bool isRemovable;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${index + 1}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      title: Text(
        title,
      ),
      onTap: onTap,
      trailing: isRemovable
          ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<RegressionModelProvider>().removeMetric(index);
              },
            )
          : null,
    );
  }
}
