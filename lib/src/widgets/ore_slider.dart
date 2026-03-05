import 'package:flutter/material.dart';

import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';

class OreSlider extends StatelessWidget {
  const OreSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final colors = theme.colors;
    final sliderTheme = SliderTheme.of(context);
    final valueIndicatorTextStyle =
        (sliderTheme.valueIndicatorTextStyle ?? theme.typography.caption)
            .copyWith(fontFamily: theme.typography.body.fontFamily);
    final depthUnit = theme.borderWidth;
    final highlightDepth = depthUnit;
    final shadowDepth = depthUnit * 2;
    final trackHeight = depthUnit * OreTokens.sliderTrackUnits;
    final thumbSize = depthUnit * OreTokens.sliderThumbUnits;

    return SliderTheme(
      data: sliderTheme.copyWith(
        trackHeight: trackHeight,
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.borderLight,
        thumbColor: colors.surface,
        overlayColor: Colors.transparent,
        valueIndicatorTextStyle: valueIndicatorTextStyle,
        thumbShape: OreSliderThumbShape(
          colors: colors,
          borderWidth: theme.borderWidth,
          highlightDepth: highlightDepth,
          shadowDepth: shadowDepth,
          size: thumbSize,
        ),
        trackShape: OreSliderTrackShape(
          colors: colors,
          borderWidth: theme.borderWidth,
          highlightDepth: highlightDepth,
          shadowDepth: shadowDepth,
          trackHeight: trackHeight,
        ),
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
      ),
    );
  }
}

class OreSliderTrackShape extends SliderTrackShape {
  const OreSliderTrackShape({
    required this.colors,
    required this.borderWidth,
    required this.highlightDepth,
    required this.shadowDepth,
    required this.trackHeight,
  });

  final OreColors colors;
  final double borderWidth;
  final double highlightDepth;
  final double shadowDepth;
  final double trackHeight;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final resolvedTrackHeight =
        sliderTheme.trackHeight ?? trackHeight;
    final trackLeft = offset.dx + borderWidth;
    final trackTop =
        offset.dy + (parentBox.size.height - resolvedTrackHeight) / 2;
    final trackWidth = parentBox.size.width - borderWidth * 2;
    return Rect.fromLTWH(
        trackLeft, trackTop, trackWidth, resolvedTrackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final canvas = context.canvas;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final inactivePaint = Paint()
      ..color = isEnabled ? colors.borderLight : colors.surface
      ..style = PaintingStyle.fill;
    canvas.drawRect(trackRect, inactivePaint);

    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx.clamp(trackRect.left, trackRect.right),
      trackRect.bottom,
    );
    final activePaint = Paint()
      ..color = isEnabled ? colors.accent : colors.surfaceHover
      ..style = PaintingStyle.fill;
    canvas.drawRect(activeRect, activePaint);

    final borderPaint = Paint()
      ..color = isEnabled ? colors.border : colors.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRect(trackRect, borderPaint);

    final highlightPaint = Paint()
      ..color = colors.highlight
      ..strokeWidth = highlightDepth;
    canvas.drawLine(
      Offset(trackRect.left + borderWidth, trackRect.top + highlightDepth / 2),
      Offset(trackRect.right - borderWidth, trackRect.top + highlightDepth / 2),
      highlightPaint,
    );

    final shadowPaint = Paint()
      ..color = colors.shadow
      ..strokeWidth = shadowDepth;
    canvas.drawLine(
      Offset(trackRect.left + borderWidth, trackRect.bottom - shadowDepth / 2),
      Offset(
          trackRect.right - borderWidth, trackRect.bottom - shadowDepth / 2),
      shadowPaint,
    );
  }
}

class OreSliderThumbShape extends SliderComponentShape {
  const OreSliderThumbShape({
    required this.colors,
    required this.borderWidth,
    required this.highlightDepth,
    required this.shadowDepth,
    required this.size,
  });

  final OreColors colors;
  final double borderWidth;
  final double highlightDepth;
  final double shadowDepth;
  final double size;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(size, size);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(center: center, width: size, height: size);
    final enabled = enableAnimation.value > 0.0;

    final fillPaint = Paint()
      ..color = enabled ? colors.surface : colors.surface
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    final borderPaint = Paint()
      ..color = enabled ? colors.border : colors.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRect(rect.deflate(borderWidth / 2), borderPaint);

    final highlightPaint = Paint()
      ..color = colors.highlight
      ..strokeWidth = highlightDepth;
    canvas.drawLine(
      Offset(rect.left + borderWidth, rect.top + highlightDepth / 2),
      Offset(rect.right - borderWidth, rect.top + highlightDepth / 2),
      highlightPaint,
    );

    final shadowPaint = Paint()
      ..color = colors.shadow
      ..strokeWidth = shadowDepth;
    canvas.drawLine(
      Offset(rect.left + borderWidth, rect.bottom - shadowDepth / 2),
      Offset(rect.right - borderWidth, rect.bottom - shadowDepth / 2),
      shadowPaint,
    );
  }
}
