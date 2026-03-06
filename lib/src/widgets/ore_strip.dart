import 'package:flutter/widgets.dart';

import '../theme/ore_theme.dart';

class OreStrip extends StatelessWidget {
  const OreStrip({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.highlightColor,
    this.shadowColor,
    this.alignment = Alignment.centerLeft,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? highlightColor;
  final Color? shadowColor;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final colors = theme.colors;
    final stroke = theme.borderWidth;

    final resolvedPadding = padding ?? EdgeInsets.zero;

    Widget body = Container(
      width: double.infinity,
      color: color ?? colors.surface,
      child: Stack(
        alignment: alignment,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: stroke,
            child: Container(
              color: highlightColor ?? colors.highlight,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: stroke,
            child: Container(
              color: shadowColor ?? colors.shadow,
            ),
          ),
          Padding(
            padding: resolvedPadding,
            child: child,
          ),
        ],
      ),
    );

    if (margin != null) {
      body = Padding(padding: margin!, child: body);
    }

    return body;
  }
}
