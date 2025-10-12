import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_helper.dart';

/// Bottom Navigation Bar iOS natif pour l'application Pièces d'Occasion
///
/// Features:
/// - CupertinoTabBar natif iOS
/// - Hauteur iOS standard (50px + safe area)
/// - Icônes Cupertino
/// - Haptic feedback sur sélection
/// - Badge pour messages non lus
/// - Différents items pour particulier vs vendeur
/// - Border top subtile iOS
/// - Animations natives iOS
///
/// Exemple d'utilisation:
/// ```dart
/// IOSBottomNavigation(
///   currentIndex: 0,
///   onTap: (index) => _handleNavigation(index),
///   unreadMessagesCount: 3,
///   isSellerMode: false,
/// )
/// ```
class IOSBottomNavigation extends StatelessWidget {
  /// Index de l'onglet actuellement sélectionné
  final int currentIndex;

  /// Callback appelé lors du tap sur un onglet
  final Function(int) onTap;

  /// Nombre de messages non lus (affiche un badge rouge)
  final int? unreadMessagesCount;

  /// Mode vendeur (affiche des items différents)
  final bool isSellerMode;

  /// Couleur de fond (par défaut: blanc)
  final Color? backgroundColor;

  /// Couleur des items actifs
  final Color? activeColor;

  /// Couleur des items inactifs
  final Color? inactiveColor;

  const IOSBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadMessagesCount,
    this.isSellerMode = false,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.gray.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: CupertinoTabBar(
            backgroundColor: Colors.transparent,
            activeColor: activeColor ?? AppTheme.primaryBlue,
            inactiveColor: inactiveColor ?? AppTheme.gray,
            iconSize: 28,
            currentIndex: currentIndex,
            onTap: (index) {
              // Haptic feedback sur sélection
              HapticHelper.selection();
              onTap(index);
            },
            items: isSellerMode ? _buildSellerItems() : _buildBuyerItems(),
          ),
        ),
      ),
    );
  }

  /// Items de navigation pour le mode particulier/acheteur
  List<BottomNavigationBarItem> _buildBuyerItems() {
    return [
      // Recherche
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.search),
        activeIcon: Icon(CupertinoIcons.search_circle_fill),
        label: 'Recherche',
      ),

      // Favoris
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.heart),
        activeIcon: Icon(CupertinoIcons.heart_fill),
        label: 'Favoris',
      ),

      // Messages avec badge
      BottomNavigationBarItem(
        icon: _buildIconWithBadge(
          icon: CupertinoIcons.chat_bubble_2,
          badgeCount: unreadMessagesCount,
        ),
        activeIcon: _buildIconWithBadge(
          icon: CupertinoIcons.chat_bubble_2_fill,
          badgeCount: unreadMessagesCount,
        ),
        label: 'Messages',
      ),

      // Profil
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person),
        activeIcon: Icon(CupertinoIcons.person_fill),
        label: 'Profil',
      ),
    ];
  }

  /// Items de navigation pour le mode vendeur
  List<BottomNavigationBarItem> _buildSellerItems() {
    return [
      // Mes annonces
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.square_grid_2x2),
        activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
        label: 'Annonces',
      ),

      // Ajouter une pièce
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.add_circled),
        activeIcon: Icon(CupertinoIcons.add_circled_solid),
        label: 'Ajouter',
      ),

      // Messages avec badge
      BottomNavigationBarItem(
        icon: _buildIconWithBadge(
          icon: CupertinoIcons.chat_bubble_2,
          badgeCount: unreadMessagesCount,
        ),
        activeIcon: _buildIconWithBadge(
          icon: CupertinoIcons.chat_bubble_2_fill,
          badgeCount: unreadMessagesCount,
        ),
        label: 'Messages',
      ),

      // Statistiques
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.chart_bar),
        activeIcon: Icon(CupertinoIcons.chart_bar_fill),
        label: 'Stats',
      ),

      // Profil vendeur
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person),
        activeIcon: Icon(CupertinoIcons.person_fill),
        label: 'Profil',
      ),
    ];
  }

  /// Construit une icône avec un badge de notification
  Widget _buildIconWithBadge({
    required IconData icon,
    int? badgeCount,
  }) {
    // Si pas de badge, retourner l'icône simple
    if (badgeCount == null || badgeCount == 0) {
      return Icon(icon);
    }

    // Icône avec badge
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -8,
          top: -4,
          child: _buildBadge(badgeCount),
        ),
      ],
    );
  }

  /// Construit le badge rouge iOS pour les notifications
  Widget _buildBadge(int count) {
    // Limiter l'affichage à 99+
    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.white,
          width: 1.5,
        ),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        displayCount,
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Extension pour les routes de navigation
///
/// Utilise pour mapper les index aux routes Go Router
extension NavigationRoutes on IOSBottomNavigation {
  /// Obtient la route correspondant à l'index (mode acheteur)
  static String getBuyerRoute(int index) {
    switch (index) {
      case 0:
        return '/search';
      case 1:
        return '/favorites';
      case 2:
        return '/messages';
      case 3:
        return '/profile';
      default:
        return '/search';
    }
  }

  /// Obtient la route correspondant à l'index (mode vendeur)
  static String getSellerRoute(int index) {
    switch (index) {
      case 0:
        return '/seller/listings';
      case 1:
        return '/seller/add';
      case 2:
        return '/messages';
      case 3:
        return '/seller/stats';
      case 4:
        return '/seller/profile';
      default:
        return '/seller/listings';
    }
  }

  /// Obtient l'index à partir de la route
  static int getIndexFromRoute(String route, {bool isSellerMode = false}) {
    if (isSellerMode) {
      if (route.startsWith('/seller/listings')) return 0;
      if (route.startsWith('/seller/add')) return 1;
      if (route.startsWith('/messages')) return 2;
      if (route.startsWith('/seller/stats')) return 3;
      if (route.startsWith('/seller/profile')) return 4;
      return 0;
    } else {
      if (route.startsWith('/search')) return 0;
      if (route.startsWith('/favorites')) return 1;
      if (route.startsWith('/messages')) return 2;
      if (route.startsWith('/profile')) return 3;
      return 0;
    }
  }
}
