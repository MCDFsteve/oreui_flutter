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
    final children = List.generate(items.length, (index) {
      final selected = index == selectedIndex;
      final child = _ChoiceButton(
        child: items[index],
        selected: selected,
        onPressed: _enabled ? () => onChanged?.call(index) : null,
        size: size,
      );
      return fullWidth ? Expanded(child: child) : child;
    });

    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.child,
    required this.selected,
    required this.onPressed,
    required this.size,
  });

  final Widget child;
  final bool selected;
  final VoidCallback? onPressed;
  final OreButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = OreTheme.of(context).colors;

    return OreButton(
      onPressed: onPressed,
      size: size,
      variant:
          selected ? OreButtonVariant.primary : OreButtonVariant.secondary,
      overlayBuilder: (context, data) {
        if (!selected) {
          return const SizedBox.shrink();
        }
        final indicatorHeight =
            data.borderWidth * OreTokens.choiceIndicatorHeightUnits;
        final indicatorBottom = data.borderWidth + data.shadowDepth;
        return Positioned(
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
        );
      },
      child: child,
    );
  }
}
