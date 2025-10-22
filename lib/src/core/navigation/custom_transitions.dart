import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Configuration des priorités des pages pour déterminer la direction des transitions
/// Plus le nombre est élevé, plus la page est "profonde" dans la navigation
class PagePriorities {
  static const Map<String, int> particulier = {
    '/home': 0,
    '/requests': 1,
    '/conversations': 2,
    '/messages-clients': 2, // Alias pour conversations
    '/become-seller': 3,
    '/profile': 4,
    '/settings': 5,
    '/help': 6,
  };

  static const Map<String, int> vendeur = {
    '/seller/home': 0,
    '/seller/add': 1,
    '/seller/create-ad': 1,
    '/seller/create-request': 1,
    '/seller/ads': 2,
    '/seller/messages': 3,
    '/seller/profile': 4,
    '/seller/settings': 5,
    '/seller/help': 6,
    '/seller/notifications': 7,
  };

  /// Détermine la priorité d'une route
  static int getPagePriority(String route) {
    // Nettoyer la route pour enlever les paramètres
    final cleanRoute = route.split('?').first;
    final pathSegments = cleanRoute.split('/');

    // Gérer les routes imbriquées (ex: /conversations/123 -> /conversations)
    if (pathSegments.length > 2) {
      final baseRoute = '/${pathSegments[1]}';
      if (particulier.containsKey(baseRoute)) {
        return particulier[baseRoute]!;
      }
      if (pathSegments.length > 3) {
        final sellerBaseRoute = '/${pathSegments[1]}/${pathSegments[2]}';
        if (vendeur.containsKey(sellerBaseRoute)) {
          return vendeur[sellerBaseRoute]!;
        }
      }
    }

    // Route exacte
    return particulier[cleanRoute] ?? vendeur[cleanRoute] ?? 0;
  }
}

/// Crée une transition de type slide avec direction intelligente
///
/// La direction est déterminée automatiquement selon la priorité des pages :
/// - Si nouvelle page > ancienne : slide de droite à gauche (avancer)
/// - Si nouvelle page < ancienne : slide de gauche à droite (reculer)
Page<T> slideTransitionPage<T extends Object?>({
  required Widget child,
  required GoRouterState state,
  String? previousLocation,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Déterminer la direction de la transition
      SlideDirection direction = _getSlideDirection(
        state.matchedLocation,
        previousLocation,
      );

      // Configuration des offsets selon la direction
      Offset beginOffset;
      Offset endOffset = Offset.zero;

      switch (direction) {
        case SlideDirection.leftToRight:
          beginOffset = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.rightToLeft:
          beginOffset = const Offset(1.0, 0.0);
          break;
      }

      // Animation principale (entrée)
      final slideAnimation = Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut, // Courbe iOS native
      ));

      // Note: Animation secondaire disponible si nécessaire
      // final secondarySlideAnimation = Tween<Offset>(...).animate(...);

      // Animation de fade pour un rendu plus lisse
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 1.0),
      ));

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

enum SlideDirection {
  leftToRight, // Retour/navigation arrière
  rightToLeft, // Avancer/navigation avant
}

/// Détermine la direction du slide selon la priorité des pages
SlideDirection _getSlideDirection(
    String currentLocation, String? previousLocation) {
  if (previousLocation == null) {
    return SlideDirection.rightToLeft; // Par défaut, avancer
  }

  final currentPriority = PagePriorities.getPagePriority(currentLocation);
  final previousPriority = PagePriorities.getPagePriority(previousLocation);

  // Si la nouvelle page a une priorité plus élevée -> avancer (slide droite à gauche)
  // Si la nouvelle page a une priorité plus faible -> reculer (slide gauche à droite)
  return currentPriority > previousPriority
      ? SlideDirection.rightToLeft
      : SlideDirection.leftToRight;
}

// Extension retirée pour éviter les conflits de nommage
// Utiliser directement la fonction slideTransitionPage() principale
