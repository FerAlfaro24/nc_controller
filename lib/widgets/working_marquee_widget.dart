import 'package:flutter/material.dart';

class WorkingMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const WorkingMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 8),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<WorkingMarquee> createState() => _WorkingMarqueeState();
}

class _WorkingMarqueeState extends State<WorkingMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    print('🎬 Marquee: Inicializando...');

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

    // Listener para reiniciar
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print('🔄 Marquee: Reiniciando animación...');
        _controller.reset();
        _controller.forward();
      }
    });

    // Iniciar la animación inmediatamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🚀 Marquee: Iniciando animación');
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(WorkingMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      print('📝 Marquee: Texto cambió a: "${widget.text}"');
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    print('🗑️ Marquee: Disposing...');
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
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(1.0 - _animation.value * 2.0, 0.0),
                  child: Text(
                    widget.text,
                    style: widget.style,
                    maxLines: 1,
                    softWrap: false,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Versión ultra simple que GARANTIZA que funciona
class UltraSimpleMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const UltraSimpleMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 6),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<UltraSimpleMarquee> createState() => _UltraSimpleMarqueeState();
}

class _UltraSimpleMarqueeState extends State<UltraSimpleMarquee>
    with TickerProviderStateMixin {
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

    print('✅ UltraSimple Marquee: Animación iniciada');
  }

  @override
  void didUpdateWidget(UltraSimpleMarquee oldWidget) {
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
                  begin: const Offset(1.0, 0.0),
                  end: const Offset(-1.0, 0.0),
                ).animate(_controller),
                child: Text(
                  widget.text,
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

// Versión con ScrollController (más robusta)
class ScrollMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const ScrollMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 8),
    this.height = 40,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<ScrollMarquee> createState() => _ScrollMarqueeState();
}

class _ScrollMarqueeState extends State<ScrollMarquee> {
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  @override
  void didUpdateWidget(ScrollMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startScrolling();
    }
  }

  void _startScrolling() async {
    if (!mounted || _isScrolling) return;

    _isScrolling = true;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    while (mounted) {
      // Scroll hacia la derecha (para simular texto entrando por la izquierda)
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: widget.duration,
        curve: Curves.linear,
      );

      if (!mounted) break;

      // Reset inmediato
      _scrollController.jumpTo(0);

      await Future.delayed(const Duration(milliseconds: 100));
    }

    _isScrolling = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              '${widget.text}     ${widget.text}     ', // Repetir texto para continuidad
              style: widget.style,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}