import 'package:flutter/material.dart';
import 'package:flutter_stats/router/app_content.dart';
import 'package:flutter_stats/router/router.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:flutter_stats/widgets/scroll_to_top.dart';
import 'package:provider/provider.dart';

class ScaffoldWithNavigationDrawer extends StatefulWidget {
  const ScaffoldWithNavigationDrawer({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<ScaffoldWithNavigationDrawer> createState() =>
      _ScaffoldWithNavigationDrawerState();
}

class _ScaffoldWithNavigationDrawerState
    extends State<ScaffoldWithNavigationDrawer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: widget.selectedIndex,
            onDestinationSelected: widget.onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            groupAlignment: 0,
            useIndicator: true,
            leading: FloatingActionButton(
              elevation: 0,
              onPressed: () =>
                  context.read<DataHandler>().loadDataFile(context),
              tooltip: 'Load CSV file',
              child: const Icon(Icons.add),
            ),
            destinations: appRoutes
                .map(
                  (route) => NavigationRailDestination(
                    icon: Icon(route.icon),
                    selectedIcon: Icon(route.selectedIcon),
                    label: Text(route.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: AppContent(
              body: widget.body,
            ),
          ),
        ],
      ),
      floatingActionButton: const ScrollToTop(),
    );
  }
}
