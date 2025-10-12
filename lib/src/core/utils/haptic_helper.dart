import 'package:flutter/services.dart';

/// Classe utilitaire pour gérer tous les retours haptiques iOS
///
/// Utilise les patterns natifs iOS pour offrir une expérience tactile cohérente:
/// - Light: Interactions légères (sélection d'item, tap dans liste)
/// - Medium: Actions importantes (boutons, confirmations)
/// - Heavy: Actions critiques (validation finale, suppression)
/// - Selection: Changement de sélection (slider, picker)
/// - Vibrate: Erreurs et alertes
class HapticHelper {
  /// Impact léger - Pour les sélections et interactions subtiles
  ///
  /// Usage: Tap sur un élément de liste, selection dans un menu
  /// Intensité: ●○○
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Impact moyen - Pour les actions importantes
  ///
  /// Usage: Boutons d'action, switches, toggles
  /// Intensité: ●●○
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Impact fort - Pour les actions critiques
  ///
  /// Usage: Validation finale, suppression, actions irréversibles
  /// Intensité: ●●●
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Click de sélection - Pour les changements de sélection continus
  ///
  /// Usage: Slider, picker, scroll avec snap
  /// Intensité: ●○○ (léger et rapide)
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibration - Pour les erreurs et alertes
  ///
  /// Usage: Erreur de validation, action échouée, alerte importante
  /// Intensité: ●●● (plus long que heavy)
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  /// Feedback d'erreur - Combine vibration et pattern d'erreur
  ///
  /// Usage: Formulaire invalide, échec de connexion
  static void error() {
    HapticFeedback.vibrate();
  }

  /// Feedback de succès - Impact moyen pour les réussites
  ///
  /// Usage: Action complétée avec succès, validation réussie
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Feedback de navigation - Impact léger pour la navigation
  ///
  /// Usage: Changement de page, retour en arrière
  static void navigation() {
    HapticFeedback.lightImpact();
  }
}
