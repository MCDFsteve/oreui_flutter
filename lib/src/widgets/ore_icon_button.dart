import 'package:flutter/material.dart';

import '../theme/ore_theme.dart';
import 'ore_pixel_icon.dart';
import 'ore_tooltip.dart';

/// An icon-only action with a transparent touch target in every state.
class OreIconButton extends StatefulWidget {
  const OreIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconSize = 24,
    this.color,
    this.focusNode,
    this.autofocus = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double iconSize;
  final Color? color;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<OreIconButton> createState() => _OreIconButtonState();
}

class _OreIconButtonState extends State<OreIconButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = OreTheme.of(context).colors;
    final enabled = widget.onPressed != null;
    final color = !enabled
        ? c.textDisabled
        : _pressed
        ? c.accent
        : _hovered || _focused
        ? c.success
        : widget.color ?? c.textPrimary;
    final icon = widget.icon;
    Widget child = Semantics(
      button: true,
      enabled: enabled,
      label: widget.tooltip,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: enabled,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: () => setState(() => _pressed = false),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Transform.scale(
                scale: _pressed ? .9 : 1,
                child: IconTheme(
                  data: IconThemeData(color: color, size: widget.iconSize),
                  child: icon is Icon && icon.icon != null
                      ? OrePixelIcon(
                          icon: icon.icon!,
                          color: color,
                          size: icon.size ?? widget.iconSize,
                          semanticLabel: icon.semanticLabel,
                        )
                      : icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      child = OreTooltip(message: widget.tooltip!, child: child);
    }
    return child;
  }
}
