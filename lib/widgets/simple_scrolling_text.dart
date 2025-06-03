import 'package:flutter/material.dart';

class SimpleScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const SimpleScrollingText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<SimpleScrollingText> createState() => _SimpleScrollingTextState();
}

class _SimpleScrollingTextState extends State<SimpleScrollingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Animación de 0 a 1 (de derecha a izquierda)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Calcula el desplazamiento para que el texto se mueva completamente de derecha a izquierda
              final textWidth = _getTextWidth(widget.text, widget.style);
              final containerWidth = constraints.maxWidth;

              // Si el texto es más corto que el contenedor, no animar
              if (textWidth <= containerWidth) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.text,
                    style: widget.style,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }

              // Animación: empieza desde la derecha, sale por la izquierda
              final totalDistance = containerWidth + textWidth;
              final offset = (1 - _animation.value) * containerWidth - (_animation.value * textWidth);

              return Transform.translate(
                offset: Offset(offset, 0),
                child: Text(
                  widget.text,
                  style: widget.style,
                  maxLines: 1,
                  softWrap: false,
                ),
              );
            },
          ),
        );
      },
    );
  }

  double _getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size.width;
  }
}