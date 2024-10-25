import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/router/app_content.dart';
import 'package:flutter_stats/router/router.dart';
import 'package:flutter_stats/widgets/app_drawer.dart';
import 'package:flutter_stats/widgets/download_projects_button.dart';
import 'package:flutter_stats/widgets/load_file_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ScaffoldWithNavigationBar extends StatefulWidget {
  const ScaffoldWithNavigationBar({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<ScaffoldWithNavigationBar> createState() =>
      _ScaffoldWithNavigationBarState();
}

class _ScaffoldWithNavigationBarState extends State<ScaffoldWithNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final outliersProvider = context.watch<ProjectsProvider>();
    final navigationProvider = context.watch<MetricsNavigationProvider>();
    final model = context.watch<RegressionModelProvider>().model;
    String title;
    if (widget.selectedIndex == 0) {
      title = navigationProvider.type.label;
      if (model != null) {
        final route = navigationProvider.type;
        final size =
            navigationProvider.getProjects(model: model, type: route).length;
        title = '$title ($size)';
      }
    } else {
      title = appRoutes[widget.selectedIndex].label;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (widget.selectedIndex == 0 && model != null)
            DownloadProjectsButton(
              filename: navigationProvider.type.label,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              GoRouter.of(context).push('/settings');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: outliersProvider.projects.isNotEmpty && widget.selectedIndex == 0
          ? const AppDrawer()
          : null,
      body: AppContent(
        body: widget.body,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onDestinationSelected,
        destinations: appRoutes
            .map(
              (route) => NavigationDestination(
                icon: Icon(route.icon),
                selectedIcon: Icon(route.selectedIcon),
                label: route.label,
              ),
            )
            .toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const LoadFileButton(),
    );
  }
}
