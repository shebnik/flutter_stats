import 'package:flutter/material.dart';
import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:flutter_stats/widgets/metrics_card.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class RegressionView extends StatefulWidget {
  const RegressionView({super.key});

  @override
  State<RegressionView> createState() => _RegressionViewState();
}

class _RegressionViewState extends State<RegressionView> {
  bool useSigma = false;

  String getLinearEquation(Coefficients coefficients) {
    final b0 = Utils.formatNumber(coefficients.b[0]);
    dynamic b1 = coefficients.b[1];
    dynamic b2 = coefficients.b[2];
    dynamic b3 = coefficients.b[3];

    if ((b1 as double) < 0) {
      b1 = ' - ${Utils.formatNumber(b1.abs())}';
    } else {
      b1 = ' + ${Utils.formatNumber(b1)}';
    }

    if ((b2 as double) < 0) {
      b2 = ' - ${Utils.formatNumber(b2.abs())}';
    } else {
      b2 = ' + ${Utils.formatNumber(b2)}';
    }

    if ((b3 as double) < 0) {
      b3 = ' - ${Utils.formatNumber(b3.abs())}';
    } else {
      b3 = ' + ${Utils.formatNumber(b3)}';
    }

    // ignore: prefer_interpolation_to_compose_strings
    var str = r'\hat{Z_Y} = ';
    if (ResponsiveBreakpoints.of(context).isDesktop) {
      str +=
          r'\beta_0 + \beta_1 \cdot Z_{X_1} + \beta_2 \cdot Z_{X_2} + \beta_3 \cdot Z_{X_3}';
      if (useSigma) {
        str += r' + \sigma =';
      } else {
        str += '=';
      }
    }
    str += b0 +
        (b1 as String) +
        r' \cdot Z_{X_1}' +
        (b2 as String) +
        r' \cdot Z_{X_2}' +
        (b3 as String) +
        r' \cdot Z_{X_3}';
    if (useSigma) {
      str += ' + ${Utils.formatNumber(coefficients.sigma)}';
    }
    return str;
  }

  String getNonlinearEquation(Coefficients coefficients) {
    final b0 = Utils.formatNumber(coefficients.b[0]);
    final b1 = Utils.formatNumber(coefficients.b[1]);
    final b2 = Utils.formatNumber(coefficients.b[2]);
    final b3 = Utils.formatNumber(coefficients.b[3]);
    var str = r'\hat{Y} = ';
    if (ResponsiveBreakpoints.of(context).isDesktop) {
      str +=
          r'10^{\beta_0} \cdot X_1^{\beta_1} \cdot X_2^{\beta_2} \cdot X_3^{\beta_3}';
      if (useSigma) {
        str += r' + \sigma =';
      } else {
        str += '=';
      }
    }
    // ignore: prefer_interpolation_to_compose_strings
    str += '10^{' +
        b0 +
        r'} \cdot X_1^{' +
        b1 +
        r'} \cdot X_2^{' +
        b2 +
        r'} \cdot X_3^{' +
        b3 +
        '}';
    if (useSigma) {
      str += ' + ${Utils.formatNumber(coefficients.sigma)}';
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final model = context.watch<RegressionModelProvider>().model;
    if (model == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final provider = context.watch<ProjectsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        useSigma = provider.useSigma;
      });
    });

    final regressionInfoWidgets = [
      Flexible(
        child: MetricsCard(
          title: 'Train data points',
          value: model.trainProjects.length.toString(),
        ),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: MetricsCard(
          title: 'Test data points',
          value: model.testProjects.length.toString(),
        ),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: MetricsCard(
          title: 'Outliers removed',
          value: provider.outliersRemoved.toString(),
        ),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: MetricsCard(
          title: 'Outliers left',
          value: provider.outliers.length.toString(),
        ),
      ),
    ];

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Text(
                'Regression Analysis',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 20),
            ],
            MetricsCard(
              title: 'Linear Regression',
              value: getLinearEquation(model.coefficients),
              isEquation: true,
            ),
            const SizedBox(height: 20),
            MetricsCard(
              title: 'Nonlinear Regression Equation',
              value: getNonlinearEquation(model.coefficients),
              isEquation: true,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: regressionInfoWidgets,
            ),
            const SizedBox(height: 20),
            Text(
              'Nonlinear Regression Model Quality',
              style: isMobile
                  ? const TextStyle(fontSize: 16)
                  : Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 8 : 16),
            _ModelQualityWidget(
              modelQuality: model.modelQuality,
            ),
            const SizedBox(height: 16),
            Text(
              'Test Model Quality (${model.testProjects.length} data points)',
              style: isMobile
                  ? const TextStyle(fontSize: 16)
                  : Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 8 : 16),
            _ModelQualityWidget(
              modelQuality: model.testModelQuality,
            ),
            const SizedBox(height: 16),
            const Text(
              'Good model indicators:\n'
              'R² > 0.7\n'
              'MMRE < 0.25\n'
              'PRED(0.25) > 0.75',
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelQualityWidget extends StatelessWidget {
  const _ModelQualityWidget({
    required this.modelQuality,
  });

  final ModelQuality modelQuality;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Utils.copyToClipboard(modelQuality.toString(), context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'R² = ',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                    ),
                  ),
                  Text(
                    Utils.formatNumber(modelQuality.rSquared),
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                      color: Utils.getColor(
                        ModelQualityTypes.rSquared,
                        modelQuality.rSquared,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isMobile) const SizedBox(width: 32),
              Row(
                children: [
                  Text(
                    'MMRE = ',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                    ),
                  ),
                  Text(
                    Utils.formatNumber(modelQuality.mmre),
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                      color: Utils.getColor(
                        ModelQualityTypes.mmre,
                        modelQuality.mmre,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isMobile) const SizedBox(width: 32),
              Row(
                children: [
                  Text(
                    'PRED(0.25) = ',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                    ),
                  ),
                  Text(
                    Utils.formatNumber(modelQuality.pred),
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                      color: Utils.getColor(
                        ModelQualityTypes.pred,
                        modelQuality.pred,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
