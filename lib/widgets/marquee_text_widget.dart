import 'package:flutter/material.dart';

class MarqueeTextWidget extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Border? border;

  const MarqueeTextWidget({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 10),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius,
    this.border,
  });

  @override
  State<MarqueeTextWidget> createState() => _MarqueeTextWidgetState();
}

class _MarqueeTextWidgetState extends State<MarqueeTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _needsScrolling = false;
  double _textWidth = 0;
  double _containerWidth = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Medir el texto inmediatamente
    _measureText();
  }

  @override
  void didUpdateWidget(MarqueeTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _controller.stop();
      _controller.reset();
      setState(() {
        _isReady = false;
      });
      _measureText();
    }
  }

  void _measureText() {
    // Medir el ancho del texto
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    _textWidth = textPainter.size.width;

    print('📏 Marquee: Texto "${widget.text}" tiene ancho: $_textWidth');

    // Esperar a que el widget se construya para obtener el ancho del contenedor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollingNeeded();
    });
  }

  void _checkIfScrollingNeeded() {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _containerWidth = renderBox.size.width - widget.padding.horizontal;

      print('📐 Marquee: Contenedor tiene ancho: $_containerWidth');
      print('🔍 Marquee: ¿Necesita scroll? ${_textWidth > _containerWidth}');

      final needsScrolling = _textWidth > _containerWidth;

      setState(() {
        _needsScrolling = needsScrolling;
        _isReady = true;
      });

      if (_needsScrolling) {
        _startScrolling();
      }
    }
  }

  void _startScrolling() {
    if (!mounted || !_needsScrolling) return;

    print('🎬 Marquee: Iniciando animación de scroll');

    // Esperar un momento antes de empezar
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
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        border: widget.border,
      ),
      child: Padding(
        padding: widget.padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Actualizar el ancho del contenedor si cambió
            final newContainerWidth = constraints.maxWidth;
            if (newContainerWidth != _containerWidth && _isReady) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkIfScrollingNeeded();
              });
            }

            // Mostrar indicador de carga mientras se prepara
            if (!_isReady) {
              return Center(
                child: Text(
                  widget.text,
                  style: widget.style.copyWith(color: widget.style.color?.withOpacity(0.7)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }

            return ClipRect(
              child: _needsScrolling ? _buildScrollingText() : _buildStaticText(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStaticText() {
    print('📍 Marquee: Mostrando texto estático');
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildScrollingText() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calcular posición del texto
        final spacing = 50.0; // Espacio entre repeticiones
        final totalWidth = _textWidth + spacing;
        final position = _animation.value * totalWidth;

        return Stack(
          children: [
            // Texto principal
            Positioned(
              left: _containerWidth - position,
              child: Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            // Texto repetido para continuidad
            Positioned(
              left: _containerWidth - position + totalWidth,
              child: Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget simplificado y más confiable para el marquee
class SimpleMarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const SimpleMarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 8),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<SimpleMarqueeText> createState() => _SimpleMarqueeTextState();
}

class _SimpleMarqueeTextState extends State<SimpleMarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _needsAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAnimationNeeded();
    });
  }

  @override
  void didUpdateWidget(SimpleMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.stop();
      _controller.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfAnimationNeeded();
      });
    }
  }

  void _checkIfAnimationNeeded() {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final containerWidth = renderBox.size.width - widget.padding.horizontal;

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final needsAnimation = textPainter.size.width > containerWidth;

    if (needsAnimation != _needsAnimation) {
      setState(() {
        _needsAnimation = needsAnimation;
      });

      if (_needsAnimation) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _needsAnimation) {
            _controller.repeat();
          }
        });
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: widget.padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!_needsAnimation) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.text,
                  style: widget.style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }

            return ClipRect(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final textPainter = TextPainter(
                    text: TextSpan(text: widget.text, style: widget.style),
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                  );
                  textPainter.layout();

                  final textWidth = textPainter.size.width;
                  final containerWidth = constraints.maxWidth;
                  final totalDistance = containerWidth + textWidth + 30;

                  final offset = _animation.value * totalDistance - textWidth;

                  return Transform.translate(
                    offset: Offset(containerWidth - offset, 0),
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
        ),
      ),
    );
  }
}