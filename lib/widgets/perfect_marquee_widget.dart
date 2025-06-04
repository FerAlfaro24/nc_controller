import 'package:flutter/material.dart';

class PerfectNewsMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double speed; // píxeles por segundo
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final Duration pauseBeforeStart;

  const PerfectNewsMarquee({
    super.key,
    required this.text,
    required this.style,
    this.speed = 50.0, // píxeles por segundo (ajustable)
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.pauseBeforeStart = const Duration(milliseconds: 1000),
  });

  @override
  State<PerfectNewsMarquee> createState() => _PerfectNewsMarqueeState();
}

class _PerfectNewsMarqueeState extends State<PerfectNewsMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _textWidth = 0;
  double _containerWidth = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(PerfectNewsMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style || oldWidget.speed != widget.speed) {
      _setupAnimation();
    }
  }

  void _setupAnimation() {
    // Medir el texto primero
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndStartAnimation();
    });
  }

  void _measureAndStartAnimation() {
    if (!mounted) return;

    // Medir ancho del texto
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    _textWidth = textPainter.size.width;

    // Obtener ancho del contenedor
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _containerWidth = renderBox.size.width - widget.padding.horizontal;

    print('📏 Marquee: Texto "${widget.text}" - Ancho: $_textWidth px');
    print('📐 Marquee: Contenedor - Ancho: $_containerWidth px');

    // Calcular la distancia total que debe recorrer el texto
    // Desde que aparece por la derecha hasta que desaparece por la izquierda
    final double totalDistance = _containerWidth + _textWidth;

    // Calcular duración basada en la velocidad
    final Duration animationDuration = Duration(
      milliseconds: (totalDistance / widget.speed * 1000).round(),
    );

    print('🎬 Marquee: Distancia total: ${totalDistance.toStringAsFixed(1)} px');
    print('⏱️ Marquee: Duración: ${animationDuration.inMilliseconds} ms');
    print('🏃 Marquee: Velocidad: ${widget.speed} px/s');

    // Recrear el controller con la nueva duración
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();

    _controller = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    // Animación lineal de 0 a 1
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Listener para reiniciar cuando termine
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print('🔄 Marquee: Ciclo completado, reiniciando...');
        // Reiniciar inmediatamente SIN pausa (como las noticias de TV)
        _controller.reset();
        _controller.forward();
      }
    });

    setState(() {
      _isReady = true;
    });

    // Iniciar la animación después de una pequeña pausa
    Future.delayed(widget.pauseBeforeStart, () {
      if (mounted) {
        print('🚀 Marquee: Iniciando animación');
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
            // Si las dimensiones cambiaron, recalcular
            final newContainerWidth = constraints.maxWidth;
            if (newContainerWidth != _containerWidth && _isReady) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _measureAndStartAnimation();
              });
            }

            // Mostrar texto estático mientras se prepara
            if (!_isReady) {
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

            // Widget animado
            return ClipRect(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // Calcular posición exacta
                  // Posición inicial: texto empieza fuera por la derecha
                  final double startX = _containerWidth;
                  // Posición final: texto termina fuera por la izquierda
                  final double endX = -_textWidth;
                  // Distancia total
                  final double totalDistance = startX - endX;

                  // Posición actual basada en el progreso de la animación
                  final double currentX = startX - (_animation.value * totalDistance);

                  return Transform.translate(
                    offset: Offset(currentX, 0),
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

// Versión aún más simple y directa
class TVNewsMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const TVNewsMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 10),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<TVNewsMarquee> createState() => _TVNewsMarqueeState();
}

class _TVNewsMarqueeState extends State<TVNewsMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(TVNewsMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.duration != widget.duration) {
      _initializeAnimation();
    }
  }

  void _initializeAnimation() {
    // Disponer del controller anterior si existe
    if (mounted) {
      _controller.dispose();
    }

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Animación que va de 0 a 1
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Auto-restart cuando termine
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Reiniciar inmediatamente
        _controller.reset();
        _controller.forward();
      }
    });

    // Iniciar después de un breve delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
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
        child: ClipRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // Calcular posición usando las dimensiones reales
                  final containerWidth = constraints.maxWidth;

                  // Medir texto para calcular su ancho
                  final textPainter = TextPainter(
                    text: TextSpan(text: widget.text, style: widget.style),
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                  );
                  textPainter.layout();
                  final textWidth = textPainter.size.width;

                  // Movimiento de derecha a izquierda
                  // Inicia en: containerWidth (fuera por la derecha)
                  // Termina en: -textWidth (completamente fuera por la izquierda)
                  final startPosition = containerWidth;
                  final endPosition = -textWidth;
                  final totalTravel = startPosition - endPosition;

                  final currentPosition = startPosition - (_animation.value * totalTravel);

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
              );
            },
          ),
        ),
      ),
    );
  }
}