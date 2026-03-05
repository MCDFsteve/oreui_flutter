import 'package:flutter/widgets.dart';

import '../theme/ore_theme.dart';

class OreSurface extends StatelessWidget {
  const OreSurface({
    super.key,
    required this.child,
    required this.color,
    required this.borderColor,
    required this.highlightColor,
    required this.shadowColor,
    required this.borderWidth,
    required this.depth,
    this.padding,
    this.pressed = false,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final Color highlightColor;
  final Color shadowColor;
  final double borderWidth;
  final double depth;
  final EdgeInsetsGeometry? padding;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final highlight = pressed ? shadowColor : highlightColor;
    final shadow = pressed ? highlightColor : shadowColor;
    final cornerHighlight = highlight.alpha == 0
        ? highlight
        : Color.lerp(highlight, const Color(0xFFFFFFFF), 0.35)!;
    final innerDepth = depth.clamp(0, 8).toDouble();
    final highlightDepth = innerDepth;
    final shadowDepth = innerDepth;

    return Container(
      decoration: BoxDecoration(color: color),
      child: Stack(
        children: [
          if (borderWidth > 0) ...[
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: borderWidth,
              child: Container(color: borderColor),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: borderWidth,
              child: Container(color: borderColor),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: borderWidth,
              child: Container(color: borderColor),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: borderWidth,
              child: Container(color: borderColor),
            ),
          ],
          if (innerDepth > 0) ...[
            Positioned(
              left: borderWidth,
              right: borderWidth,
              top: borderWidth,
              height: highlightDepth,
              child: Container(color: highlight),
            ),
            Positioned(
              left: borderWidth,
              top: borderWidth + highlightDepth,
              bottom: borderWidth + highlightDepth + shadowDepth,
              width: highlightDepth,
              child: Container(color: highlight),
            ),
            Positioned(
              right: borderWidth,
              top: borderWidth + highlightDepth,
              bottom: borderWidth + highlightDepth + shadowDepth,
              width: highlightDepth,
              child: Container(color: highlight),
            ),
            Positioned(
              left: borderWidth,
              right: borderWidth,
              bottom: borderWidth + shadowDepth,
              height: highlightDepth,
              child: Container(color: highlight),
            ),
            Positioned(
              right: borderWidth,
              top: borderWidth,
              width: highlightDepth,
              height: highlightDepth,
              child: Container(color: cornerHighlight),
            ),
            Positioned(
              left: borderWidth,
              bottom: borderWidth + shadowDepth,
              width: highlightDepth,
              height: highlightDepth,
              child: Container(color: cornerHighlight),
            ),
            Positioned(
              left: borderWidth,
              right: borderWidth,
              bottom: borderWidth,
              height: shadowDepth,
              child: Container(color: shadow),
            ),
          ],
          Padding(
            padding: padding ?? EdgeInsets.all(theme.gap),
            child: child,
          ),
        ],
      ),
    );
  }
}
