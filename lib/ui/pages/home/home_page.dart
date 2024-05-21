import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/app_navigation_provider.dart';
import 'package:flutter_stats/providers/app_theme_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/providers/scroll_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/ui/pages/home/views/covariance_matrix_view.dart';
import 'package:flutter_stats/ui/pages/home/views/intervals_view.dart';
import 'package:flutter_stats/ui/pages/home/views/mahalanobis_distances_view.dart';
import 'package:flutter_stats/ui/pages/home/views/metrics_view.dart';
import 'package:flutter_stats/ui/pages/home/views/outliers_view.dart';
import 'package:flutter_stats/ui/pages/home/views/regression_view.dart';
import 'package:flutter_stats/ui/pages/home/views/scatter_plot_view.dart';
import 'package:flutter_stats/ui/pages/home/views/test_statistic_view.dart';
import 'package:flutter_stats/ui/pages/home/widgets/app_navigation_rail.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dataHandler = DataHandler();
  late final scrollProvider = Provider.of<ScrollProvider>(
    context,
    listen: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Stats'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: context.read<AppThemeProvider>().toggleTheme,
            icon: context.watch<AppThemeProvider>().isDarkMode
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
          ),
        ],
      ),
      body: Row(
        children: [
          const AppNavigationRail(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Consumer<RegressionModelProvider>(
              builder: (context, value, child) {
                if (value.projects.isEmpty) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () =>
                          context.read<Utils>().loadCsvFile(context),
                      child: const Text('Load csv File'),
                    ),
                  );
                }
                return _buildView();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<ScrollProvider>(
        builder: (context, value, child) {
          if (value.showScrollToTopButton) {
            return FloatingActionButton(
              onPressed: value.scrollToTop,
              child: const Icon(Icons.arrow_upward),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildView() {
    switch (context.watch<AppNavigationProvider>().currentIndex) {
      case 0:
        return const MetricsView();
      case 1:
        return const CovarianceMatrixView();
      case 2:
        return const MahalanobisDistancesView();
      case 3:
        return const TestStatisticView();
      case 4:
        return const OutliersView();
      case 5:
        return const RegressionView();
      case 6:
        return const IntervalsView();
      case 7:
        return const ScatterPlotView();
      default:
        return const MetricsView();
    }
  }
}
