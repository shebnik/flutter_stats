import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/router/app_content.dart';
import 'package:flutter_stats/router/router.dart';
import 'package:flutter_stats/widgets/load_file_button.dart';
import 'package:go_router/go_router.dart';
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
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              children: [
                Expanded(
                  child: NavigationRail(
                    selectedIndex: widget.selectedIndex,
                    onDestinationSelected: widget.onDestinationSelected,
                    labelType: NavigationRailLabelType.all,
                    groupAlignment: 0,
                    useIndicator: true,
                    leading: const LoadFileButton(),
                    destinations: appRoutes.map(
                      (route) {
                        var label = route.label;
                        if (route.type == AppRouteType.outliers) {
                          final outliers =
                              context.watch<ProjectsProvider>().outliers.length;
                          if (outliers > 0) {
                            label = '$label ($outliers)';
                          }
                        }
                        return NavigationRailDestination(
                          icon: Icon(route.icon),
                          selectedIcon: Icon(route.selectedIcon),
                          label: Text(label),
                        );
                      },
                    ).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      GoRouter.of(context).push('/settings');
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: AppContent(
              body: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
