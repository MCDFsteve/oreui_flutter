import 'package:flutter/material.dart';
import '../theme/ore_theme.dart';
import 'ore_card.dart';
import 'ore_icon_button.dart';

/// A square Ore dialog, with keyboard insets and bounded content.
class OreDialog extends StatelessWidget {
  const OreDialog({
    super.key,
    required this.child,
    this.maxWidth = 560,
    this.insetPadding = const EdgeInsets.all(20),
    this.surface = true,
  });
  final Widget child;
  final double maxWidth;
  final EdgeInsets insetPadding;

  /// Disable when the child already supplies its own Ore surface.
  final bool surface;

  @override
  Widget build(BuildContext context) => AnimatedPadding(
    padding: MediaQuery.viewInsetsOf(context) + insetPadding,
    duration: const Duration(milliseconds: 100),
    child: MediaQuery.removeViewInsets(
      context: context,
      removeLeft: true,
      removeTop: true,
      removeRight: true,
      removeBottom: true,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: surface
                ? OreCard(padding: EdgeInsets.zero, child: child)
                : child,
          ),
        ),
      ),
    ),
  );
}

class OreAlertDialog extends StatelessWidget {
  const OreAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.maxWidth = 560,
  });
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => OreDialog(
    maxWidth: maxWidth,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            namesRoute: true,
            child: DefaultTextStyle.merge(
              style: OreTheme.of(context).typography.choiceTitle,
              child: title,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(child: SingleChildScrollView(child: content)),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(spacing: 8, runSpacing: 8, children: actions),
          ),
        ],
      ),
    ),
  );
}

Future<T?> showOreDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  return navigator.push<T>(
    RawDialogRoute<T>(
      settings: routeSettings,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: const Color(0x99000000),
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (context, _, _) => themes.wrap(
        SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: Builder(builder: builder),
          ),
        ),
      ),
      transitionBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

Future<T?> showOreModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool showCloseButton = false,
}) => showOreDialog<T>(
  context: context,
  builder: (context) => AnimatedPadding(
    padding: MediaQuery.viewInsetsOf(context),
    duration: const Duration(milliseconds: 100),
    child: LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 640,
            maxHeight: constraints.maxHeight * (isScrollControlled ? .95 : .65),
          ),
          child: OreCard(
            padding: EdgeInsets.zero,
            child: MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showCloseButton)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: OreIconButton(
                        icon: const Icon(Icons.close),
                        tooltip: '关闭',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  Flexible(child: Builder(builder: builder)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
