import 'package:flutter/material.dart';
import 'ore_theme.dart';

/// Bridges Flutter's route/text infrastructure to the Ore palette and type.
ThemeData oreAppTheme({Brightness brightness = Brightness.light}) {
  final ore = brightness == Brightness.dark
      ? OreThemeData.dark()
      : OreThemeData.light();
  final c = ore.colors;
  final t = ore.typography;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: c.accent,
        brightness: brightness,
      ).copyWith(
        primary: c.accent,
        onPrimary: c.textInverse,
        secondary: c.success,
        surface: c.surface,
        onSurface: c.textPrimary,
        error: c.danger,
        outline: c.border,
        onSurfaceVariant: c.textMuted,
      );
  final base = ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    useMaterial3: true,
  );
  return base.copyWith(
    scaffoldBackgroundColor: c.background,
    canvasColor: c.background,
    splashFactory: NoSplash.splashFactory,
    textTheme: base.textTheme
        .apply(
          fontFamily: t.body.fontFamily,
          bodyColor: c.textPrimary,
          displayColor: c.textPrimary,
        )
        .copyWith(
          bodyMedium: t.body,
          bodySmall: t.caption,
          titleMedium: t.choiceTitle,
          titleLarge: t.title,
          labelLarge: t.label,
        ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.success,
      selectionColor: c.selection,
      selectionHandleColor: c.success,
    ),
    extensions: [ore],
  );
}

/// Explicit OreScrollbars own the scrollbar visuals; no stock glow/stretch.
class OreScrollBehavior extends MaterialScrollBehavior {
  const OreScrollBehavior();
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
