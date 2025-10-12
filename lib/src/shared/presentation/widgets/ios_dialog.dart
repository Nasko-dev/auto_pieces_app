import 'package:flutter/cupertino.dart';
import '../../../core/utils/haptic_helper.dart';

/// Extension pour afficher des dialogs iOS natifs authentiques sur BuildContext
///
/// Utilise UNIQUEMENT des composants Cupertino natifs pour une expérience 100% Apple.
/// Chaque interaction inclut un retour haptique approprié selon les guidelines iOS.
///
/// Styles conformes aux Apple Human Interface Guidelines:
/// - BorderRadius: 14pt (pas 20pt)
/// - Animation: Fade simple (pas d'elasticOut)
/// - Pas d'icônes ni de décorations custom
/// - Texte centré et épuré
/// - Boutons horizontaux (2 actions) ou verticaux (3+ actions)
extension CupertinoDialogExtension on BuildContext {

  // ============================================================================
  // DIALOG DE CONFIRMATION (2 boutons horizontaux)
  // ============================================================================

  /// Affiche un dialog de confirmation iOS natif avec 2 boutons horizontaux
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// final result = await context.showConfirmationDialog(
  ///   title: 'Déconnexion',
  ///   message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
  ///   confirmText: 'Déconnecter',
  ///   cancelText: 'Annuler',
  ///   isDestructive: false,
  /// );
  /// ```
  ///
  /// Paramètres:
  /// - [title]: Titre du dialog (requis)
  /// - [message]: Message explicatif (requis)
  /// - [confirmText]: Texte du bouton de confirmation (défaut: 'Confirmer')
  /// - [cancelText]: Texte du bouton d'annulation (défaut: 'Annuler')
  /// - [isDestructive]: Si true, le bouton confirm sera rouge (défaut: false)
  ///
  /// Retourne:
  /// - `true` si l'utilisateur confirme
  /// - `false` si l'utilisateur annule
  /// - `null` si le dialog est fermé en tapant à l'extérieur
  Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    bool isDestructive = false,
  }) {
    HapticHelper.medium();

    return showCupertinoDialog<bool>(
      context: this,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          // Bouton Annuler (toujours à gauche dans les guidelines Apple)
          CupertinoDialogAction(
            onPressed: () {
              HapticHelper.light();
              Navigator.of(context).pop(false);
            },
            child: Text(cancelText),
          ),
          // Bouton Confirmer (à droite, peut être destructive = rouge)
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () {
              if (isDestructive) {
                HapticHelper.heavy();
              } else {
                HapticHelper.medium();
              }
              Navigator.of(context).pop(true);
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // DIALOG D'ALERTE (1 seul bouton)
  // ============================================================================

  /// Affiche un dialog d'alerte simple iOS avec un seul bouton
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// await context.showAlertDialog(
  ///   title: 'Succès',
  ///   message: 'Votre compte a été créé avec succès.',
  ///   buttonText: 'OK',
  /// );
  /// ```
  ///
  /// Paramètres:
  /// - [title]: Titre du dialog (requis)
  /// - [message]: Message informatif (requis)
  /// - [buttonText]: Texte du bouton (défaut: 'OK')
  ///
  /// Usage typique:
  /// - Messages d'information
  /// - Notifications simples
  /// - Confirmations sans action critique
  Future<void> showAlertDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    HapticHelper.medium();

    return showCupertinoDialog(
      context: this,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              HapticHelper.light();
              Navigator.of(context).pop();
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // DIALOG D'ERREUR (style rouge destructive)
  // ============================================================================

  /// Affiche un dialog d'erreur avec style destructive (rouge)
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// await context.showErrorDialog(
  ///   title: 'Erreur',
  ///   message: 'Impossible de se connecter au serveur.',
  ///   buttonText: 'Compris',
  /// );
  /// ```
  ///
  /// Paramètres:
  /// - [title]: Titre de l'erreur (requis)
  /// - [message]: Description de l'erreur (requis)
  /// - [buttonText]: Texte du bouton (défaut: 'OK')
  ///
  /// Note: Inclut un retour haptique fort pour alerter l'utilisateur
  Future<void> showErrorDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    HapticHelper.heavy(); // Vibration forte pour les erreurs

    return showCupertinoDialog(
      context: this,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              HapticHelper.light();
              Navigator.of(context).pop();
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // DIALOG D'INFORMATION (style par défaut)
  // ============================================================================

  /// Affiche un dialog d'information avec un seul bouton (style par défaut)
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// await context.showInfoDialog(
  ///   title: 'Information',
  ///   message: 'Une nouvelle mise à jour est disponible.',
  ///   buttonText: 'OK',
  /// );
  /// ```
  ///
  /// Paramètres:
  /// - [title]: Titre de l'information (requis)
  /// - [message]: Message informatif (requis)
  /// - [buttonText]: Texte du bouton (défaut: 'OK')
  ///
  /// Note: Identique à showAlertDialog mais plus explicite dans le nom
  Future<void> showInfoDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showAlertDialog(
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  // ============================================================================
  // DIALOG D'AVERTISSEMENT
  // ============================================================================

  /// Affiche un dialog d'avertissement avec possibilité d'annuler
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// final result = await context.showWarningDialog(
  ///   title: 'Attention',
  ///   message: 'Cette action peut prendre plusieurs minutes.',
  ///   confirmText: 'Continuer',
  ///   cancelText: 'Annuler',
  /// );
  /// ```
  ///
  /// Paramètres:
  /// - [title]: Titre de l'avertissement (requis)
  /// - [message]: Message d'avertissement (requis)
  /// - [confirmText]: Texte du bouton de confirmation (défaut: 'Continuer')
  /// - [cancelText]: Texte du bouton d'annulation (défaut: 'Annuler')
  ///
  /// Note: Similaire à showConfirmationDialog mais avec un nom plus explicite
  Future<bool?> showWarningDialog({
    required String title,
    required String message,
    String confirmText = 'Continuer',
    String cancelText = 'Annuler',
  }) {
    return showConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: false,
    );
  }

  // ============================================================================
  // DIALOG D'ACTION DESTRUCTIVE (suppression, danger)
  // ============================================================================

  /// Affiche un dialog pour une action destructive et irréversible
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// final result = await context.showDestructiveDialog(
  ///   title: 'Supprimer le compte',
  ///   message: 'Cette action est irréversible. Toutes vos données seront perdues.',
  ///   destructiveText: 'Supprimer',
  ///   cancelText: 'Annuler',
  /// );
  /// if (result == true) {
  ///   // L'utilisateur a confirmé la suppression
  /// }
  /// ```
  ///
  /// Paramètres:
  /// - [title]: Titre du dialog (requis)
  /// - [message]: Message d'avertissement (requis)
  /// - [destructiveText]: Texte du bouton destructif (défaut: 'Supprimer')
  /// - [cancelText]: Texte du bouton d'annulation (défaut: 'Annuler')
  ///
  /// Retourne:
  /// - `true` si l'utilisateur confirme l'action destructive
  /// - `false` si l'utilisateur annule
  /// - `null` si le dialog est fermé
  ///
  /// Note: Inclut un retour haptique très fort pour l'action destructive
  Future<bool?> showDestructiveDialog({
    required String title,
    required String message,
    String destructiveText = 'Supprimer',
    String cancelText = 'Annuler',
  }) {
    HapticHelper.heavy();

    return showCupertinoDialog<bool>(
      context: this,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              HapticHelper.light();
              Navigator.of(context).pop(false);
            },
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              HapticHelper.heavy();
              Navigator.of(context).pop(true);
            },
            child: Text(destructiveText),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ACTION SHEET (liste d'actions depuis le bas - iOS native)
  // ============================================================================

  /// Affiche une action sheet iOS native qui remonte depuis le bas de l'écran
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// final result = await context.showActionSheet<String>(
  ///   title: 'Options du compte',
  ///   message: 'Choisissez une action',
  ///   actions: [
  ///     ActionSheetAction(
  ///       value: 'edit',
  ///       child: Text('Modifier le profil'),
  ///     ),
  ///     ActionSheetAction(
  ///       value: 'logout',
  ///       child: Text('Déconnexion'),
  ///     ),
  ///     ActionSheetAction(
  ///       value: 'delete',
  ///       child: Text('Supprimer le compte'),
  ///       isDestructive: true,
  ///     ),
  ///   ],
  ///   cancelText: 'Annuler',
  /// );
  ///
  /// if (result == 'delete') {
  ///   // Action de suppression
  /// }
  /// ```
  ///
  /// Paramètres:
  /// - [title]: Titre de l'action sheet (optionnel)
  /// - [message]: Message explicatif (optionnel)
  /// - [actions]: Liste des actions disponibles (requis)
  /// - [cancelText]: Texte du bouton annuler (défaut: 'Annuler')
  ///
  /// Type générique T: Type de valeur retournée par chaque action
  ///
  /// Retourne:
  /// - La valeur de l'action sélectionnée (type T)
  /// - `null` si l'utilisateur annule
  Future<T?> showActionSheet<T>({
    String? title,
    String? message,
    required List<ActionSheetAction<T>> actions,
    String cancelText = 'Annuler',
  }) {
    HapticHelper.light();

    return showCupertinoModalPopup<T>(
      context: this,
      builder: (context) => CupertinoActionSheet(
        title: title != null ? Text(title) : null,
        message: message != null ? Text(message) : null,
        actions: actions.map((action) {
          return CupertinoActionSheetAction(
            isDestructiveAction: action.isDestructive,
            onPressed: () {
              if (action.isDestructive) {
                HapticHelper.heavy();
              } else {
                HapticHelper.medium();
              }
              Navigator.of(context).pop(action.value);
            },
            child: action.child,
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            HapticHelper.light();
            Navigator.of(context).pop();
          },
          child: Text(cancelText),
        ),
      ),
    );
  }

  // ============================================================================
  // DIALOG AVEC 3+ BOUTONS (boutons empilés verticalement)
  // ============================================================================

  /// Affiche un dialog avec plusieurs boutons empilés verticalement
  ///
  /// Selon les guidelines Apple, quand il y a 3 boutons ou plus,
  /// ils doivent être empilés verticalement au lieu d'horizontalement.
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// final result = await context.showMultiActionDialog(
  ///   title: 'Enregistrer les modifications',
  ///   message: 'Voulez-vous enregistrer vos modifications avant de quitter ?',
  ///   actions: [
  ///     DialogAction(
  ///       value: 'save',
  ///       text: 'Enregistrer',
  ///       isDefault: true,
  ///     ),
  ///     DialogAction(
  ///       value: 'discard',
  ///       text: 'Ne pas enregistrer',
  ///       isDestructive: true,
  ///     ),
  ///     DialogAction(
  ///       value: 'cancel',
  ///       text: 'Annuler',
  ///     ),
  ///   ],
  /// );
  /// ```
  ///
  /// Paramètres:
  /// - [title]: Titre du dialog (requis)
  /// - [message]: Message explicatif (requis)
  /// - [actions]: Liste des actions (min 3 actions recommandé)
  ///
  /// Retourne:
  /// - La valeur de l'action sélectionnée (type T)
  /// - `null` si le dialog est fermé
  Future<T?> showMultiActionDialog<T>({
    required String title,
    required String message,
    required List<DialogAction<T>> actions,
  }) {
    HapticHelper.medium();

    return showCupertinoDialog<T>(
      context: this,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: actions.map((action) {
          return CupertinoDialogAction(
            isDefaultAction: action.isDefault,
            isDestructiveAction: action.isDestructive,
            onPressed: () {
              if (action.isDestructive) {
                HapticHelper.heavy();
              } else if (action.isDefault) {
                HapticHelper.medium();
              } else {
                HapticHelper.light();
              }
              Navigator.of(context).pop(action.value);
            },
            child: Text(action.text),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================================
// CLASSE HELPER POUR ACTION SHEET
// ============================================================================

/// Représente une action dans une CupertinoActionSheet
///
/// Paramètres:
/// - [value]: Valeur retournée si cette action est sélectionnée
/// - [child]: Widget à afficher (généralement un Text)
/// - [isDestructive]: Si true, affiche en rouge (actions dangereuses)
///
/// Exemple:
/// ```dart
/// ActionSheetAction<String>(
///   value: 'delete',
///   child: Text('Supprimer'),
///   isDestructive: true,
/// )
/// ```
class ActionSheetAction<T> {
  /// Valeur retournée lors de la sélection
  final T value;

  /// Widget à afficher pour cette action
  final Widget child;

  /// Si true, l'action sera affichée en rouge (style destructif)
  final bool isDestructive;

  const ActionSheetAction({
    required this.value,
    required this.child,
    this.isDestructive = false,
  });
}

// ============================================================================
// CLASSE HELPER POUR DIALOG MULTI-ACTIONS
// ============================================================================

/// Représente une action dans un CupertinoAlertDialog multi-actions
///
/// Paramètres:
/// - [value]: Valeur retournée si cette action est sélectionnée
/// - [text]: Texte du bouton
/// - [isDefault]: Si true, affiche en gras (action recommandée)
/// - [isDestructive]: Si true, affiche en rouge (action dangereuse)
///
/// Exemple:
/// ```dart
/// DialogAction<String>(
///   value: 'save',
///   text: 'Enregistrer',
///   isDefault: true,
/// )
/// ```
class DialogAction<T> {
  /// Valeur retournée lors de la sélection
  final T value;

  /// Texte du bouton
  final String text;

  /// Si true, le bouton sera en gras (action par défaut recommandée)
  final bool isDefault;

  /// Si true, le bouton sera en rouge (action destructive/dangereuse)
  final bool isDestructive;

  const DialogAction({
    required this.value,
    required this.text,
    this.isDefault = false,
    this.isDestructive = false,
  });
}
