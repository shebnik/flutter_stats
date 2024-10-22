import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/outliers_provider.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<MetricsNavigationProvider>(
        builder: (context, provider, child) => Column(
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
                selected: provider.type == route,
                title: Text(
                  route.label,
                  style: TextStyle(
                    fontWeight: provider.type == route
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  provider.type = route;
                  Navigator.of(context).pop();
                },
              );
            }),
            const Spacer(),
            Consumer<OutliersProvider>(
              builder: (context, outliersProvider, child) =>
                  PopupMenuItem<void>(
                onTap: () {
                  outliersProvider
                      .setUseRelativeNOC(!outliersProvider.useRelativeNOC);
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: outliersProvider.useRelativeNOC,
                      onChanged: (bool? value) {
                        outliersProvider.setUseRelativeNOC(value ?? false);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Use relative NOC\n(Divide all metrics by NOC)',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
