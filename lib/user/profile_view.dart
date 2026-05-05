import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final theme = Theme.of(context);
    final profileImage = user?.profileImage;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: profileImage != null && profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                      child: profileImage == null || profileImage.isEmpty
                          ? Text(
                              (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest User',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(user?.email ?? '-', style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 12),
                          _ProfileLine(icon: Icons.phone_outlined, text: user?.phone ?? '-'),
                          const SizedBox(height: 8),
                          _ProfileLine(icon: Icons.location_on_outlined, text: user?.address ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Menu Options', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _ProfileMenuTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                  const Divider(height: 1),
                  _ProfileMenuTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
                  ),
                  const Divider(height: 1),
                  _ProfileMenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'My Orders',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
                  ),
                  const Divider(height: 1),
                  _ProfileMenuTile(
                    icon: Icons.favorite_border,
                    title: 'Wishlist',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.wishlist),
                  ),
                  const Divider(height: 1),
                  _ProfileMenuTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: theme.colorScheme.error,
                    titleColor: theme.colorScheme.error,
                    onTap: () async {
                      await context.read<AuthController>().logout();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: iconColor ?? theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}