import 'package:flutter/material.dart';

import '../theme/ore_control_colors.dart';
import '../theme/ore_highlight.dart';
import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';
import 'ore_pixel_icon.dart';
import 'ore_surface.dart';

enum OreButtonVariant { primary, secondary, ghost, danger }

enum OreButtonSize { sm, md, lg }

class OreButton extends StatefulWidget {
  const OreButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.variant = OreButtonVariant.secondary,
    this.size = OreButtonSize.md,
    this.isLoading = false,
    this.leading,
    this.trailing,
    this.fullWidth = false,
    this.width,
    this.autofocus = false,
    this.focusNode,
    this.forcePressed = false,
    this.forcePressedKeepsColor = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final OreButtonVariant variant;
  final OreButtonSize size;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final bool fullWidth;
  final double? width;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool forcePressed;
  final bool forcePressedKeepsColor;

  @override
  State<OreButton> createState() => _OreButtonState();
}

class _OreButtonState extends State<OreButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final colors = resolveControlColors(context, theme.colors);
    final isPressed = (_pressed && _enabled) || widget.forcePressed;
    final colorPressed =
        (_pressed && _enabled && !(widget.forcePressed && widget.forcePressedKeepsColor)) ||
        (widget.forcePressed && !widget.forcePressedKeepsColor);
    final isHovered = _hovered &&
        _enabled &&
        !(widget.forcePressed && widget.forcePressedKeepsColor);
    final styleEnabled = _enabled || widget.forcePressed;

    final config =
        _resolveColors(colors, isHovered, colorPressed, styleEnabled);
    final height = _height(widget.size);
    final basePadding = _padding(widget.size, theme.borderWidth);

    final depthUnit = theme.borderWidth;
    final visualDepth = depthUnit * 2;
    final shadowDepth = isPressed ? 0.0 : visualDepth;
    final highlightDepth = depthUnit;
    final contentOffsetY = isPressed ? 0.0 : -visualDepth / 2;
    final pressedPadding = EdgeInsets.fromLTRB(
      basePadding.left,
      (basePadding.top - visualDepth).clamp(0.0, basePadding.top),
      basePadding.right,
      (basePadding.bottom - visualDepth).clamp(0.0, basePadding.bottom),
    );
    final padding = isPressed ? pressedPadding : basePadding;

    Widget content = DefaultTextStyle.merge(
      style: theme.typography.label.copyWith(color: config.textColor),
      child: _buildContent(config.textColor),
    );
    content = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: contentOffsetY, end: contentOffsetY),
      duration: OreTokens.fast,
      builder: (context, value, child) {
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final snapped =
            (value * dpr).roundToDouble() / dpr;
        return Transform.translate(
          offset: Offset(0, snapped),
          child: child,
        );
      },
      child: content,
    );

    final surface = OreSurface(
      color: config.background,
      borderColor: config.borderColor,
      highlightColor: config.highlightColor,
      shadowColor: config.shadowColor,
      borderWidth: theme.borderWidth,
      depth: visualDepth,
      highlightDepth: highlightDepth,
      shadowDepth: shadowDepth,
      swapHighlightOnPressed: false,
      alignment: Alignment.center,
      padding: padding,
      pressed: isPressed,
      child: content,
    );

    final pressedCut = isPressed ? visualDepth : 0.0;
    final pressedHeight =
        (height - pressedCut).clamp(0.0, height);
    final widthFactor =
        (widget.width == null && !widget.fullWidth) ? 1.0 : null;
    final innerWidth =
        (widget.width != null || widget.fullWidth) ? double.infinity : null;

    Widget buttonBody = SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.bottomCenter,
        widthFactor: widthFactor,
        child: SizedBox(
          width: innerWidth,
          height: pressedHeight,
          child: surface,
        ),
      ),
    );

    if (widget.width != null) {
      buttonBody = SizedBox(width: widget.width, child: buttonBody);
    } else if (widget.fullWidth) {
      buttonBody = SizedBox(width: double.infinity, child: buttonBody);
    }

    return Focus(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: _enabled ? widget.onPressed : null,
          onLongPress: _enabled ? widget.onLongPress : null,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          behavior: HitTestBehavior.opaque,
          child: buttonBody,
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    final parts = <Widget>[];
    final hasAffixes =
        widget.isLoading || widget.leading != null || widget.trailing != null;

    if (widget.isLoading) {
      parts.add(
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    if (widget.leading != null) {
      parts.add(_normalizeIcon(widget.leading!, textColor));
    }

    parts.add(hasAffixes ? Flexible(child: widget.child) : widget.child);

    if (widget.trailing != null) {
      parts.add(_normalizeIcon(widget.trailing!, textColor));
    }

    if (parts.length == 1) {
      return parts.first;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(parts, OreTokens.gapSm),
    );
  }

  List<Widget> _withGaps(List<Widget> items, double gap) {
    if (items.length <= 1) {
      return items;
    }
    final spaced = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i != items.length - 1) {
        spaced.add(SizedBox(width: gap));
      }
    }
    return spaced;
  }

  Widget _normalizeIcon(Widget widget, Color textColor) {
    if (widget is OrePixelIcon) return widget;
    if (widget is Icon) {
      final iconData = widget.icon;
      if (iconData == null) return widget;
      return OrePixelIcon(
        icon: iconData,
        size: widget.size,
        color: widget.color ?? textColor,
        semanticLabel: widget.semanticLabel,
        textDirection: widget.textDirection,
      );
    }
    return widget;
  }

  double _height(OreButtonSize size) {
    switch (size) {
      case OreButtonSize.sm:
        return OreTokens.controlHeightSm;
      case OreButtonSize.md:
        return OreTokens.controlHeightMd;
      case OreButtonSize.lg:
        return OreTokens.controlHeightLg;
    }
  }

  EdgeInsets _padding(OreButtonSize size, double unit) {
    switch (size) {
      case OreButtonSize.sm:
        return EdgeInsets.symmetric(
          horizontal: unit * OreTokens.buttonPadSmHUnits,
          vertical: unit * OreTokens.buttonPadSmVUnits,
        );
      case OreButtonSize.md:
        return EdgeInsets.symmetric(
          horizontal: unit * OreTokens.buttonPadMdHUnits,
          vertical: unit * OreTokens.buttonPadMdVUnits,
        );
      case OreButtonSize.lg:
        return EdgeInsets.symmetric(
          horizontal: unit * OreTokens.buttonPadLgHUnits,
          vertical: unit * OreTokens.buttonPadLgVUnits,
        );
    }
  }

  _ButtonColors _resolveColors(
    OreColors colors,
    bool hovered,
    bool pressed,
    bool enabled,
  ) {
    if (!enabled) {
      return _ButtonColors(
        background: colors.surface,
        borderColor: colors.borderLight,
        shadowColor: colors.borderLight.withOpacity(0.6),
        highlightColor: Colors.transparent,
        textColor: colors.textDisabled,
      );
    }

    final neutralHighlight = OreHighlight.resolve(
      colors: colors,
      colored: false,
      hovered: hovered,
    );
    final coloredHighlight = OreHighlight.resolve(
      colors: colors,
      colored: true,
      hovered: hovered,
    );

    switch (widget.variant) {
      case OreButtonVariant.primary:
        return _ButtonColors(
          background: _pick(colors.accent, colors.accentHover,
              colors.accentPressed, hovered, pressed),
          borderColor: colors.border,
          shadowColor: colors.accentPressed,
          highlightColor: coloredHighlight,
          textColor: colors.textInverse,
        );
      case OreButtonVariant.danger:
        return _ButtonColors(
          background: _pick(colors.danger, colors.dangerHover,
              colors.dangerPressed, hovered, pressed),
          borderColor: colors.border,
          shadowColor: colors.dangerPressed,
          highlightColor: coloredHighlight,
          textColor: colors.textInverse,
        );
      case OreButtonVariant.secondary:
        return _ButtonColors(
          background: _pick(colors.surface, colors.surfaceHover,
              colors.surfacePressed, hovered, pressed),
          borderColor: colors.border,
          shadowColor: colors.shadow,
          highlightColor: neutralHighlight,
          textColor: colors.textPrimary,
        );
      case OreButtonVariant.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          borderColor: Colors.transparent,
          shadowColor: Colors.transparent,
          highlightColor: Colors.transparent,
          textColor: colors.textPrimary,
        );
    }
  }

  Color _pick(
    Color base,
    Color hover,
    Color pressed,
    bool isHovered,
    bool isPressed,
  ) {
    if (isPressed) return pressed;
    if (isHovered) return hover;
    return base;
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.borderColor,
    required this.shadowColor,
    required this.highlightColor,
    required this.textColor,
  });

  final Color background;
  final Color borderColor;
  final Color shadowColor;
  final Color highlightColor;
  final Color textColor;
}
