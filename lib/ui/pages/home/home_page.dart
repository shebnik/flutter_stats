import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/providers/app_navigation_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/ui/pages/home/views/intervals_view.dart';
import 'package:flutter_stats/ui/pages/home/views/metrics_view.dart';
import 'package:flutter_stats/ui/pages/home/views/outliers_view.dart';
import 'package:flutter_stats/ui/pages/home/views/prediction_view.dart';
import 'package:flutter_stats/ui/pages/home/views/regression_view.dart';
import 'package:flutter_stats/ui/pages/home/views/scatter_plot_view.dart';
import 'package:flutter_stats/ui/pages/home/widgets/app_navigation_rail.dart';
import 'package:flutter_stats/ui/pages/home/widgets/styled_button.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dataHandler = DataHandler();
  final scrollController = ScrollController();
  ValueNotifier<bool> showScrollToTopButton = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset > 100) {
        showScrollToTopButton.value = true;
      } else {
        showScrollToTopButton.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBreakpoints.of(context).isMobile
          ? _buildMobileView()
          : _buildDesktopView(),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: showScrollToTopButton,
        builder: (context, value, child) {
          if (value) {
            return FloatingActionButton(
              onPressed: () => scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              child: const Icon(Icons.arrow_upward),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMobileView() {
    return _buildView();
  }

  Widget _buildDesktopView() {
    return Row(
      children: [
        const AppNavigationRail(),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Consumer<RegressionModelProvider>(
            builder: (context, value, child) {
              if (value.projects.isEmpty) {
                return Center(
                  child: StyledButton(
                    text: 'Load Data File',
                    onPressed: () =>
                        context.read<Utils>().loadDataFile(context),
                    svgPicturePath: excelSVG,
                  ),
                );
              }
              return SingleChildScrollView(
                controller: scrollController,
                child: _buildView(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildView() {
    switch (context.watch<AppNavigationProvider>().currentIndex) {
      case 0:
        return const MetricsView();
      case 1:
        return const OutliersView();
      case 2:
        return const RegressionView();
      case 3:
        return const PredictionView();
      case 4:
        return const IntervalsView();
      case 5:
        return const ScatterPlotView();
      default:
        return const MetricsView();
    }
  }
}
