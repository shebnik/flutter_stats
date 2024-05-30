import 'package:flutter/material.dart';
import 'package:flutter_stats/ui/pages/home/home_page.dart';
import 'package:go_router/go_router.dart';

GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter router = GoRouter(
  initialLocation: '/home',
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: HomePage(),
      ),
    ),
  ],
);
