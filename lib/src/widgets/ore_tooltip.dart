import 'dart:async';
import 'package:flutter/widgets.dart';
import 'ore_card.dart';

/// A squared Ore tooltip, positioned within the viewport.
class OreTooltip extends StatefulWidget {
  const OreTooltip({super.key, required this.message, required this.child});
  final String message;
  final Widget child;
  @override
  State<OreTooltip> createState() => _OreTooltipState();
}

class _OreTooltipState extends State<OreTooltip> {
  final _overlay = OverlayPortalController();
  Timer? _timer;
  void _show() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _overlay.show();
    });
  }

  void _hide() {
    _timer?.cancel();
    _overlay.hide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _overlay,
    overlayChildBuilder: (overlayContext) {
      final box = context.findRenderObject()! as RenderBox;
      final overlayBox =
          Overlay.of(context).context.findRenderObject()! as RenderBox;
      final origin = box.localToGlobal(Offset.zero, ancestor: overlayBox);
      return IgnorePointer(
        child: CustomSingleChildLayout(
          delegate: TextSelectionToolbarLayoutDelegate(
            anchorAbove: origin + Offset(box.size.width / 2, -8),
            anchorBelow:
                origin + Offset(box.size.width / 2, box.size.height + 8),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: OreCard(
              padding: const EdgeInsets.all(8),
              child: Text(widget.message),
            ),
          ),
        ),
      );
    },
    child: MouseRegion(
      onEnter: (_) => _show(),
      onExit: (_) => _hide(),
      child: Focus(
        canRequestFocus: false,
        onFocusChange: (focused) => focused ? _show() : _hide(),
        child: Listener(onPointerDown: (_) => _hide(), child: widget.child),
      ),
    ),
  );
}
