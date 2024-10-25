import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';

class AliasSelector extends StatelessWidget {
  const AliasSelector({
    required this.label,
    this.isEnabled,
    this.onSelected,
    this.alias,
    super.key,
    this.toggleEnabled,
  });

  final String label;
  final String? alias;
  final void Function(String?)? onSelected;
  final bool? isEnabled;
  final VoidCallback? toggleEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isEnabled != null) ...[
                  Checkbox(
                    value: isEnabled,
                    onChanged: (_) => toggleEnabled?.call(),
                  ),
                ] else ...[
                  const AbsorbPointer(
                    child: Checkbox(
                      value: true,
                      onChanged: null,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: AbsorbPointer(
              absorbing: isEnabled == false,
              child: LayoutBuilder(
                builder: (context, constraints) => Autocomplete<String>(
                  optionsBuilder: (text) {
                    return aliases;
                    // .where(
                    //   (e) => e.toLowerCase().contains(
                    //         text.text.toLowerCase(),
                    //       ),
                    // )
                    // .toList();
                  },
                  onSelected: onSelected,
                  fieldViewBuilder: (
                    _,
                    controller,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    controller.text = (isEnabled ?? true) ? (alias ?? '') : '';
                    return TextFormField(
                      enabled: isEnabled ?? true,
                      controller: controller,
                      focusNode: focusNode,
                      onFieldSubmitted: (_) => onFieldSubmitted(),
                      onChanged: (value) => onSelected?.call(value),
                      decoration: InputDecoration(
                        disabledBorder: InputBorder.none,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) => Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(4)),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: min(
                            MediaQuery.of(context).size.height * 0.5,
                            52 * options.length.toDouble(),
                          ),
                          maxWidth: constraints.biggest.width,
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(option),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
