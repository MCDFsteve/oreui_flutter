import 'package:flutter/material.dart';

import '../theme/ore_theme.dart';

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

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.borderLight,
        thumbColor: colors.surface,
        overlayColor: Colors.transparent,
        thumbShape: OreSliderThumbShape(
          colors: colors,
          borderWidth: theme.borderWidth,
          bevelDepth: theme.bevelDepth,
        ),
        trackShape: OreSliderTrackShape(
          colors: colors,
          borderWidth: theme.borderWidth,
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
  });

  final OreColors colors;
  final double borderWidth;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 8;
    final trackLeft = offset.dx + borderWidth;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width - borderWidth * 2;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
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
      ..strokeWidth = borderWidth;
    canvas.drawLine(
      Offset(trackRect.left, trackRect.top + borderWidth / 2),
      Offset(trackRect.right, trackRect.top + borderWidth / 2),
      highlightPaint,
    );

    final shadowPaint = Paint()
      ..color = colors.shadow
      ..strokeWidth = borderWidth;
    canvas.drawLine(
      Offset(trackRect.left, trackRect.bottom - borderWidth / 2),
      Offset(trackRect.right, trackRect.bottom - borderWidth / 2),
      shadowPaint,
    );
  }
}

class OreSliderThumbShape extends SliderComponentShape {
  const OreSliderThumbShape({
    required this.colors,
    required this.borderWidth,
    required this.bevelDepth,
  });

  final OreColors colors;
  final double borderWidth;
  final double bevelDepth;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(28, 28);
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
    final rect = Rect.fromCenter(center: center, width: 28, height: 28);
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
      ..strokeWidth = borderWidth;
    canvas.drawLine(
      Offset(rect.left + borderWidth, rect.top + borderWidth / 2),
      Offset(rect.right - borderWidth, rect.top + borderWidth / 2),
      highlightPaint,
    );

    final shadowPaint = Paint()
      ..color = colors.shadow
      ..strokeWidth = bevelDepth;
    canvas.drawLine(
      Offset(rect.left + borderWidth, rect.bottom - borderWidth / 2),
      Offset(rect.right - borderWidth, rect.bottom - borderWidth / 2),
      shadowPaint,
    );
  }
}
