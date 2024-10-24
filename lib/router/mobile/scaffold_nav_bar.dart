import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/router/app_content.dart';
import 'package:flutter_stats/router/router.dart';
import 'package:flutter_stats/widgets/app_drawer.dart';
import 'package:flutter_stats/widgets/app_header.dart';
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
    return Scaffold(
      appBar: outliersProvider.projects.isNotEmpty && widget.selectedIndex == 0
          ? const AppHeader()
          : null,
      drawer: const AppDrawer(),
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
      // floatingActionButtonLocation: 
      // FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => context.read<DataHandler>().loadDataFile(context),
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
