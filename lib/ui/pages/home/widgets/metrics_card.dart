import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_stats/providers/app_theme_provider.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:provider/provider.dart';

class MetricsCard extends StatelessWidget {
  const MetricsCard({
    required this.title,
    required this.value,
    this.isEquation = false,
    super.key,
  });

  final String title;
  final String value;
  final bool isEquation;

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
                '$title:',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 5),
              if (isEquation) ...[
                Math.tex(
                  value,
                  mathStyle: MathStyle.text,
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                  textScaleFactor: 1.5,
                ),
              ] else ...[
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
