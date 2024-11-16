import 'package:flutter/material.dart';
import 'package:flutter_stats/services/outliers.dart';
import 'package:flutter_stats/widgets/projects_list.dart';
import 'package:provider/provider.dart';

class OutliersView extends StatefulWidget {
  const OutliersView({super.key});

  @override
  State<OutliersView> createState() => _OutliersViewState();
}

class _OutliersViewState extends State<OutliersView> {
  int currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Consumer<OutliersProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentPage > 1) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (currentPage > 1) {
                            setState(() {
                              currentPage--;
                            });
                          }
                        },
                      ),
                    ] else ...[
                      const SizedBox(),
                    ],
                    Text(
                      'Iteration $currentPage',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentPage < provider.iterations.length) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (currentPage < provider.iterations.length) {
                            setState(() {
                              currentPage++;
                            });
                          }
                        },
                      ),
                    ] else ...[
                      const SizedBox(),
                    ],
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: ProjectsList(
                projects: provider.iterations[currentPage - 1].projects,
                whyOutliers: provider.iterations[currentPage - 1].whyOutliers,
                key: const Key('outliers_list'),
              ),
            ),
          ],
        );
      },
    );
  }
}
