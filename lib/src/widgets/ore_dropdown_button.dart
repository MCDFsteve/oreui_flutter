import 'package:flutter/material.dart';

import '../theme/ore_highlight.dart';
import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';
import 'ore_button.dart';
import 'ore_surface.dart';

@immutable
class OreDropdownItem<T> {
  const OreDropdownItem({
    required this.value,
    required this.child,
  });

  final T value;
  final Widget child;
}

class OreDropdownButton<T> extends StatefulWidget {
  const OreDropdownButton({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.size = OreButtonSize.md,
    this.variant = OreButtonVariant.secondary,
    this.fullWidth = true,
  });

  final List<OreDropdownItem<T>> items;
  final ValueChanged<T>? onChanged;
  final T? value;
  final Widget? hint;
  final OreButtonSize size;
  final OreButtonVariant variant;
  final bool fullWidth;

  @override
  State<OreDropdownButton<T>> createState() => _OreDropdownButtonState<T>();
}

class _OreDropdownButtonState<T> extends State<OreDropdownButton<T>> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onChanged != null && widget.items.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final colors = theme.colors;
    final isPressed = _pressed && _enabled;
    final isHovered = _hovered && _enabled;
    final config = _resolveColors(colors, isHovered, isPressed, _enabled);
    final height = _height(widget.size);
    final padding = _padding(widget.size, theme.borderWidth);

    final visualDepth = theme.bevelDepth;
    final shadowDepth = isPressed ? 0.0 : visualDepth;
    final highlightDepth =
        (visualDepth - 1).clamp(0.0, visualDepth).toDouble();
    final contentOffsetY = isPressed ? 0.0 : -visualDepth / 2;

    final display = _selectedChild() ?? widget.hint ?? const SizedBox.shrink();
    final labelStyle = theme.typography.label.copyWith(
      color: config.textColor,
    );
    final arrow = Icon(
      Icons.keyboard_arrow_down,
      size: 18,
      color: config.textColor,
    );

    Widget content = DefaultTextStyle.merge(
      style: labelStyle,
      child: _buildContent(display, arrow),
    );
    content = AnimatedContainer(
      duration: OreTokens.fast,
      transform: Matrix4.translationValues(0, contentOffsetY, 0),
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
      alignment: Alignment.centerLeft,
      padding: padding,
      pressed: isPressed,
      child: content,
    );

    final pressedCut = isPressed ? visualDepth : 0.0;
    final pressedHeight = (height - pressedCut).clamp(0.0, height);
    final widthFactor = widget.fullWidth ? null : 1.0;

    Widget buttonBody = SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.bottomCenter,
        widthFactor: widthFactor,
        child: SizedBox(
          height: pressedHeight,
          child: surface,
        ),
      ),
    );

    if (widget.fullWidth) {
      buttonBody = SizedBox(width: double.infinity, child: buttonBody);
    }

    return Focus(
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: _enabled ? _openMenu : null,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          behavior: HitTestBehavior.opaque,
          child: buttonBody,
        ),
      ),
    );
  }

  Widget _buildContent(Widget label, Widget arrow) {
    if (widget.fullWidth) {
      return Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: label,
            ),
          ),
          const SizedBox(width: OreTokens.gapSm),
          arrow,
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        label,
        const SizedBox(width: OreTokens.gapSm),
        arrow,
      ],
    );
  }

  Widget? _selectedChild() {
    if (widget.items.isEmpty) return null;
    for (final item in widget.items) {
      if (item.value == widget.value) {
        return item.child;
      }
    }
    return null;
  }

  Future<void> _openMenu() async {
    _setPressed(false);
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final buttonBox = context.findRenderObject() as RenderBox?;
    if (buttonBox == null || !buttonBox.hasSize) return;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.hasSize) return;

    final buttonTopLeft =
        buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final buttonRect = Rect.fromLTWH(
      buttonTopLeft.dx,
      buttonTopLeft.dy,
      buttonBox.size.width,
      buttonBox.size.height,
    );
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(
        buttonRect.left,
        buttonRect.bottom,
        buttonRect.width,
        0,
      ),
      Offset.zero & overlayBox.size,
    );

    final selected = await showMenu<T>(
      context: context,
      position: position,
      items: _buildMenuItems(buttonRect.width),
    );
    if (selected != null) {
      widget.onChanged?.call(selected);
    }
  }

  List<PopupMenuEntry<T>> _buildMenuItems(double width) {
    final theme = OreTheme.of(context);
    final colors = theme.colors;
    final style = theme.typography.body.copyWith(color: colors.textPrimary);
    return widget.items
        .map(
          (item) => PopupMenuItem<T>(
            value: item.value,
            child: SizedBox(
              width: width,
              child: DefaultTextStyle.merge(
                style: style,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: item.child,
                ),
              ),
            ),
          ),
        )
        .toList();
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

  EdgeInsetsGeometry _padding(OreButtonSize size, double unit) {
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

  _DropdownColors _resolveColors(
    OreColors colors,
    bool hovered,
    bool pressed,
    bool enabled,
  ) {
    if (!enabled) {
      return _DropdownColors(
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
        return _DropdownColors(
          background: _pick(colors.accent, colors.accentHover,
              colors.accentPressed, hovered, pressed),
          borderColor: colors.border,
          shadowColor: colors.accentPressed,
          highlightColor: coloredHighlight,
          textColor: colors.textInverse,
        );
      case OreButtonVariant.danger:
        return _DropdownColors(
          background: _pick(colors.danger, colors.dangerHover,
              colors.dangerPressed, hovered, pressed),
          borderColor: colors.border,
          shadowColor: colors.dangerPressed,
          highlightColor: coloredHighlight,
          textColor: colors.textInverse,
        );
      case OreButtonVariant.secondary:
        return _DropdownColors(
          background: _pick(colors.surface, colors.surfaceHover,
              colors.surfacePressed, hovered, pressed),
          borderColor: colors.border,
          shadowColor: colors.shadow,
          highlightColor: neutralHighlight,
          textColor: colors.textPrimary,
        );
      case OreButtonVariant.ghost:
        return _DropdownColors(
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

class _DropdownColors {
  const _DropdownColors({
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
