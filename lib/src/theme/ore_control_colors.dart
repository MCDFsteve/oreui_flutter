import 'package:flutter/material.dart';

import 'ore_theme.dart';

OreColors resolveControlColors(BuildContext context, OreColors baseColors) {
  final brightness = Theme.of(context).brightness;
  final inverted = brightness == Brightness.dark
      ? OreColors.light()
      : OreColors.dark();
  return inverted.copyWith(
    accent: baseColors.accent,
    accentHover: baseColors.accentHover,
    accentPressed: baseColors.accentPressed,
    danger: baseColors.danger,
    dangerHover: baseColors.dangerHover,
    dangerPressed: baseColors.dangerPressed,
    info: baseColors.info,
    warning: baseColors.warning,
    success: baseColors.success,
    selection: baseColors.selection,
    textInverse: baseColors.textInverse,
  );
}
