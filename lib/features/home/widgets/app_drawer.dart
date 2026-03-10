import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/services/auth_service.dart';
import '../../weight/screens/add_weight_screen.dart';
import '../../weight/screens/weight_history_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onClose;

  const AppDrawer({super.key, this.onClose});

  void _handleTap(BuildContext context) {
    if (onClose != null) {
      onClose!();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleSignOut() async {
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Usuario';
    final userEmail = user?.email ?? '';
    final userPhoto = user?.photoURL;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: userPhoto != null ? NetworkImage(userPhoto) : null,
                    child: userPhoto == null
                        ? const Icon(Icons.person, size: 32, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    userEmail,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              title: 'Início',
              selected: true,
              onTap: () => _handleTap(context),
            ),
            _DrawerItem(
              icon: Icons.monitor_weight_outlined,
              selectedIcon: Icons.monitor_weight,
              title: 'Registrar Peso',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddWeightScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.emoji_events_outlined,
              selectedIcon: Icons.emoji_events,
              title: 'Competições',
              onTap: () => _handleTap(context),
            ),
            _DrawerItem(
              icon: Icons.history_outlined,
              selectedIcon: Icons.history,
              title: 'Histórico de Peso',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeightHistoryScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.leaderboard_outlined,
              selectedIcon: Icons.leaderboard,
              title: 'Ranking',
              onTap: () => _handleTap(context),
            ),
            const Divider(indent: 16, endIndent: 16),
            _DrawerItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              title: 'Configurações',
              onTap: () => _handleTap(context),
            ),
            _DrawerItem(
              icon: Icons.logout_outlined,
              selectedIcon: Icons.logout,
              title: 'Sair',
              onTap: () => _handleSignOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
