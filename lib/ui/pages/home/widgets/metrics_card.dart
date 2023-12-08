import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/app_theme_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:provider/provider.dart';

class MetricsCard extends StatelessWidget {
  const MetricsCard({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Utils.copyToClipboard(value, context),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: context.read<AppThemeProvider>().isDarkMode
                ? Colors.grey[900]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(width: 5),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
