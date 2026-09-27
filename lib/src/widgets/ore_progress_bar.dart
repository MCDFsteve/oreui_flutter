import 'package:flutter/widgets.dart';

import '../theme/ore_theme.dart';

/// A square, recessed progress track. A null value animates a moving block.
class OreProgressBar extends StatefulWidget {
  const OreProgressBar({
    super.key,
    this.value,
    this.height = 12,
    this.semanticLabel,
  });

  final double? value;
  final double height;
  final String? semanticLabel;

  @override
  State<OreProgressBar> createState() => _OreProgressBarState();
}

class _OreProgressBarState extends State<OreProgressBar>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  void _syncAnimation() {
    if (widget.value == null && !MediaQuery.disableAnimationsOf(context)) {
      if (!_animation.isAnimating) _animation.repeat(reverse: true);
    } else {
      _animation.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(OreProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OreTheme.of(context).colors;
    final value = widget.value?.clamp(0.0, 1.0);
    return Semantics(
      label: widget.semanticLabel ?? '加载中',
      value: value == null ? null : '${(value * 100).round()}%',
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: colors.surfaceDark,
          border: Border.all(color: colors.border, width: 2),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) => Align(
            alignment: value == null
                ? AlignmentDirectional(_animation.value * 2 - 1, 0)
                : AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: value ?? .25,
              heightFactor: 1,
              child: ColoredBox(color: colors.success),
            ),
          ),
        ),
      ),
    );
  }
}
