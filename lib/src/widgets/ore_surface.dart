import 'dart:math' as math;

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
    this.highlightDepth,
    this.shadowDepth,
    this.swapHighlightOnPressed = true,
    this.alignment = AlignmentDirectional.topStart,
    this.padding,
    this.pressed = false,
    this.ignoreShadowPadding = false,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final Color highlightColor;
  final Color shadowColor;
  final double borderWidth;
  final double depth;
  final double? highlightDepth;
  final double? shadowDepth;
  final bool swapHighlightOnPressed;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;
  final bool pressed;
  final bool ignoreShadowPadding;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final shouldSwap = pressed && swapHighlightOnPressed;
    final highlight = shouldSwap ? shadowColor : highlightColor;
    final shadow = shouldSwap ? highlightColor : shadowColor;
    final cornerHighlight = highlight.alpha == 0
        ? highlight
        : Color.lerp(highlight, const Color(0xFFFFFFFF), 0.2)!;
    final resolvedHighlightDepth =
        math.max(0.0, highlightDepth ?? depth);
    final resolvedShadowDepth =
        math.max(0.0, shadowDepth ?? depth);
    final weakHighlight = highlight.alpha == 0
        ? highlight
        : highlight.withOpacity((highlight.opacity * 0.66).clamp(0, 1));

    final resolvedPadding =
        padding?.resolve(Directionality.of(context)) ??
            EdgeInsets.all(theme.gap);
    final adjustedPadding = ignoreShadowPadding
        ? EdgeInsets.fromLTRB(
            resolvedPadding.left,
            resolvedPadding.top,
            resolvedPadding.right,
            math.max(0, resolvedPadding.bottom - resolvedShadowDepth),
          )
        : resolvedPadding;

    return Container(
      decoration: BoxDecoration(color: color),
      child: Stack(
        alignment: alignment,
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
          if (resolvedHighlightDepth > 0) ...[
            // Top highlight (strong)
            Positioned(
              left: borderWidth,
              right: borderWidth,
              top: borderWidth,
              height: resolvedHighlightDepth,
              child: Container(color: highlight),
            ),
            // Left highlight (strong)
            Positioned(
              left: borderWidth,
              top: borderWidth + resolvedHighlightDepth,
              bottom:
                  borderWidth + resolvedShadowDepth + resolvedHighlightDepth,
              width: resolvedHighlightDepth,
              child: Container(color: highlight),
            ),
            // Right highlight (weak)
            Positioned(
              right: borderWidth,
              top: borderWidth + resolvedHighlightDepth,
              bottom:
                  borderWidth + resolvedShadowDepth + resolvedHighlightDepth,
              width: resolvedHighlightDepth,
              child: Container(color: weakHighlight),
            ),
            // Bottom highlight (weak) sits above shadow
            Positioned(
              left: borderWidth,
              right: borderWidth,
              bottom: borderWidth + resolvedShadowDepth,
              height: resolvedHighlightDepth,
              child: Container(color: weakHighlight),
            ),
            // Bright corners (top-right, bottom-left)
            Positioned(
              right: borderWidth,
              top: borderWidth,
              width: resolvedHighlightDepth,
              height: resolvedHighlightDepth,
              child: Container(color: cornerHighlight),
            ),
            Positioned(
              left: borderWidth,
              bottom: borderWidth + resolvedShadowDepth,
              width: resolvedHighlightDepth,
              height: resolvedHighlightDepth,
              child: Container(color: cornerHighlight),
            ),
          ],
          if (resolvedShadowDepth > 0) ...[
            // Bottom shadow
            Positioned(
              left: borderWidth,
              right: borderWidth,
              bottom: borderWidth,
              height: resolvedShadowDepth,
              child: Container(color: shadow),
            ),
          ],
          Padding(
            padding: adjustedPadding,
            child: child,
          ),
        ],
      ),
    );
  }
}
