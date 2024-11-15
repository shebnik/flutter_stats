import 'package:flutter/material.dart';
import 'package:flutter_stats/models/intervals/intervals.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/router/scaffold_nav.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/views/metrics_view.dart';
import 'package:flutter_stats/views/outliers_view.dart';
import 'package:flutter_stats/views/prediction_view.dart';
import 'package:flutter_stats/views/regression_view.dart';
import 'package:flutter_stats/views/settings_view.dart';
import 'package:flutter_stats/widgets/intervals_table.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

enum AppRouteType {
  projects(icon: Icons.dataset_outlined, selectedIcon: Icons.dataset),
  outliers(icon: Icons.circle_outlined, selectedIcon: Icons.circle),
  regression(icon: Icons.show_chart, selectedIcon: Icons.trending_up),
  prediction(icon: Icons.analytics_outlined, selectedIcon: Icons.analytics);

  const AppRouteType({
    required this.icon,
    required this.selectedIcon,
  });

  final IconData icon;
  final IconData selectedIcon;
}

class AppRoute {
  AppRoute(this.type, this.view, {this.childRoutes = const []});
  final AppRouteType type;
  final Widget view;
  final List<GoRoute> childRoutes;

  String get name => type.name;
  String get path => '/$name';
  Page<dynamic> get page => NoTransitionPage(child: view);

  String get label => type.name.capitalize();
  IconData get icon => type.icon;
  IconData get selectedIcon => type.selectedIcon;
}

final List<AppRoute> appRoutes = [
  AppRoute(AppRouteType.projects, const MetricsView()),
  AppRoute(AppRouteType.outliers, const OutliersView()),
  AppRoute(AppRouteType.regression, const RegressionView()),
  AppRoute(
    AppRouteType.prediction,
    const PredictionView(),
    childRoutes: [
      GoRoute(
        name: 'intervals',
        path: '/intervals',
        pageBuilder: (context, state) => NoTransitionPage(
          child: IntervalsTable(
            intervals:
                context.read<RegressionModelProvider>().model?.intervals ??
                    Intervals.empty(),
          ),
        ),
      ),
    ],
  ),
];

GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  initialLocation: appRoutes.first.path,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: _buildBranches(),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SettingsView(),
      ),
    ),
  ],
  errorBuilder: (context, state) => const _ErrorView(),
);

List<StatefulShellBranch> _buildBranches() {
  return appRoutes.map((route) {
    return StatefulShellBranch(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: route.name),
      routes: [
        GoRoute(
          path: route.path,
          name: route.name,
          pageBuilder: (context, state) => route.page,
          routes: route.childRoutes,
        ),
      ],
    );
  }).toList();
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(appRoutes.first.path),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
