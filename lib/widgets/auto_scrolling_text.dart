import 'package:flutter/material.dart';

class AutoScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final int maxLines;
  final TextAlign textAlign;
  final double spacing;

  const AutoScrollingText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 10),
    this.maxLines = 1,
    this.textAlign = TextAlign.left,
    this.spacing = 50.0,
  });

  @override
  State<AutoScrollingText> createState() => _AutoScrollingTextState();
}

class _AutoScrollingTextState extends State<AutoScrollingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _needsScrolling = false;
  double _textWidth = 0;
  double _containerWidth = 0;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTextAndStartAnimation();
    });
  }

  @override
  void didUpdateWidget(AutoScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _measureTextAndStartAnimation();
      });
    }
  }

  void _measureTextAndStartAnimation() {
    if (!mounted) return;

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    _textWidth = textPainter.size.width;

    final renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _containerWidth = renderBox.size.width;
      final needsScrolling = _textWidth > _containerWidth;

      if (needsScrolling != _needsScrolling) {
        setState(() {
          _needsScrolling = needsScrolling;
        });

        if (_needsScrolling) {
          _startScrolling();
        } else {
          _controller.stop();
          _controller.reset();
        }
      }
    }
  }

  void _startScrolling() {
    if (!mounted || !_needsScrolling) return;

    _controller.stop();
    _controller.reset();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _needsScrolling) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: _textKey,
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (constraints.maxWidth != _containerWidth) {
            _measureTextAndStartAnimation();
          }
        });

        if (!_needsScrolling) {
          return Text(
            widget.text,
            key: ValueKey(widget.text),
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: widget.textAlign,
          );
        }

        final totalWidth = _textWidth + widget.spacing;
        final offset = _animation.value * totalWidth;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -offset,
              child: Row(
                children: [
                  Text(
                    widget.text,
                    style: widget.style,
                    maxLines: widget.maxLines,
                    softWrap: false,
                  ),
                  SizedBox(width: widget.spacing),
                  Text(
                    widget.text,
                    style: widget.style,
                    maxLines: widget.maxLines,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}