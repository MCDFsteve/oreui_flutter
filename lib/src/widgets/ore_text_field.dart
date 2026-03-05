import 'package:flutter/material.dart';

import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';
import 'ore_surface.dart';

class OreTextField extends StatelessWidget {
  const OreTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onEditingComplete,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool enabled;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final colors = theme.colors;
    final depthUnit = theme.borderWidth;
    final highlightDepth = depthUnit;
    final shadowDepth = depthUnit * 2;

    final surfaceColor = enabled ? colors.surfaceDark : colors.surface;
    final borderColor = enabled ? colors.border : colors.borderLight;
    final textColor = enabled ? colors.textInverse : colors.textDisabled;

    return TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: colors.success,
        selectionColor: colors.selection,
      ),
      child: OreSurface(
        color: surfaceColor,
        borderColor: borderColor,
        highlightColor: colors.shadowStrong,
        shadowColor: enabled ? colors.shadowStrong : colors.borderLight,
        borderWidth: theme.borderWidth,
        depth: shadowDepth,
        highlightDepth: highlightDepth,
        shadowDepth: shadowDepth,
        padding: EdgeInsets.zero,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onEditingComplete: onEditingComplete,
          onSubmitted: onSubmitted,
          style: theme.typography.body.copyWith(color: textColor),
          cursorColor: colors.success,
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: hintText,
            hintStyle: theme.typography.body.copyWith(color: colors.textMuted),
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: OreTokens.gapMd,
                  vertical: OreTokens.gapSm,
                ),
            prefixIcon: prefix,
            suffixIcon: suffix,
          ),
        ),
      ),
    );
  }
}
