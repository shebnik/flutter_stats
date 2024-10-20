import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StyledButton extends StatelessWidget {
  const StyledButton({
    this.text,
    this.onPressed,
    this.svgPicturePath,
    super.key,
  });

  final String? text;
  final void Function()? onPressed;
  final String? svgPicturePath;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgPicturePath != null) ...[
              SvgPicture.asset(
                svgPicturePath!,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
