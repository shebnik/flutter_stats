import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/widgets/projects_list.dart';
import 'package:provider/provider.dart';

class OutliersView extends StatefulWidget {
  const OutliersView({super.key});

  @override
  State<OutliersView> createState() => _OutliersViewState();
}

class _OutliersViewState extends State<OutliersView> {
  final isRemoving = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsProvider>(
      builder: (context, provider, _) {
        if (provider.outliers.isEmpty) {
          return Center(
            child: Text(
              'No outliers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ValueListenableBuilder(
                    valueListenable: isRemoving,
                    builder: (_, disabled, __) => ElevatedButton(
                      onPressed:
                          disabled ? null : () => _removeAllClick(provider),
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
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(top: 16),
            ),
            SliverFillRemaining(
              child: ProjectsList(
                projects: provider.projects,
                outliersIndexes: provider.outliers,
                key: const Key('outliers_list'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeAllClick(ProjectsProvider provider) async {
    if (isRemoving.value) return;
    isRemoving.value = true;
    try {
      await _removeAllOutliers(provider);
    } finally {
      isRemoving.value = false;
    }
  }

  Future<void> _removeAllOutliers(ProjectsProvider provider) async {
    await provider.removeProjects(
      provider.outliers,
    );

    if (provider.outliers.isEmpty) {
      return;
    }
    return _removeAllOutliers(provider);
  }
}
