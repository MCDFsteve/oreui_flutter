import 'package:flutter/material.dart';

import '../theme/ore_control_colors.dart';
import '../theme/ore_highlight.dart';
import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';
import 'ore_button.dart';
import 'ore_scrollbar.dart';
import 'ore_surface.dart';

const double _menuInnerBorderWidth = 1.0;

@immutable
class OreDropdownItem<T> {
  const OreDropdownItem({required this.value, required this.child});

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

enum _MenuPlacement { below, above }

class _OreDropdownButtonState<T> extends State<OreDropdownButton<T>> {
  bool _hovered = false;
  bool _pressed = false;
  bool _menuOpen = false;
  _MenuPlacement _menuPlacement = _MenuPlacement.below;

  bool get _enabled => widget.onChanged != null && widget.items.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final themeColors = theme.colors;
    final colors = resolveControlColors(context, themeColors);
    final isPressed = _pressed && _enabled;
    final isHovered = _hovered && _enabled;
    final baseConfig = _resolveColors(colors, isHovered, isPressed, _enabled);
    final config = _menuOpen
        ? _DropdownColors(
            background: themeColors.background,
            borderColor: themeColors.border,
            shadowColor: Colors.transparent,
            highlightColor: Colors.transparent,
            textColor: themeColors.textPrimary,
          )
        : baseConfig;
    final height = _height(widget.size);
    final basePadding = _padding(widget.size, theme.borderWidth);
    final padding = isPressed
        ? basePadding.copyWith(
            top: (basePadding.top - theme.bevelDepth / 2).clamp(
              0.0,
              basePadding.top,
            ),
            bottom: (basePadding.bottom - theme.bevelDepth / 2).clamp(
              0.0,
              basePadding.bottom,
            ),
          )
        : basePadding;

    final visualDepth = _menuOpen ? 0.0 : theme.bevelDepth;
    final shadowDepth = (isPressed || _menuOpen) ? 0.0 : visualDepth;
    final highlightDepth = _menuOpen
        ? 0.0
        : (visualDepth - 1).clamp(0.0, visualDepth).toDouble();
    final contentOffsetY = (isPressed || _menuOpen) ? 0.0 : -visualDepth / 2;

    final display = _selectedChild() ?? widget.hint ?? const SizedBox.shrink();
    final labelStyle = theme.typography.label.copyWith(color: config.textColor);
    final arrow = Icon(
      _menuOpen ? Icons.check : Icons.keyboard_arrow_down,
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

    final hideBlackTop = _menuOpen && _menuPlacement == _MenuPlacement.above;
    final hideBlackBottom = _menuOpen && _menuPlacement == _MenuPlacement.below;
    final surface = _menuOpen
        ? _MenuSurface(
            color: config.background,
            borderColor: config.borderColor,
            innerBorderColor: themeColors.textInverse,
            borderWidth: theme.borderWidth,
            padding: padding,
            alignment: Alignment.centerLeft,
            showBlackTop: !hideBlackTop,
            showBlackBottom: !hideBlackBottom,
            whiteInsetTop: 0.0,
            whiteInsetBottom: 0.0,
            child: content,
          )
        : OreSurface(
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
    Widget buttonBody = Padding(
      padding: EdgeInsets.only(top: pressedCut),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height - pressedCut),
        child: surface,
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
              heightFactor: 1,
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
    final theme = OreTheme.of(context);
    final surfaceColors = theme.colors;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final buttonBox = context.findRenderObject() as RenderBox?;
    if (buttonBox == null || !buttonBox.hasSize) return;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.hasSize) return;

    final buttonTopLeft = buttonBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final buttonRect = Rect.fromLTWH(
      buttonTopLeft.dx,
      buttonTopLeft.dy,
      buttonBox.size.width,
      buttonBox.size.height,
    );
    final overlaySize = overlayBox.size;
    final itemHeight = buttonRect.height;
    final overlap = theme.borderWidth;
    final menuHeight = _menuHeight(widget.items.length, itemHeight);
    final menuWidth = buttonRect.width;
    final left = _clampHorizontal(
      buttonRect.left,
      menuWidth,
      overlaySize.width,
    );
    final belowSpace = (overlaySize.height - buttonRect.bottom + overlap).clamp(
      0.0,
      overlaySize.height,
    );
    final aboveSpace = (buttonRect.top + overlap).clamp(
      0.0,
      overlaySize.height,
    );
    final placement = belowSpace >= menuHeight || belowSpace >= aboveSpace
        ? _MenuPlacement.below
        : _MenuPlacement.above;
    final maxHeight = placement == _MenuPlacement.below
        ? belowSpace
        : aboveSpace;

    setState(() {
      _menuOpen = true;
      _menuPlacement = placement;
    });
    try {
      final selected = await showGeneralDialog<T>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        barrierColor: Colors.transparent,
        transitionDuration: OreTokens.fast,
        pageBuilder: (context, _, _) {
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  left: left,
                  top: placement == _MenuPlacement.below
                      ? buttonRect.bottom - overlap
                      : null,
                  bottom: placement == _MenuPlacement.above
                      ? overlaySize.height - buttonRect.top - overlap
                      : null,
                  width: menuWidth,
                  child: _DropdownMenuPanel<T>(
                    width: menuWidth,
                    itemHeight: itemHeight,
                    maxHeight: maxHeight,
                    padding: _padding(widget.size, theme.borderWidth),
                    items: widget.items,
                    colors: surfaceColors,
                    textStyle: theme.typography.body.copyWith(
                      color: surfaceColors.textPrimary,
                    ),
                    placement: placement,
                    onSelected: (value) => Navigator.of(context).pop(value),
                  ),
                ),
              ],
            ),
          );
        },
        transitionBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
      if (selected != null) {
        widget.onChanged?.call(selected);
      }
    } finally {
      if (mounted) {
        setState(() => _menuOpen = false);
      }
    }
  }

  double _menuHeight(int count, double itemHeight) => itemHeight * count;

  double _clampHorizontal(double left, double width, double maxWidth) {
    if (maxWidth <= 0) return 0;
    final maxLeft = (maxWidth - width).clamp(0.0, maxWidth);
    return left.clamp(0.0, maxLeft);
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
    // The bevel already occupies two units; keep it out of the content inset.
    switch (size) {
      case OreButtonSize.sm:
        return EdgeInsets.symmetric(
          horizontal: unit * OreTokens.buttonPadSmHUnits,
          vertical: unit * (OreTokens.buttonPadSmVUnits - 2),
        );
      case OreButtonSize.md:
        return EdgeInsets.symmetric(
          horizontal: unit * OreTokens.buttonPadMdHUnits,
          vertical: unit * (OreTokens.buttonPadMdVUnits - 2),
        );
      case OreButtonSize.lg:
        return EdgeInsets.symmetric(
          horizontal: unit * OreTokens.buttonPadLgHUnits,
          vertical: unit * (OreTokens.buttonPadLgVUnits - 2),
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
        shadowColor: colors.borderLight.withValues(alpha: 0.6),
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
          background: _pick(
            colors.accent,
            colors.accentHover,
            colors.accentPressed,
            hovered,
            pressed,
          ),
          borderColor: colors.border,
          shadowColor: colors.accentPressed,
          highlightColor: coloredHighlight,
          textColor: colors.textInverse,
        );
      case OreButtonVariant.danger:
        return _DropdownColors(
          background: _pick(
            colors.danger,
            colors.dangerHover,
            colors.dangerPressed,
            hovered,
            pressed,
          ),
          borderColor: colors.border,
          shadowColor: colors.dangerPressed,
          highlightColor: coloredHighlight,
          textColor: colors.textInverse,
        );
      case OreButtonVariant.secondary:
        return _DropdownColors(
          background: _pick(
            colors.surface,
            colors.surfaceHover,
            colors.surfacePressed,
            hovered,
            pressed,
          ),
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

class _DropdownMenuPanel<T> extends StatefulWidget {
  const _DropdownMenuPanel({
    required this.width,
    required this.itemHeight,
    required this.maxHeight,
    required this.padding,
    required this.items,
    required this.colors,
    required this.textStyle,
    required this.placement,
    required this.onSelected,
  });

  final double width;
  final double itemHeight;
  final double maxHeight;
  final EdgeInsetsGeometry padding;
  final List<OreDropdownItem<T>> items;
  final OreColors colors;
  final TextStyle textStyle;
  final _MenuPlacement placement;
  final ValueChanged<T> onSelected;

  @override
  State<_DropdownMenuPanel<T>> createState() => _DropdownMenuPanelState<T>();
}

class _DropdownMenuPanelState<T> extends State<_DropdownMenuPanel<T>> {
  late final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemBackground =
        Color.lerp(
          widget.colors.background,
          isDark ? Colors.white : Colors.black,
          isDark ? 0.22 : 0.16,
        ) ??
        widget.colors.background;
    final borderWidth = OreTheme.of(context).borderWidth;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.items.length; i++)
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: widget.itemHeight),
            child: _DropdownMenuItem<T>(
              item: widget.items[i],
              textStyle: widget.textStyle,
              background: itemBackground,
              borderColor: widget.colors.border,
              borderWidth: borderWidth,
              padding: widget.padding,
              showBlackTop: widget.placement == _MenuPlacement.above
                  ? i == 0
                  : false,
              showBlackBottom: widget.placement == _MenuPlacement.above
                  ? false
                  : i == widget.items.length - 1,
              whiteInsetTop: widget.placement == _MenuPlacement.below && i == 0
                  ? _menuInnerBorderWidth
                  : 0.0,
              whiteInsetBottom:
                  widget.placement == _MenuPlacement.above &&
                      i == widget.items.length - 1
                  ? _menuInnerBorderWidth
                  : 0.0,
              onSelected: widget.onSelected,
            ),
          ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      child: SizedBox(
        width: widget.width,
        child: OreScrollbar(
          controller: _controller,
          child: SingleChildScrollView(controller: _controller, child: content),
        ),
      ),
    );
  }
}

class _DropdownMenuItem<T> extends StatelessWidget {
  const _DropdownMenuItem({
    required this.item,
    required this.textStyle,
    required this.background,
    required this.borderColor,
    required this.borderWidth,
    required this.padding,
    required this.showBlackTop,
    required this.showBlackBottom,
    required this.whiteInsetTop,
    required this.whiteInsetBottom,
    required this.onSelected,
  });

  final OreDropdownItem<T> item;
  final TextStyle textStyle;
  final Color background;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final bool showBlackTop;
  final bool showBlackBottom;
  final double whiteInsetTop;
  final double whiteInsetBottom;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelected(item.value),
        child: DefaultTextStyle.merge(
          style: textStyle,
          child: _MenuSurface(
            color: background,
            borderColor: borderColor,
            innerBorderColor: Colors.white,
            borderWidth: borderWidth,
            padding: padding,
            alignment: Alignment.centerLeft,
            showBlackTop: showBlackTop,
            showBlackBottom: showBlackBottom,
            whiteInsetTop: whiteInsetTop,
            whiteInsetBottom: whiteInsetBottom,
            child: item.child,
          ),
        ),
      ),
    );
  }
}

class _MenuSurface extends StatelessWidget {
  const _MenuSurface({
    required this.child,
    required this.color,
    required this.borderColor,
    required this.innerBorderColor,
    required this.borderWidth,
    required this.padding,
    this.alignment = Alignment.centerLeft,
    this.showBlackTop = true,
    this.showBlackBottom = true,
    this.whiteInsetTop = 0.0,
    this.whiteInsetBottom = 0.0,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final Color innerBorderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final bool showBlackTop;
  final bool showBlackBottom;
  final double whiteInsetTop;
  final double whiteInsetBottom;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding.resolve(Directionality.of(context));
    final innerWidth = _menuInnerBorderWidth;
    final leftInset = borderWidth;
    final rightInset = borderWidth;
    final topInset = showBlackTop ? borderWidth : 0.0;
    final bottomInset = showBlackBottom ? borderWidth : 0.0;
    final whiteTopInset = topInset + whiteInsetTop;
    final whiteBottomInset = bottomInset + whiteInsetBottom;

    return Container(
      decoration: BoxDecoration(color: color),
      child: Stack(
        alignment: alignment,
        children: [
          if (borderWidth > 0) ...[
            if (showBlackTop)
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
            if (showBlackBottom)
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
          Positioned(
            left: leftInset,
            right: rightInset,
            top: whiteTopInset,
            height: innerWidth,
            child: Container(color: innerBorderColor),
          ),
          Positioned(
            left: leftInset,
            top: whiteTopInset,
            bottom: whiteBottomInset,
            width: innerWidth,
            child: Container(color: innerBorderColor),
          ),
          Positioned(
            right: rightInset,
            top: whiteTopInset,
            bottom: whiteBottomInset,
            width: innerWidth,
            child: Container(color: innerBorderColor),
          ),
          Positioned(
            left: leftInset,
            right: rightInset,
            bottom: whiteBottomInset,
            height: innerWidth,
            child: Container(color: innerBorderColor),
          ),
          Padding(padding: resolvedPadding, child: child),
        ],
      ),
    );
  }
}
