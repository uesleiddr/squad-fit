import 'package:flutter/material.dart';

/// Widget que anima a entrada de itens em listas
///
/// Exemplo de uso:
/// ```dart
/// ListView.builder(
///   itemBuilder: (context, index) {
///     return SFAnimatedListItem(
///       index: index,
///       child: MyListItem(),
///     );
///   },
/// )
/// ```
class SFAnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const SFAnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<SFAnimatedListItem> createState() => _SFAnimatedListItemState();
}

class _SFAnimatedListItemState extends State<SFAnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Delay baseado no índice
    Future.delayed(widget.delay * widget.index, () {
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget para animações de scale ao pressionar
class SFScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleValue;
  final Duration duration;

  const SFScaleOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleValue = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<SFScaleOnTap> createState() => _SFScaleOnTapState();
}

class _SFScaleOnTapState extends State<SFScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget para animações de fade in na construção
class SFFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const SFFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  @override
  State<SFFadeIn> createState() => _SFFadeInState();
}

class _SFFadeInState extends State<SFFadeIn>
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

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(widget.delay, () {
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
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Widget para animar mudanças de valor numérico
class SFAnimatedNumber extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final int decimalPlaces;
  final Duration duration;

  const SFAnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.prefix,
    this.suffix,
    this.decimalPlaces = 1,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        final formattedValue = animatedValue.toStringAsFixed(decimalPlaces);
        return Text(
          '${prefix ?? ''}$formattedValue${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}
