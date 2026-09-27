import 'package:flutter/material.dart';
import '../theme/ore_theme.dart';
import 'ore_button.dart';
import 'ore_card.dart';

/// Square handles with the platform text editing/clipboard behavior preserved.
class OreTextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  @override
  Size getHandleSize(double textLineHeight) => const Size(16, 20);

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      Offset(
        type == TextSelectionHandleType.left
            ? 14
            : type == TextSelectionHandleType.right
            ? 2
            : 8,
        0,
      );

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 16,
      height: 20,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 12,
          height: 16,
          decoration: BoxDecoration(
            color: OreTheme.of(context).colors.success,
            border: Border.all(
              color: OreTheme.of(context).colors.border,
              width: 2,
            ),
          ),
        ),
      ),
    ),
  );
}

class OreTextSelectionToolbar extends StatelessWidget {
  const OreTextSelectionToolbar({
    super.key,
    required this.anchors,
    required this.items,
  });
  final TextSelectionToolbarAnchors anchors;
  final List<ContextMenuButtonItem> items;

  static Widget editable(BuildContext context, EditableTextState state) =>
      OreTextSelectionToolbar(
        anchors: state.contextMenuAnchors,
        items: state.contextMenuButtonItems,
      );

  static Widget selectable(BuildContext context, SelectableRegionState state) =>
      OreTextSelectionToolbar(
        anchors: state.contextMenuAnchors,
        items: state.contextMenuButtonItems,
      );

  String _label(BuildContext context, ContextMenuButtonItem item) {
    if (item.label != null) return item.label!;
    final labels = MaterialLocalizations.of(context);
    return switch (item.type) {
      ContextMenuButtonType.cut => labels.cutButtonLabel,
      ContextMenuButtonType.copy => labels.copyButtonLabel,
      ContextMenuButtonType.paste => labels.pasteButtonLabel,
      ContextMenuButtonType.selectAll => labels.selectAllButtonLabel,
      ContextMenuButtonType.delete => labels.deleteButtonTooltip,
      ContextMenuButtonType.share => '分享',
      ContextMenuButtonType.lookUp => '查询',
      ContextMenuButtonType.searchWeb => '搜索',
      _ => '操作',
    };
  }

  @override
  Widget build(BuildContext context) => CustomSingleChildLayout(
    delegate: TextSelectionToolbarLayoutDelegate(
      anchorAbove: anchors.primaryAnchor,
      anchorBelow: anchors.secondaryAnchor ?? anchors.primaryAnchor,
    ),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: OreCard(
        padding: const EdgeInsets.all(4),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final item in items)
              OreButton(
                size: OreButtonSize.sm,
                onPressed: item.onPressed,
                child: Text(_label(context, item)),
              ),
          ],
        ),
      ),
    ),
  );
}

class OreSelectionArea extends StatelessWidget {
  const OreSelectionArea({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SelectionArea(
    selectionControls: OreTextSelectionControls(),
    contextMenuBuilder: OreTextSelectionToolbar.selectable,
    child: child,
  );
}

class OreSelectableText extends StatelessWidget {
  const OreSelectableText(this.data, {super.key, this.style});
  final String data;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) => SelectableText(
    data,
    style: style ?? OreTheme.of(context).typography.body,
    selectionControls: OreTextSelectionControls(),
    contextMenuBuilder: OreTextSelectionToolbar.editable,
    cursorColor: OreTheme.of(context).colors.success,
    cursorRadius: Radius.zero,
  );
}
