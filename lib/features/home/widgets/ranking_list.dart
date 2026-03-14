import 'package:flutter/material.dart';

class RankingList extends StatelessWidget {
  const RankingList({super.key});

  @override
  Widget build(BuildContext context) {
    final rankings = [
      _RankingData(position: 1, name: 'Maria Santos', lost: 5.2, isCurrentUser: false),
      _RankingData(position: 2, name: 'Pedro Lima', lost: 4.8, isCurrentUser: false),
      _RankingData(position: 3, name: 'João Silva', lost: 3.5, isCurrentUser: true),
      _RankingData(position: 4, name: 'Ana Costa', lost: 3.2, isCurrentUser: false),
      _RankingData(position: 5, name: 'Carlos Souza', lost: 2.9, isCurrentUser: false),
      _RankingData(position: 6, name: 'Lucia Ferreira', lost: 2.5, isCurrentUser: false),
      _RankingData(position: 7, name: 'Bruno Oliveira', lost: 2.1, isCurrentUser: false),
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rankings.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 72, color: Colors.black26),
        itemBuilder: (context, index) {
          final ranking = rankings[index];
          return _RankingTile(data: ranking);
        },
      ),
    );
  }
}

class _RankingData {
  final int position;
  final String name;
  final double lost;
  final bool isCurrentUser;

  _RankingData({
    required this.position,
    required this.name,
    required this.lost,
    required this.isCurrentUser,
  });
}

class _RankingTile extends StatelessWidget {
  final _RankingData data;

  const _RankingTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildPositionBadge(context),
      title: Row(
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                data.name,
                style: TextStyle(
                  fontWeight: data.isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (data.isCurrentUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Você',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '-${data.lost} kg',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPositionBadge(BuildContext context) {
    Color badgeColor;
    IconData? icon;

    switch (data.position) {
      case 1:
        badgeColor = Colors.amber;
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey.shade400;
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = Colors.brown.shade300;
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = Colors.grey;
        icon = null;
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: CircleAvatar(
        backgroundColor: badgeColor.withValues(alpha: 0.2),
        child: icon != null
            ? Icon(icon, color: badgeColor, size: 20)
            : Text(
                '${data.position}',
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
