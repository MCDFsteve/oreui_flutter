import 'package:flutter/material.dart';
import '../theme/ore_theme.dart';
import 'ore_checkbox.dart';
import 'ore_surface.dart';

class OreListTile extends StatefulWidget {
  const OreListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense = false,
    this.contentPadding,
    this.selected = false,
  });
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;
  final EdgeInsetsGeometry? contentPadding;
  final bool selected;
  @override
  State<OreListTile> createState() => _OreListTileState();
}

class _OreListTileState extends State<OreListTile> {
  bool _highlight = false;
  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    return FocusableActionDetector(
      enabled: widget.onTap != null,
      onShowFocusHighlight: (v) => setState(() => _highlight = v),
      onShowHoverHighlight: (v) => setState(() => _highlight = v),
      mouseCursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ColoredBox(
          color: _highlight
              ? theme.colors.surfaceHover
              : widget.selected
              ? theme.colors.selection
              : const Color(0x00000000),
          child: Padding(
            padding:
                widget.contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: widget.dense ? 8 : 12,
                ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle.merge(
                        style: theme.typography.body,
                        child: widget.title,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        DefaultTextStyle.merge(
                          style: theme.typography.caption,
                          child: widget.subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OreCheckboxListTile extends StatelessWidget {
  const OreCheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.dense = false,
    this.contentPadding,
  });
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final Widget title;
  final Widget? subtitle;
  final bool dense;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      checked: value == true,
      enabled: onChanged != null,
      child: OreListTile(
        title: title,
        subtitle: subtitle,
        dense: dense,
        contentPadding: contentPadding,
        onTap: onChanged == null ? null : () => onChanged!(!(value ?? false)),
        leading: ExcludeFocus(
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: OreCheckbox(
                value: value,
                onChanged: onChanged,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class OreRadioListTile<T> extends StatelessWidget {
  const OreRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.dense = false,
  });
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget title;
  final Widget? subtitle;
  final bool dense;
  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final c = theme.colors;
    final selected = value == groupValue;
    return MergeSemantics(
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: true,
        enabled: onChanged != null,
        child: OreListTile(
          title: title,
          subtitle: subtitle,
          dense: dense,
          onTap: onChanged == null ? null : () => onChanged!(value),
          leading: SizedBox(
            width: 28,
            height: 28,
            child: OreSurface(
              color: c.surfaceDark,
              borderColor: c.border,
              highlightColor: c.highlight,
              shadowColor: c.shadow,
              borderWidth: theme.borderWidth,
              depth: 2,
              padding: const EdgeInsets.all(5),
              child: ColoredBox(
                color: selected
                    ? onChanged == null
                          ? c.textDisabled
                          : c.success
                    : const Color(0x00000000),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
