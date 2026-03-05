import 'package:flutter/widgets.dart';

import '../theme/ore_theme.dart';
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

class _OreSwitchState extends State<OreSwitch>
    with SingleTickerProviderStateMixin {
  static const double _trackWidth = 53.0;
  static const double _trackHeight = 24.0;
  static const double _knobSize = 28.0;
  static const double _maxLeft = _trackWidth - _knobSize;
  static const double _iconBaseSize = 16.0;
  static const double _iconVisualScale = 2.0;
  static const int _firstUpMs = 60;
  static const int _firstDownMs = 60;
  static const int _midPauseMs = 30;
  static const int _secondUpMs = 60;
  static const int _secondDownMs = 60;
  static const int _endPauseMs = 30;
  static const int _totalMs =
      _firstUpMs +
      _firstDownMs +
      _midPauseMs +
      _secondUpMs +
      _secondDownMs +
      _endPauseMs;

  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _wiggleController;
  late Animation<double> _leftAnimation;

  bool get _enabled => widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    );
    _leftAnimation =
        AlwaysStoppedAnimation(widget.value ? _maxLeft : 0.0);
  }

  @override
  void didUpdateWidget(covariant OreSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final theme = OreTheme.of(context);
      final highlightDepth =
          (theme.bevelDepth - 1).clamp(0.0, theme.bevelDepth).toDouble();
      final from = _leftAnimation.value;
      final to = widget.value ? _maxLeft : 0.0;
      final direction = widget.value ? 1.0 : -1.0;
      final overshoot = to + highlightDepth * direction;
      _leftAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: from, end: overshoot)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: _firstUpMs.toDouble(),
        ),
        TweenSequenceItem(
          tween: Tween(begin: overshoot, end: to)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: _firstDownMs.toDouble(),
        ),
        TweenSequenceItem(
          tween: ConstantTween(to),
          weight: _midPauseMs.toDouble(),
        ),
        TweenSequenceItem(
          tween: Tween(begin: to, end: overshoot)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: _secondUpMs.toDouble(),
        ),
        TweenSequenceItem(
          tween: Tween(begin: overshoot, end: to)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: _secondDownMs.toDouble(),
        ),
        TweenSequenceItem(
          tween: ConstantTween(to),
          weight: _endPauseMs.toDouble(),
        ),
      ]).animate(_wiggleController);
      _wiggleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final colors = theme.colors;
    final isOn = widget.value;
    final isHovered = _hovered && _enabled;
    final isPressed = _pressed && _enabled;
    final isInteracting = isHovered || isPressed;
    final highlightDepth =
        (theme.bevelDepth - 1).clamp(0.0, theme.bevelDepth).toDouble();
    final shadowDepth = theme.bevelDepth;
    final knobTop = _trackHeight - _knobSize;

    final borderColor = _enabled ? colors.border : colors.borderLight;
    final trackColor = _enabled
        ? (isOn ? colors.accent : colors.borderLight)
        : colors.surface;
    final iconBoxWidth = _trackWidth / 2;

    final track = SizedBox(
      width: _trackWidth,
      height: _trackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: trackColor,
                border: Border.all(
                  color: borderColor,
                  width: theme.borderWidth,
                ),
              ),
            ),
          ),
          if (isOn)
            Positioned(
              left: 0,
              top: 0,
              width: iconBoxWidth,
              height: _trackHeight,
              child: Center(
                child: ClipRect(
                  child: Transform.scale(
                    scale: _iconVisualScale,
                    child: Image.asset(
                      'assets/I.png',
                      package: 'oreui_flutter',
                      width: _iconBaseSize,
                      height: _iconBaseSize,
                      filterQuality: FilterQuality.none,
                      color: const Color(0xFFFFFFFF),
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              right: 0,
              top: 0,
              width: iconBoxWidth,
              height: _trackHeight,
              child: Center(
                child: ClipRect(
                  child: Transform.scale(
                    scale: _iconVisualScale,
                    child: Image.asset(
                      'assets/O.png',
                      package: 'oreui_flutter',
                      width: _iconBaseSize,
                      height: _iconBaseSize,
                      filterQuality: FilterQuality.none,
                      color: borderColor,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final sliderColor =
        isInteracting ? colors.surfaceHover : colors.surface;

    final slider = SizedBox(
      width: _knobSize,
      height: _knobSize,
      child: OreSurface(
        color: sliderColor,
        borderColor: _enabled ? colors.border : colors.borderLight,
        highlightColor: colors.highlight,
        shadowColor: colors.shadow,
        borderWidth: theme.borderWidth,
        depth: theme.bevelDepth,
        highlightDepth: highlightDepth,
        shadowDepth: shadowDepth,
        swapHighlightOnPressed: false,
        pressed: false,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              track,
              AnimatedBuilder(
                animation: _leftAnimation,
                child: slider,
                builder: (context, child) => Positioned(
                  left: _leftAnimation.value,
                  top: knobTop,
                  child: child!,
                ),
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
