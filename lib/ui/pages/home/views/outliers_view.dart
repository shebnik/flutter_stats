import 'package:flutter/material.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/outliers_provider.dart';
import 'package:flutter_stats/ui/pages/home/widgets/projects_list.dart';
import 'package:provider/provider.dart';

class OutliersView extends StatefulWidget {
  const OutliersView({super.key});

  @override
  State<OutliersView> createState() => _OutliersViewState();
}

class _OutliersViewState extends State<OutliersView> {
  final isRemoving = ValueNotifier<bool>(false);
  late Future<List<int>> outliersIndexesFuture;
  late List<Project> metrics;

  @override
  Widget build(BuildContext context) {
    outliersIndexesFuture = context.select(
      (OutliersProvider provider) => provider.outliers,
    );
    metrics = context.select(
      (OutliersProvider provider) => provider.projects,
    );
    return FutureBuilder(
      future: outliersIndexesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final outliersIndexes = snapshot.data;
        if (outliersIndexes == null) {
          return const Center(
            child: Text('Error loading outliers'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (outliersIndexes.isEmpty) ...[
                Center(
                  child: Text(
                    'No outliers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ] else ...[
                Center(
                  child: ValueListenableBuilder(
                    valueListenable: isRemoving,
                    builder: (_, disabled, __) => ElevatedButton(
                      onPressed: disabled
                          ? null
                          : () => _removeAllClick(outliersIndexes),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Remove all outliers',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ProjectsList(
                  projects: metrics,
                  outliersIndexes: outliersIndexes,
                  key: const Key('outliers_list'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeAllClick(List<int> outliersIndexes) async {
    if (isRemoving.value) return;
    isRemoving.value = true;
    await _removeAllOutliers(outliersIndexes);
    isRemoving.value = false;
  }

  Future<void> _removeAllOutliers(List<int> outliersIndexes) async {
    final provider = context.read<OutliersProvider>()
      ..removeProjects(outliersIndexes);

    final newOutliers = await provider.outliers;
    if (newOutliers.isEmpty) {
      return;
    }
    return _removeAllOutliers(newOutliers);
  }
}
