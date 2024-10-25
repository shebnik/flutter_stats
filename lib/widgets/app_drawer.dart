import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<MetricsNavigationProvider>(
        builder: (context, metricsProvider, child) =>
            Consumer<ProjectsProvider>(
          builder: (context, projectsProvider, child) => Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF042B59), // Flutter Navy
                      Color(0xFF0553B1), // Flutter Blue
                    ],
                  ),
                ),
                child: SizedBox.expand(
                  child: Text(
                    'Metrics',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              ...List.generate(metricsNavigationRoutes.length, (i) {
                final route = metricsNavigationRoutes[i];
                return ListTile(
                  selected: metricsProvider.type == route,
                  title: Text(
                    route.label,
                    style: TextStyle(
                      fontWeight: metricsProvider.type == route
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    metricsProvider.type = route;
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
