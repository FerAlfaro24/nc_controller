import 'package:flutter/material.dart';

class CompleteTextMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const CompleteTextMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 8),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<CompleteTextMarquee> createState() => _CompleteTextMarqueeState();
}

class _CompleteTextMarqueeState extends State<CompleteTextMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _textWidth = 0;
  double _containerWidth = 0;
  bool _needsAnimation = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    print('🎬 CompleteMarquee: Inicializando...');

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _needsAnimation) {
        print('🔄 CompleteMarquee: Ciclo completado, reiniciando...');
        _controller.reset();
        _controller.forward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndStart();
    });
  }

  @override
  void didUpdateWidget(CompleteTextMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      print('📝 CompleteMarquee: Texto cambió, remidiendo...');
      _controller.stop();
      _controller.reset();
      setState(() {
        _isReady = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _measureAndStart();
      });
    }
  }

  void _measureAndStart() {
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
    if (renderBox == null) return;

    _containerWidth = renderBox.size.width - widget.padding.horizontal;

    print('📏 CompleteMarquee: Texto "${widget.text}"');
    print('📏 CompleteMarquee: Ancho texto: $_textWidth px');
    print('📏 CompleteMarquee: Ancho contenedor: $_containerWidth px');

    final needsAnimation = _textWidth > _containerWidth;
    print('🔍 CompleteMarquee: ¿Necesita animación? $needsAnimation');

    setState(() {
      _needsAnimation = needsAnimation;
      _isReady = true;
    });

    if (_needsAnimation) {
      print('🚀 CompleteMarquee: Iniciando animación...');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _needsAnimation) {
          _controller.forward();
        }
      });
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
            // Si las dimensiones cambiaron, remedir
            final newContainerWidth = constraints.maxWidth;
            if (newContainerWidth != _containerWidth && _isReady) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _measureAndStart();
              });
            }

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

            // Si no necesita animación, mostrar texto normal
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

            // ANIMACIÓN QUE MUESTRA TODO EL TEXTO
            return ClipRect(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    // Calcular posición para que TODO el texto sea visible
                    // Empieza desde la derecha del contenedor
                    final startX = _containerWidth;
                    // Termina cuando el final del texto sale por la izquierda
                    final endX = -_textWidth;
                    final totalDistance = startX - endX;

                    final currentX = startX - (_animation.value * totalDistance);

                    return Transform.translate(
                      offset: Offset(currentX, 0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.text,
                          style: widget.style,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible, // ¡CLAVE!
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Versión alternativa con doble texto para continuidad
class ContinuousMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const ContinuousMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 10),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<ContinuousMarquee> createState() => _ContinuousMarqueeState();
}

class _ContinuousMarqueeState extends State<ContinuousMarquee>
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

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Repetir indefinidamente
    _controller.repeat();

    print('✅ ContinuousMarquee: Animación iniciada');
  }

  @override
  void didUpdateWidget(ContinuousMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // Crear texto duplicado con espaciado
                  final String doubleText = '${widget.text}     •     ${widget.text}     •     ';

                  // Medir el texto individual
                  final textPainter = TextPainter(
                    text: TextSpan(text: widget.text, style: widget.style),
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                  );
                  textPainter.layout();
                  final textWidth = textPainter.size.width;

                  // Calcular desplazamiento
                  final containerWidth = constraints.maxWidth;
                  final cycleDistance = textWidth + 50; // texto + espaciado
                  final offset = (_animation.value * cycleDistance) % cycleDistance;

                  return Transform.translate(
                    offset: Offset(containerWidth - offset, 0),
                    child: Text(
                      doubleText,
                      style: widget.style,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
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

// Versión súper simple que GARANTIZA mostrar todo el texto
class FullTextMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const FullTextMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 8),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<FullTextMarquee> createState() => _FullTextMarqueeState();
}

class _FullTextMarqueeState extends State<FullTextMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.repeat();
  }

  @override
  void didUpdateWidget(FullTextMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
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
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.2, 0.0), // Empieza más a la derecha
                  end: const Offset(-1.2, 0.0),   // Termina más a la izquierda
                ).animate(_controller),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.text,
                    style: widget.style,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}