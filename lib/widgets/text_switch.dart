import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class TextSwitch extends StatelessWidget {
  const TextSwitch({
    required this.caption,
    required this.onChanged,
    required this.value,
    super.key,
  });

  final String caption;
  final void Function() onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          caption,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 14 : 18,
          ),
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
