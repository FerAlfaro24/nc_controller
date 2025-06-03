import 'package:flutter/material.dart';

class ScrollingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double? width;

  const ScrollingTextWidget({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 8),
    this.width,
  });

  @override
  State<ScrollingTextWidget> createState() => _ScrollingTextWidgetState();
}

class _ScrollingTextWidgetState extends State<ScrollingTextWidget>
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
    _animation = Tween<double>(begin: 1.0, end: -1.0).animate(
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
    return SizedBox(
      width: widget.width,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final screenWidth = widget.width ?? MediaQuery.of(context).size.width;
            return Transform.translate(
              offset: Offset(_animation.value * screenWidth, 0),
              child: Text(
                widget.text,
                style: widget.style,
                overflow: TextOverflow.visible,
                maxLines: 1,
              ),
            );
          },
        ),
      ),
    );
  }
}

// Widget más simple para textos que solo necesitan fade
class FadingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const FadingTextWidget({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<FadingTextWidget> createState() => _FadingTextWidgetState();
}

class _FadingTextWidgetState extends State<FadingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Text(
            widget.text,
            style: widget.style,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      },
    );
  }
}