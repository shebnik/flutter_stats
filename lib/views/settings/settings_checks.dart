import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/providers/settings_provider.dart';
import 'package:flutter_stats/widgets/text_switch.dart';
import 'package:provider/provider.dart';

class SettingsChecks extends StatelessWidget {
  const SettingsChecks({super.key});

  @override
  Widget build(BuildContext context) {
    final projectsProvider =
        Provider.of<ProjectsProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextSwitch(
              caption: 'Use relative NOC (Divide all metrics by NOC)',
              subtitle: 'Please note that this will detect new outliers'
                  ' and refit the model',
              value: settings.useRelativeNOC,
              onChanged: () {
                settings.useRelativeNOC = !settings.useRelativeNOC;
                projectsProvider.useRelativeNOC(
                  useRelativeNOC: settings.useRelativeNOC,
                );
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
          ],
        ),
      ),
    );
  }
}
