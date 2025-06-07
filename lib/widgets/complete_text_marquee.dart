import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart'; // ← Importar el paquete

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
    this.duration = const Duration(seconds: 10),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<CompleteTextMarquee> createState() => _CompleteTextMarqueeState();
}

class _CompleteTextMarqueeState extends State<CompleteTextMarquee> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity, // ← IMPORTANTE: Ancho definido
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: widget.padding,
        child: _construirMarquee(),
      ),
    );
  }

  Widget _construirMarquee() {
    // ✅ FORZAR MARQUEE SIEMPRE (como en tu Android)
    return SizedBox(
      width: double.infinity, // ← CLAVE: Ancho definido
      height: widget.height - widget.padding.vertical,
      child: Marquee(
        text: widget.text,
        style: widget.style,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 80.0,                    // Más espacio entre repeticiones
        velocity: 60.0,                      // Velocidad más visible
        pauseAfterRound: Duration.zero,      // Sin pausas (como TV)
        startPadding: 0.0,
        accelerationDuration: Duration.zero, // Sin aceleración
        decelerationDuration: Duration.zero, // Sin desaceleración
        accelerationCurve: Curves.linear,
        decelerationCurve: Curves.linear,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

// ✅ VERSIÓN SÚPER SIMPLE QUE FUNCIONA SEGURO
class SimpleMarquee extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const SimpleMarquee({
    super.key,
    required this.text,
    required this.style,
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity, // ← CRÍTICO
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: padding,
        child: Marquee(
          text: text,
          style: style,
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          blankSpace: 100.0,                  // Espaciado grande
          velocity: 80.0,                     // Velocidad bien visible
          pauseAfterRound: Duration.zero,     // ← SIN PAUSAS
          startPadding: 0.0,
          accelerationDuration: Duration.zero,
          decelerationDuration: Duration.zero,
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}


// ✅ VERSIÓN ALTERNATIVA ULTRA SIMPLE Y CONFIABLE
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Repetir para siempre
    _controller.repeat();

    print('✅ TV News Marquee: Animación iniciada');
  }

  @override
  void didUpdateWidget(TVNewsMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.duration != widget.duration) {
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
              // Crear texto con espaciado y repetición para efecto continuo
              final separator = '  •  '; // Separador visual
              final repeatedText = '${widget.text}$separator${widget.text}$separator${widget.text}$separator';

              // Medir una unidad del texto (texto + separador)
              final textPainter = TextPainter(
                text: TextSpan(text: '${widget.text}$separator', style: widget.style),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              );
              textPainter.layout();
              final unitWidth = textPainter.size.width;

              // Calcular desplazamiento cíclico
              final containerWidth = MediaQuery.of(context).size.width;
              final offset = (_controller.value * unitWidth) % unitWidth;

              return Transform.translate(
                offset: Offset(containerWidth - offset, 0),
                child: Text(
                  repeatedText,
                  style: widget.style,
                  maxLines: 1,
                  softWrap: false,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ✅ VERSIÓN SÚPER SIMPLE GARANTIZADA
class InfiniteMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const InfiniteMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 12),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<InfiniteMarquee> createState() => _InfiniteMarqueeState();
}

class _InfiniteMarqueeState extends State<InfiniteMarquee>
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
  void didUpdateWidget(InfiniteMarquee oldWidget) {
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
              return FractionalTranslation(
                translation: Offset(2.0 - _controller.value * 4.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
                    const SizedBox(width: 100),
                    Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
                    const SizedBox(width: 100),
                    Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}