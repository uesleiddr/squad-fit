import 'package:flutter/material.dart';
import 'sf_loading.dart';
import 'sf_card.dart';

/// Skeleton layout para a Home Screen
///
/// Inclui:
/// - Header com avatar e saudação
/// - Banner de streak
/// - Hero card (ring de calorias)
/// - Stats row (3 cards)
/// - Section header
/// - Ranking rows (3 itens)
class SFSkeletonHome extends StatelessWidget {
  const SFSkeletonHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          // Header: avatar + greeting + notification
          Row(
            children: [
              const SFSkeleton(width: 48, height: 48, borderRadius: 999),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SFSkeleton(width: 80, height: 10),
                    SizedBox(height: 6),
                    SFSkeleton(width: 140, height: 18),
                  ],
                ),
              ),
              const SFSkeleton(width: 40, height: 40, borderRadius: 12),
            ],
          ),

          const SizedBox(height: 16),

          // Streak banner
          const SFSkeleton(height: 70, borderRadius: 16),

          const SizedBox(height: 14),

          // Hero card (nutrition ring)
          SFCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const SFSkeleton(width: 130, height: 130, borderRadius: 999),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SFSkeleton(width: 70, height: 10),
                      SizedBox(height: 6),
                      SFSkeleton(width: 100, height: 22),
                      SizedBox(height: 14),
                      SFSkeleton(width: 70, height: 10),
                      SizedBox(height: 6),
                      SFSkeleton(width: 90, height: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Stats row (3 cards)
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i > 0 ? 5 : 0,
                    right: i < 2 ? 5 : 0,
                  ),
                  child: SFCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SFSkeleton(width: 50, height: 9),
                        SizedBox(height: 8),
                        SFSkeleton(width: 70, height: 22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SFSkeleton(width: 100, height: 16),
              SFSkeleton(width: 60, height: 10),
            ],
          ),

          const SizedBox(height: 12),

          // Ranking rows
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SkeletonRankingRow(delay: i * 120),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonRankingRow extends StatefulWidget {
  final int delay;

  const _SkeletonRankingRow({this.delay = 0});

  @override
  State<_SkeletonRankingRow> createState() => _SkeletonRankingRowState();
}

class _SkeletonRankingRowState extends State<_SkeletonRankingRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: SFCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const SFSkeleton(width: 32, height: 32, borderRadius: 10),
                const SizedBox(width: 10),
                const SFSkeleton(width: 40, height: 40, borderRadius: 999),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SFSkeleton(width: 100, height: 12),
                      SizedBox(height: 6),
                      SFSkeleton(width: 60, height: 9),
                    ],
                  ),
                ),
                const SFSkeleton(width: 50, height: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton layout para a Profile Screen
///
/// Inclui:
/// - Avatar central
/// - Nome e membro desde
/// - Chips row
/// - Stats grid 2x2
/// - Chart placeholder
class SFSkeletonProfile extends StatelessWidget {
  const SFSkeletonProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          // Avatar + nome
          Column(
            children: const [
              SFSkeleton(width: 100, height: 100, borderRadius: 999),
              SizedBox(height: 16),
              SFSkeleton(width: 140, height: 22),
              SizedBox(height: 8),
              SFSkeleton(width: 90, height: 10),
            ],
          ),

          const SizedBox(height: 16),

          // Chips row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SFSkeleton(width: 72, height: 26, borderRadius: 999),
              SizedBox(width: 6),
              SFSkeleton(width: 72, height: 26, borderRadius: 999),
              SizedBox(width: 6),
              SFSkeleton(width: 72, height: 26, borderRadius: 999),
            ],
          ),

          const SizedBox(height: 20),

          // Stats card
          SFCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SFSkeleton(width: 80, height: 12),
                    SFSkeleton(width: 60, height: 12),
                  ],
                ),
                const SizedBox(height: 10),
                const SFSkeleton(height: 10, borderRadius: 999),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Stats grid 2x2
          Row(
            children: [
              Expanded(
                child: SFCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SFSkeleton(width: 60, height: 10),
                      SizedBox(height: 8),
                      SFSkeleton(width: 80, height: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SFCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SFSkeleton(width: 60, height: 10),
                      SizedBox(height: 8),
                      SFSkeleton(width: 80, height: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: SFCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SFSkeleton(width: 60, height: 10),
                      SizedBox(height: 8),
                      SFSkeleton(width: 80, height: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SFCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SFSkeleton(width: 60, height: 10),
                      SizedBox(height: 8),
                      SFSkeleton(width: 80, height: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Chart placeholder
          SFCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SFSkeleton(width: 100, height: 14),
                const SizedBox(height: 14),
                SizedBox(
                  height: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      12,
                      (i) {
                        final heights = [
                          38,
                          54,
                          32,
                          48,
                          70,
                          58,
                          82,
                          60,
                          92,
                          72,
                          88,
                          100
                        ];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: SFSkeleton(
                              height: heights[i].toDouble() * 0.9,
                              borderRadius: 4,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton genérico para cards
class SFSkeletonCard extends StatelessWidget {
  final int rows;
  final bool showIcon;

  const SFSkeletonCard({
    super.key,
    this.rows = 2,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return SFCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (showIcon) ...[
            const SFSkeleton(width: 44, height: 44, borderRadius: 12),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                rows,
                (i) => Padding(
                  padding: EdgeInsets.only(top: i > 0 ? 8 : 0),
                  child: SFSkeleton(
                    width: i == 0 ? 120 : 80,
                    height: i == 0 ? 14 : 10,
                  ),
                ),
              ),
            ),
          ),
          const SFSkeleton(width: 50, height: 18),
        ],
      ),
    );
  }
}

/// Skeleton para lista de itens
class SFSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const SFSkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 72,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i < itemCount - 1 ? spacing : 0),
          child: const SFSkeletonCard(),
        ),
      ),
    );
  }
}
