import 'dart:async';
import 'package:flutter/material.dart';
import 'ore_card.dart';
import 'ore_icon_button.dart';

final _activeToasts = Expando<OreToastController>();

class OreToastController {
  OverlayEntry? _entry;
  Timer? _timer;
  void close() {
    _timer?.cancel();
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }
}

/// Shows one dismissible Ore notification per overlay. New messages replace it.
OreToastController showOreToast(
  BuildContext context,
  Widget content, {
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _activeToasts[overlay]?.close();
  final controller = OreToastController();
  _activeToasts[overlay] = controller;
  final themes = InheritedTheme.capture(from: context, to: overlay.context);
  controller._entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.paddingOf(context).top + 16,
      right: 16,
      left: 16,
      child: Align(
        alignment: Alignment.topRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: themes.wrap(
            _ToastLifetime(
              controller: controller,
              duration: duration,
              child: Semantics(
                liveRegion: true,
                child: OreCard(
                  padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: content),
                      OreIconButton(
                        icon: const Icon(Icons.close),
                        tooltip: '关闭提示',
                        onPressed: controller.close,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(controller._entry!);
  return controller;
}

class _ToastLifetime extends StatefulWidget {
  const _ToastLifetime({
    required this.controller,
    required this.duration,
    required this.child,
  });
  final OreToastController controller;
  final Duration duration;
  final Widget child;
  @override
  State<_ToastLifetime> createState() => _ToastLifetimeState();
}

class _ToastLifetimeState extends State<_ToastLifetime> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller._timer?.cancel();
    if (!MediaQuery.accessibleNavigationOf(context)) {
      widget.controller._timer = Timer(
        widget.duration,
        widget.controller.close,
      );
    }
  }

  @override
  void dispose() {
    widget.controller._timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
