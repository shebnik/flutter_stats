import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/outliers_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/router/router.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final regressionModelProvider = RegressionModelProvider();
    return MultiProvider(
      providers: [
        Provider(create: (_) => DataHandler()),
        Provider(create: (_) => Utils()),
        ChangeNotifierProvider(
          create: (_) => OutliersProvider(regressionModelProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => regressionModelProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => MetricsNavigationProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final isDark =
              PlatformDispatcher.instance.platformBrightness == Brightness.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: isDark
                ? SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    systemNavigationBarColor: Colors.black,
                  )
                : SystemUiOverlayStyle.light,
            child: ResponsiveBreakpoints.builder(
              breakpoints: [
                const Breakpoint(start: 0, end: 800, name: MOBILE),
                const Breakpoint(
                  start: 801,
                  end: double.infinity,
                  name: DESKTOP,
                ),
              ],
              child: MaterialApp.router(
                theme: isDark
                    ? ThemeData.dark(
                        useMaterial3: true,
                      ).copyWith(
                        colorScheme: ColorScheme.fromSeed(
                          brightness: Brightness.dark,
                          seedColor: Colors.blue,
                        ),
                        scaffoldBackgroundColor: const Color(0xFF121212),
                        indicatorColor: Colors.white,
                        cardColor: const Color(0xFF1E1E1E),
                      )
                    : ThemeData.light(
                        useMaterial3: true,
                      ).copyWith(
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: Colors.blue,
                        ),
                        scaffoldBackgroundColor: const Color(0xFFEFEFEF),
                        indicatorColor: Colors.black,
                      ),
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.unknown,
                  },
                ),
                title: appName,
                debugShowCheckedModeBanner: false,
                routerConfig: router,
              ),
            ),
          );
        },
      ),
    );
  }
}
