import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import 'sf_card.dart';

/// Loading premium do Squad Fit Design System
///
/// Exemplo de uso:
/// ```dart
/// SFLoading(
///   message: 'Carregando dados...',
/// )
/// ```
class SFLoading extends StatelessWidget {
  final String? message;
  final double size;
  final bool useCard;

  const SFLoading({
    super.key,
    this.message,
    this.size = 36,
    this.useCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ],
    );

    if (useCard) {
      return SFCard(
        padding: const EdgeInsets.all(32),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

/// Loading de tela inteira com overlay
class SFLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const SFLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: AppColors.deep.withValues(alpha: 0.8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Skeleton loading para placeholders
class SFSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SFSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SFSkeleton> createState() => _SFSkeletonState();
}

class _SFSkeletonState extends State<SFSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surface2.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
