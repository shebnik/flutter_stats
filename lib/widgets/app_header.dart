import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/widgets/download_projects_button.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<MetricsNavigationProvider>();
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final model = context.watch<RegressionModelProvider>().model;
    var title = navigationProvider.type.label;
    if (model != null) {
      final route = navigationProvider.type;
      final size =
          navigationProvider.getProjects(model: model, type: route).length;
      title += ' ($size)';
    }
    return AppBar(
      centerTitle: !isMobile,
      title: Text(title),
      actions: [
        DownloadProjectsButton(
          filename: navigationProvider.type.label,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
