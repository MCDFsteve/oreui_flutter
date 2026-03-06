import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class OrePixelIcon extends StatefulWidget {
  const OrePixelIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.pixelSize = 2,
    this.semanticLabel,
    this.textDirection,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final double pixelSize;
  final String? semanticLabel;
  final TextDirection? textDirection;

  @override
  State<OrePixelIcon> createState() => _OrePixelIconState();
}

class _OrePixelIconState extends State<OrePixelIcon> {
  final GlobalKey _boundaryKey = GlobalKey();
  ui.Image? _image;
  bool _captureScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleCapture();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleCapture();
  }

  @override
  void didUpdateWidget(covariant OrePixelIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.icon != widget.icon ||
        oldWidget.size != widget.size ||
        oldWidget.color != widget.color ||
        oldWidget.pixelSize != widget.pixelSize ||
        oldWidget.semanticLabel != widget.semanticLabel ||
        oldWidget.textDirection != widget.textDirection) {
      _scheduleCapture();
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  void _scheduleCapture() {
    if (_captureScheduled) return;
    _captureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  Future<void> _capture() async {
    _captureScheduled = false;
    final boundary =
        _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || !boundary.hasSize) return;
    final image = await boundary.toImage(pixelRatio: 1.0);
    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() {
      _image?.dispose();
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = widget.size ?? theme.size ?? 16;
    final pixelSize = widget.pixelSize <= 0 ? 1.0 : widget.pixelSize;
    final rasterSize = math.max(1.0, size / pixelSize);
    final iconColor = widget.color ?? theme.color;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_image != null)
            RawImage(
              image: _image,
              width: size,
              height: size,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            )
          else
            SizedBox(width: size, height: size),
          Opacity(
            opacity: 0,
            child: RepaintBoundary(
              key: _boundaryKey,
              child: SizedBox(
                width: rasterSize,
                height: rasterSize,
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: rasterSize,
                    color: iconColor,
                    semanticLabel: widget.semanticLabel,
                    textDirection: widget.textDirection,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
