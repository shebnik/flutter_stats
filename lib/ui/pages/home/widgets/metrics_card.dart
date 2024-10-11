import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_stats/services/utils.dart';

class MetricsCard extends StatelessWidget {
  const MetricsCard({
    this.title,
    this.value,
    this.isEquation = false,
    this.valueColor,
    super.key,
  });

  final String? title;
  final String? value;
  final bool isEquation;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: value != null
                  ? () => Utils.copyToClipboard(value!, context)
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                    if (value != null) ...[
                      if (isEquation) ...[
                        Math.tex(
                          value!,
                          mathStyle: MathStyle.text,
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                          textScaleFactor: 1.5,
                        ),
                      ] else ...[
                        Text(
                          value!,
                          style: TextStyle(
                            fontSize: 18,
                            color: valueColor,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
