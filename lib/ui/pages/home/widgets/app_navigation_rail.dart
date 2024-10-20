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
        onPressed: () => context.read<Utils>().loadDataFile(context),
        tooltip: 'Load CSV file',
        child: const Icon(Icons.add),
      ),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.dataset_outlined),
          selectedIcon: Icon(Icons.dataset),
          label: Text('Metrics'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.circle_outlined),
          selectedIcon: Icon(Icons.circle),
          label: Text('Outliers'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.show_chart),
          selectedIcon: Icon(Icons.trending_up),
          label: Text('Regression'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: Text('Prediction'),
        ),
        // TODO(dev): Fix the following destinations
        // NavigationRailDestination(
        //   icon: Icon(Icons.settings_ethernet_outlined),
        //   selectedIcon: Icon(Icons.settings_ethernet_rounded),
        //   label: Text('Intervals'),
        // ),
        // NavigationRailDestination(
        //   icon: Icon(Icons.scatter_plot_outlined),
        //   selectedIcon: Icon(Icons.scatter_plot),
        //   label: Text('Scatter Plot'),
        // ),
      ],
    );
  }
}
