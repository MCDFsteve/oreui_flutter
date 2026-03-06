import 'package:flutter/widgets.dart';

import 'ore_theme.dart';
import 'ore_tokens.dart';

class OreHighlight {
  const OreHighlight._();

  static Color resolve({
    required OreColors colors,
    required bool colored,
    required bool hovered,
  }) {
    if (colored) {
      return mutedColored();
    }
    return muted(colors: colors);
  }

  static Color muted({
    required OreColors colors,
    double factor = 0.4,
  }) {
    final base = colors.highlight;
    if (base.alpha == 0) return base;
    final nextOpacity = (base.opacity * factor).clamp(0.0, 1.0);
    return base.withOpacity(nextOpacity);
  }

  static Color mutedColored({double factor = 0.4}) {
    final base = OreTokens.coloredHighlight;
    if (base.alpha == 0) return base;
    final nextOpacity = (base.opacity * factor).clamp(0.0, 1.0);
    return base.withOpacity(nextOpacity);
  }
}
