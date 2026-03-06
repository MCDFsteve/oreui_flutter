import 'package:flutter/material.dart';

import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';
import 'ore_button.dart';

class OreChoiceButtons extends StatelessWidget {
  const OreChoiceButtons({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.size = OreButtonSize.md,
    this.fullWidth = false,
  });

  final List<Widget> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final OreButtonSize size;
  final bool fullWidth;

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final colors = theme.colors;
    final borderWidth = theme.borderWidth;
    final indicatorHeight =
        borderWidth * OreTokens.choiceIndicatorHeightUnits;

    final children = List.generate(items.length, (index) {
      final selected = index == selectedIndex;
      final indicatorBottom = borderWidth;
      final button = OreButton(
        onPressed: _enabled ? () => onChanged?.call(index) : null,
        size: size,
        variant:
            selected ? OreButtonVariant.primary : OreButtonVariant.secondary,
        forcePressed: selected,
        forcePressedKeepsColor: selected,
        child: items[index],
      );
      final decorated = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          if (selected)
            Positioned(
              left: 0,
              right: 0,
              bottom: indicatorBottom,
              height: indicatorHeight,
              child: Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: OreTokens.choiceIndicatorWidthFactor,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: colors.textInverse),
                  ),
                ),
              ),
            ),
        ],
      );

      final child = fullWidth ? Expanded(child: decorated) : decorated;
      return child;
    });

    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }
}
