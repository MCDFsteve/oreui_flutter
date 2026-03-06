import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/ore_control_colors.dart';
import '../theme/ore_theme.dart';
import '../theme/ore_tokens.dart';
import 'ore_button.dart';

class OreChoiceButtons extends StatelessWidget {
  const OreChoiceButtons({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.size = OreButtonSize.md,
    this.fullWidth = false,
  });

  final List<Widget> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final OreButtonSize size;
  final bool fullWidth;

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final theme = OreTheme.of(context);
    final colors = resolveControlColors(context, theme.colors);
    final borderWidth = theme.borderWidth;
    final indicatorHeight =
        borderWidth * OreTokens.choiceIndicatorHeightUnits;
    final overlap = borderWidth * 2;

    final children = List.generate(items.length, (index) {
      final selected = index == selectedIndex;
      final indicatorBottom = borderWidth;
      final button = OreButton(
        onPressed: _enabled ? () => onChanged?.call(index) : null,
        size: size,
        variant:
            selected ? OreButtonVariant.primary : OreButtonVariant.secondary,
        forcePressed: selected,
        forcePressedKeepsColor: selected,
        child: items[index],
      );
      final decorated = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          if (selected)
            Positioned(
              left: 0,
              right: 0,
              bottom: indicatorBottom,
              height: indicatorHeight,
              child: Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: OreTokens.choiceIndicatorWidthFactor,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: colors.textInverse),
                  ),
                ),
              ),
            ),
        ],
      );

      return decorated;
    });

    return _OverlapRow(
      overlap: overlap,
      expand: fullWidth,
      crossAxisAlignment: CrossAxisAlignment.end,
      textDirection: Directionality.of(context),
      children: children,
    );
  }
}

class _OverlapRow extends MultiChildRenderObjectWidget {
  const _OverlapRow({
    required this.overlap,
    required this.expand,
    required this.crossAxisAlignment,
    required this.textDirection,
    required super.children,
  });

  final double overlap;
  final bool expand;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderOverlapRow(
      overlap: overlap,
      expand: expand,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderOverlapRow renderObject,
  ) {
    renderObject
      ..overlap = overlap
      ..expand = expand
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = textDirection;
  }
}

class _OverlapParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderOverlapRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverlapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverlapParentData> {
  _RenderOverlapRow({
    required double overlap,
    required bool expand,
    required CrossAxisAlignment crossAxisAlignment,
    required TextDirection textDirection,
  })  : _overlap = overlap,
        _expand = expand,
        _crossAxisAlignment = crossAxisAlignment,
        _textDirection = textDirection;

  double _overlap;
  bool _expand;
  CrossAxisAlignment _crossAxisAlignment;
  TextDirection _textDirection;

  double get overlap => _overlap;
  set overlap(double value) {
    if (_overlap == value) return;
    _overlap = value;
    markNeedsLayout();
  }

  bool get expand => _expand;
  set expand(bool value) {
    if (_expand == value) return;
    _expand = value;
    markNeedsLayout();
  }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverlapParentData) {
      child.parentData = _OverlapParentData();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result,
      {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    final clampedOverlap = math.max(0.0, overlap);
    final children = getChildrenAsList();
    if (children.isEmpty) {
      size = constraints.constrain(Size.zero);
      return;
    }

    double maxHeight = 0.0;
    double totalWidth = 0.0;

    final bool canExpand =
        expand && constraints.hasBoundedWidth;

    if (canExpand) {
      final count = children.length;
      final width = constraints.maxWidth;
      final childWidth =
          (width + clampedOverlap * (count - 1)) / count;
      final childConstraints = BoxConstraints(
        minWidth: childWidth,
        maxWidth: childWidth,
        minHeight: 0,
        maxHeight: constraints.maxHeight,
      );

      for (final child in children) {
        child.layout(childConstraints, parentUsesSize: true);
        maxHeight = math.max(maxHeight, child.size.height);
      }
      totalWidth = width;
    } else {
      final childConstraints = constraints.loosen();
      for (final child in children) {
        child.layout(childConstraints, parentUsesSize: true);
        maxHeight = math.max(maxHeight, child.size.height);
        totalWidth += child.size.width;
      }
      totalWidth -= clampedOverlap * (children.length - 1);
    }

    size = constraints.constrain(Size(totalWidth, maxHeight));

    if (children.isEmpty) return;

    if (canExpand) {
      final count = children.length;
      final childWidth =
          (totalWidth + clampedOverlap * (count - 1)) / count;
      double x = _textDirection == TextDirection.rtl
          ? size.width - childWidth
          : 0.0;
      final step = childWidth - clampedOverlap;

      for (final child in children) {
        final childParentData =
            child.parentData as _OverlapParentData;
        final y = _crossAxisOffset(size.height, child.size.height);
        childParentData.offset = Offset(x, y);
        x += _textDirection == TextDirection.rtl ? -step : step;
      }
    } else {
      double x = _textDirection == TextDirection.rtl
          ? size.width
          : 0.0;
      for (final child in children) {
        final childParentData =
            child.parentData as _OverlapParentData;
        final y = _crossAxisOffset(size.height, child.size.height);
        if (_textDirection == TextDirection.rtl) {
          x -= child.size.width;
          childParentData.offset = Offset(x, y);
          x += clampedOverlap;
        } else {
          childParentData.offset = Offset(x, y);
          x += child.size.width - clampedOverlap;
        }
      }
    }
  }

  double _crossAxisOffset(double height, double childHeight) {
    switch (crossAxisAlignment) {
      case CrossAxisAlignment.start:
        return 0.0;
      case CrossAxisAlignment.center:
        return (height - childHeight) / 2;
      case CrossAxisAlignment.end:
        return height - childHeight;
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        return 0.0;
    }
  }
}
