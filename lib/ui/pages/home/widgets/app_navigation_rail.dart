import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/app_navigation_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:provider/provider.dart';

class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: context.watch<AppNavigationProvider>().currentIndex,
      groupAlignment: 0,
      onDestinationSelected: context.read<AppNavigationProvider>().changeIndex,
      labelType: NavigationRailLabelType.all,
      leading: FloatingActionButton(
        elevation: 0,
        onPressed: () => context.read<Utils>().loadCsvFile(context),
        child: const Icon(Icons.add),
      ),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: Text('Metrics'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.grid_view),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: Text('Covariance Matrix'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard),
          label: Text('Mahalanobis Distances'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.science_outlined),
          selectedIcon: Icon(Icons.science),
          label: Text('Test Statistic'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.circle_outlined),
          selectedIcon: Icon(Icons.circle),
          label: Text('Outliers'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.show_chart),
          selectedIcon: Icon(Icons.trending_up),
          label: Text('Linear Regression'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.scatter_plot_outlined),
          selectedIcon: Icon(Icons.scatter_plot),
          label: Text('Scatter Plot'),
        ),
      ],
    );
  }
}
