import 'package:flutter/widgets.dart';

import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';

class OreChoiceDescription extends StatelessWidget {
  const OreChoiceDescription({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.padding,
    this.style,
    this.alignment = Alignment.centerLeft,
  });

  final List<Widget> items;
  final int selectedIndex;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty ||
        selectedIndex < 0 ||
        selectedIndex >= items.length) {
      return const SizedBox.shrink();
    }

    final theme = OreTheme.of(context);
    final textStyle = style ??
        theme.typography.body.copyWith(color: theme.colors.textPrimary);
    final resolvedPadding = padding ?? const EdgeInsets.all(OreTokens.gapXs);

    return DefaultTextStyle.merge(
      style: textStyle,
      child: AnimatedSwitcher(
        duration: OreTokens.fast,
        child: Container(
          key: ValueKey<int>(selectedIndex),
          alignment: alignment,
          padding: resolvedPadding,
          child: items[selectedIndex],
        ),
      ),
    );
  }
}
