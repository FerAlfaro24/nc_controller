import 'package:flutter/material.dart';

class FixedMarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final Duration pauseDuration; // Pausa antes de reiniciar

  const FixedMarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 8),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.pauseDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<FixedMarqueeText> createState() => _FixedMarqueeTextState();
}

class _FixedMarqueeTextState extends State<FixedMarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _needsScrolling = false;
  double _textWidth = 0;
  double _containerWidth = 0;
  bool _isInitialized = false;

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

    // Listener para reiniciar la animación
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _needsScrolling) {
        _restartAnimation();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateDimensions();
    });
  }

  @override
  void didUpdateWidget(FixedMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambió el texto, recalcular dimensiones
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _controller.stop();
      _controller.reset();
      setState(() {
        _isInitialized = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateDimensions();
      });
    }
  }

  void _calculateDimensions() {
    if (!mounted) return;

    // Medir el ancho del texto
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    _textWidth = textPainter.size.width;

    // Obtener el ancho del contenedor
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _containerWidth = renderBox.size.width - widget.padding.horizontal;

      print('📏 Marquee: Texto "${widget.text}" - Ancho: $_textWidth');
      print('📐 Marquee: Contenedor - Ancho: $_containerWidth');

      final needsScrolling = _textWidth > _containerWidth;
      print('🔍 Marquee: ¿Necesita scroll? $needsScrolling');

      if (mounted) {
        setState(() {
          _needsScrolling = needsScrolling;
          _isInitialized = true;
        });

        if (_needsScrolling) {
          _startScrolling();
        }
      }
    }
  }

  void _startScrolling() {
    if (!mounted || !_needsScrolling) return;

    print('🎬 Marquee: Iniciando animación');

    // Esperar un momento antes de empezar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _needsScrolling) {
        _controller.forward();
      }
    });
  }

  void _restartAnimation() {
    if (!mounted || !_needsScrolling) return;

    print('🔄 Marquee: Reiniciando animación');

    // Pausa antes de reiniciar
    Future.delayed(widget.pauseDuration, () {
      if (mounted && _needsScrolling) {
        _controller.reset();
        _controller.forward();
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: widget.padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Actualizar ancho del contenedor si cambió
            final newContainerWidth = constraints.maxWidth;
            if (newContainerWidth != _containerWidth && _isInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _calculateDimensions();
              });
            }

            // Mostrar loading mientras se inicializa
            if (!_isInitialized) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.text,
                  style: widget.style.copyWith(
                    color: widget.style.color?.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }

            // Si no necesita scroll, mostrar texto estático
            if (!_needsScrolling) {
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

            // Mostrar texto con animación
            return ClipRect(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // Calcular la posición del texto
                  // El texto debe moverse de derecha a izquierda completamente
                  final double startPosition = _containerWidth;
                  final double endPosition = -_textWidth;
                  final double totalDistance = startPosition - endPosition;

                  final double currentPosition = startPosition - (_animation.value * totalDistance);

                  return Transform.translate(
                    offset: Offset(currentPosition, 0),
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

// Widget aún más simple y confiable
class SuperSimpleMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const SuperSimpleMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 6),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<SuperSimpleMarquee> createState() => _SuperSimpleMarqueeState();
}

class _SuperSimpleMarqueeState extends State<SuperSimpleMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Animación simple: de derecha a izquierda
    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),  // Empieza fuera por la derecha
      end: const Offset(-1.0, 0.0),   // Termina fuera por la izquierda
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Repetir indefinidamente
    _controller.repeat();
  }

  @override
  void didUpdateWidget(SuperSimpleMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      // Reiniciar animación si cambia el texto
      _controller.reset();
      _controller.repeat();
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
        child: ClipRect(
          child: SlideTransition(
            position: _animation,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}