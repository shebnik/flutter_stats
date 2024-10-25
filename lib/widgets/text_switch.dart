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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: subtitle == null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caption,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: isMobile ? 14 : 18,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: EdgeInsets.only(top: isMobile ? 4 : 8),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 16,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: isMobile ? 8 : 50),
        Switch(
          value: value,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
