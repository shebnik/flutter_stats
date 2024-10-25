import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:flutter_stats/widgets/styled_button.dart';
import 'package:provider/provider.dart';

class AppContent extends StatelessWidget {
  const AppContent({
    required this.body,
    super.key,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final dataHandler = Provider.of<DataHandler>(context);
    return Consumer<ProjectsProvider>(
      builder: (context, value, child) {
        if (value.projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledButton(
                  text: 'Load Data File',
                  onPressed: () => dataHandler.loadDataFile(
                    context,
                    retrieveCached: false,
                  ),
                  svgPicturePath: excelSVG,
                ),
                const SizedBox(height: 8),
                TextButton(
                  child: const Text('or Use Example Dataset'),
                  onPressed: () => dataHandler.loadDataFile(
                    context,
                    useAssetDataset: true,
                    retrieveCached: false,
                  ),
                ),
              ],
            ),
          );
        }
        return body;
      },
    );
  }
}
