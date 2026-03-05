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
      return hovered
          ? OreTokens.coloredHighlightStrong
          : OreTokens.coloredHighlight;
    }
    return hovered ? colors.highlightStrong : colors.highlight;
  }
}
