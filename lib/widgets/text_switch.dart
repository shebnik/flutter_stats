import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class TextSwitch extends StatelessWidget {
  const TextSwitch({
    required this.caption,
    required this.onChanged,
    required this.value,
    this.subtitle,
    super.key,
  });

  final String caption;
  final void Function() onChanged;
  final bool value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return InkWell(
      onTap: onChanged,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: subtitle == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    caption,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                ),
                if (subtitle != null)...[
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}
