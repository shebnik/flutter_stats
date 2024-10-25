import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/providers/settings_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:flutter_stats/widgets/alias_selector.dart';
import 'package:flutter_stats/widgets/text_switch.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  Future<void> updateDataset() async {
    await context.read<DataHandler>().loadDataFile(context, promptUser: false);
  }

  @override
  Widget build(BuildContext context) {
    final projectsProvider = context.read<ProjectsProvider>();
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CSV Column Aliases',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    AliasSelector(
                      label: 'X1',
                      alias: settings.x1Alias,
                      onSelected: (value) async {
                        settings.x1Alias = value ?? '';
                        await updateDataset();
                      },
                    ),
                    AliasSelector(
                      label: 'X2',
                      alias: settings.x2Alias,
                      isEnabled: settings.hasX2,
                      toggleEnabled: () async {
                        settings.hasX2 = !settings.hasX2;
                        await updateDataset();
                      },
                      onSelected: (value) async {
                        settings.x2Alias = value ?? '';
                        await updateDataset();
                      },
                    ),
                    AliasSelector(
                      label: 'X3',
                      alias: settings.x3Alias,
                      isEnabled: settings.hasX3,
                      toggleEnabled: () async {
                        settings.hasX3 = !settings.hasX3;
                        await updateDataset();
                      },
                      onSelected: (value) async {
                        settings.x3Alias = value ?? '';
                        await updateDataset();
                      },
                    ),
                    AliasSelector(
                      label: 'Y',
                      alias: settings.yAlias,
                      onSelected: (value) async {
                        settings.yAlias = value ?? '';
                        await updateDataset();
                      },
                    ),
                    AliasSelector(
                      label: 'NOC',
                      alias: settings.nocAlias,
                      isEnabled: settings.hasNOC,
                      toggleEnabled: () async {
                        settings.hasNOC = !settings.hasNOC;
                        if (!settings.hasNOC) {
                          settings.useRelativeNOC = false;
                        }
                        await updateDataset();
                      },
                      onSelected: (value) async {
                        settings.nocAlias = value ?? '';
                        await updateDataset();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextSwitch(
                  caption: 'Divide Y by 1000',
                  value: settings.useYInThousands,
                  onChanged: () async {
                    settings.useYInThousands = !settings.useYInThousands;
                    await updateDataset();
                  },
                ),
                const SizedBox(height: 16),
                TextSwitch(
                  caption: 'Use Prediction Intervals to detect outliers upon'
                      ' with Mahalanobis distances',
                  value: settings.includeIntervalsMethod,
                  onChanged: () async {
                    settings.includeIntervalsMethod =
                        !settings.includeIntervalsMethod;
                    await updateDataset();
                  },
                ),
                const SizedBox(height: 16),
                TextSwitch(
                  caption: 'Use sigma',
                  value: settings.useSigma,
                  onChanged: () {
                    settings.useSigma = !settings.useSigma;
                    projectsProvider.refitModelWithSigma(
                      useSigma: settings.useSigma,
                    );
                  },
                ),
                if (settings.hasNOC) ...[
                  const SizedBox(height: 16),
                  TextSwitch(
                    caption: 'Use relative NOC (Divide all metrics by NOC)',
                    subtitle: 'Please note that this will reset model'
                        ' and detect new outliers',
                    value: settings.useRelativeNOC,
                    onChanged: () async {
                      settings.useRelativeNOC = !settings.useRelativeNOC;
                      projectsProvider.useRelativeNOC(
                        useRelativeNOC: settings.useRelativeNOC,
                      );
                      await updateDataset();
                    },
                  ),
                ],
                SizedBox(height: aliases.length / 2 * 52),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
