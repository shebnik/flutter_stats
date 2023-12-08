import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/app_navigation_provider.dart';
import 'package:flutter_stats/providers/app_theme_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/ui/pages/home/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => DataHandler(),
        ),
        Provider(
          create: (_) => Utils(),
        ),
        ChangeNotifierProvider(
          create: (_) => RegressionModelProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppNavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppThemeProvider(context),
        ),

      ],
      child: Builder(
        builder: (context) => MaterialApp(
          theme: ThemeData(
            brightness: context.watch<AppThemeProvider>().isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
        ),
      ),
    );
  }
}
