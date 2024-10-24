import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/widgets/text_switch.dart';
import 'package:provider/provider.dart';

class SettingsChecks extends StatelessWidget {
  const SettingsChecks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer<ProjectsProvider>(
        builder: (context, projectsProvider, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextSwitch(
              caption: 'Use relative NOC\n(Divide all metrics by NOC)',
              value: projectsProvider.useRelativeNOC,
              onChanged: () {
                projectsProvider
                    .setUseRelativeNOC(!projectsProvider.useRelativeNOC);
              },
            ),
            const SizedBox(height: 16),
            TextSwitch(
              caption: 'Use sigma',
              value: projectsProvider.useSigma,
              onChanged: () {
                projectsProvider.useSigma = !projectsProvider.useSigma;
              },
            ),
          ],
        ),
      ),
    );
  }
}
