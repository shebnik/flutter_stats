import 'package:flutter/material.dart';

class CheckTile extends StatelessWidget {
  const CheckTile({
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
    return PopupMenuItem<void>(
      onTap: onChanged,
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              caption,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
