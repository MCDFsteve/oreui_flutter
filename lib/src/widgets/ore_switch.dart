import 'package:flutter/widgets.dart';

import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';
import 'ore_surface.dart';

class OreSwitch extends StatefulWidget {
  const OreSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  State<OreSwitch> createState() => _OreSwitchState();
}

class _OreSwitchState extends State<OreSwitch> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final colors = theme.colors;
    final isOn = widget.value;
    final isHovered = _hovered && _enabled;
    final isPressed = _pressed && _enabled;

    final trackColor = _enabled
        ? LinearGradient(
            colors: [
              colors.accent,
              colors.accent,
              colors.borderLight,
              colors.borderLight,
            ],
            stops: const [0, 0.5, 0.5, 1],
          )
        : null;

    final track = Container(
      width: 58,
      height: 24,
      decoration: BoxDecoration(
        gradient: trackColor,
        color: _enabled ? null : colors.surface,
        border: Border.all(
          color: _enabled ? colors.border : colors.borderLight,
          width: theme.borderWidth,
        ),
      ),
    );

    final sliderColor = isHovered || isPressed
        ? colors.surfaceHover
        : colors.surface;

    final slider = SizedBox(
      width: 28,
      height: 28,
      child: OreSurface(
        color: sliderColor,
        borderColor: _enabled ? colors.border : colors.borderLight,
        highlightColor: colors.highlight,
        shadowColor: colors.shadow,
        borderWidth: theme.borderWidth,
        depth: isPressed ? 0 : theme.bevelDepth,
        pressed: isPressed,
        padding: EdgeInsets.zero,
        child: const SizedBox.shrink(),
      ),
    );

    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTap: _enabled ? () => widget.onChanged?.call(!isOn) : null,
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapUp: _enabled ? (_) => _setPressed(false) : null,
        onTapCancel: _enabled ? () => _setPressed(false) : null,
        behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: OreTokens.fast,
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                track,
                AnimatedPositioned(
                  duration: OreTokens.fast,
                  curve: Curves.easeOut,
                  left: isOn ? 28 : 0,
                  top: -2,
                  child: slider,
                ),
              ],
            ),
          ),
      ),
    );
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
