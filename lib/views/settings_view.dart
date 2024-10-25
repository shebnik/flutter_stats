import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/providers/settings_provider.dart';
import 'package:flutter_stats/widgets/alias_selector.dart';
import 'package:flutter_stats/widgets/text_switch.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
                      onSelected: (value) {
                        settings.x1Alias = value ?? '';
                      },
                    ),
                    AliasSelector(
                      label: 'X2',
                      alias: settings.x2Alias,
                      isEnabled: settings.hasX2,
                      toggleEnabled: () {
                        settings.hasX2 = !settings.hasX2;
                      },
                      onSelected: (value) {
                        settings.x2Alias = value ?? '';
                      },
                    ),
                    AliasSelector(
                      label: 'X3',
                      alias: settings.x3Alias,
                      isEnabled: settings.hasX3,
                      toggleEnabled: () {
                        settings.hasX3 = !settings.hasX3;
                      },
                      onSelected: (value) {
                        settings.x3Alias = value ?? '';
                      },
                    ),
                    AliasSelector(
                      label: 'Y',
                      alias: settings.yAlias,
                      onSelected: (value) {
                        settings.yAlias = value ?? '';
                      },
                    ),
                    AliasSelector(
                      label: 'NOC',
                      alias: settings.nocAlias,
                      isEnabled: settings.hasNOC,
                      toggleEnabled: () {
                        settings.hasNOC = !settings.hasNOC;
                        if (!settings.hasNOC) {
                          settings.useRelativeNOC = false;
                        }
                      },
                      onSelected: (value) {
                        settings.nocAlias = value ?? '';
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                    onChanged: () {
                      settings.useRelativeNOC = !settings.useRelativeNOC;
                      projectsProvider.useRelativeNOC(
                        useRelativeNOC: settings.useRelativeNOC,
                      );
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
