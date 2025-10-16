import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/presentation/controllers/seller_auth_controller.dart';
import '../../../core/services/notification_service.dart';
import 'ios_dialog.dart';

class SellerMenu extends ConsumerWidget {
  const SellerMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      key: const Key(
          'seller_menu_popup'), // ✅ FIX: Clé unique pour éviter les erreurs de layout
      icon: const Icon(
        Icons.more_vert,
        color: AppTheme.darkGray,
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppTheme.white,
      onSelected: (value) {
        switch (value) {
          case 'profile':
            _showProfile(context);
            break;
          case 'settings':
            _showSettings(context);
            break;
          case 'help':
            _showHelp(context);
            break;
          case 'logout':
            _showLogoutDialog(context, ref);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: AppTheme.darkGray, size: 20),
              SizedBox(width: 12),
              Text(
                'Mon profil',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, color: AppTheme.darkGray, size: 20),
              SizedBox(width: 12),
              Text(
                'Paramètres',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'help',
          child: Row(
            children: [
              Icon(Icons.help_outline, color: AppTheme.darkGray, size: 20),
              SizedBox(width: 12),
              Text(
                'Aide',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: AppTheme.error, size: 20),
              SizedBox(width: 12),
              Text(
                'Se déconnecter',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProfile(BuildContext context) {
    context.go('/seller/profile');
  }

  void _showSettings(BuildContext context) {
    context.go('/seller/settings');
  }

  void _showHelp(BuildContext context) {
    context.go('/seller/help');
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final result = await context.showWarningDialog(
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      confirmText: 'Se déconnecter',
      cancelText: 'Annuler',
    );

    if (result == true && context.mounted) {
      _logout(context, ref);
    }
  }

  void _logout(BuildContext context, WidgetRef ref) {
    // Déconnexion via le contrôleur seller auth
    ref.read(sellerAuthControllerProvider.notifier).logout();

    // Navigation vers la page d'accueil
    if (context.mounted) {
      context.go('/welcome');
    }

    // Message de confirmation
    notificationService.success(context, 'Déconnexion réussie');
  }
}
