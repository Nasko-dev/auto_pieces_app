import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/particulier_auth_providers.dart';
import '../../../core/providers/user_settings_providers.dart';

class AppMenu extends ConsumerWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileStatusAsync = ref.watch(particulierProfileStatusProvider);
    final settingsStatusAsync = ref.watch(particulierSettingsStatusProvider);
    final menuStatusAsync = ref.watch(particulierMenuStatusProvider);

    return PopupMenuButton<String>(
      icon: Stack(
        children: [
          const Icon(
            Icons.more_vert,
            color: AppTheme.darkGray,
          ),
          // Point rouge d'alerte si le profil OU les paramètres nécessitent une action
          menuStatusAsync.when(
            data: (needsAction) => needsAction
                ? Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
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
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Stack(
                children: [
                  const Icon(Icons.person_outline, color: AppTheme.darkGray, size: 20),
                  // Point rouge sur l'icône profil si nécessaire
                  profileStatusAsync.when(
                    data: (needsAction) => needsAction
                        ? Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Text(
                'Mon profil',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Stack(
                children: [
                  const Icon(Icons.settings_outlined, color: AppTheme.darkGray, size: 20),
                  // Point rouge sur l'icône paramètres si nécessaire (localisation + téléphone)
                  settingsStatusAsync.when(
                    data: (needsAction) => needsAction
                        ? Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'Paramètres',
                      style: TextStyle(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Badge texte d'alerte si nécessaire (localisation + téléphone)
                    settingsStatusAsync.when(
                      data: (needsAction) => needsAction
                          ? Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Action requise',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
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
    context.go('/profile');
  }

  void _showSettings(BuildContext context) {
    context.go('/settings');
  }

  void _showHelp(BuildContext context) {
    context.go('/help');
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.error, size: 24),
            SizedBox(width: 12),
            Text(
              'Déconnexion',
              style: TextStyle(
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(
            color: AppTheme.darkGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: AppTheme.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: AppTheme.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    // Déconnexion via le contrôleur auth
    ref.read(particulierAuthControllerProvider.notifier).logout();
    
    // Navigation vers la page d'accueil
    if (context.mounted) {
      context.go('/welcome');
    }
    
    // Message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Déconnexion réussie'),
        backgroundColor: AppTheme.success,
      ),
    );
  }
}