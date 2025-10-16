import 'package:flutter/material.dart';
import '../../shared/presentation/widgets/ios_notification_fixed.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Messages prédéfinis pour l'application
  static const Map<String, Map<String, String>> _messages = {
    // Messages pour les demandes de pièces
    'part_request': {
      'created': 'Demande publiée',
      'created_subtitle': 'Les vendeurs vont recevoir votre demande',
      'deleted': 'Demande supprimée',
      'deleted_subtitle': 'La demande a été retirée',
      'error': 'Impossible de publier la demande',
      'missing_parts': 'Veuillez spécifier au moins une pièce',
    },

    // Messages pour les conversations
    'conversation': {
      'closed': 'Conversation fermée',
      'deleted': 'Conversation supprimée',
      'blocked': 'Vendeur bloqué',
      'blocked_subtitle': 'Vous ne recevrez plus de messages',
    },

    // Messages pour les messages
    'message': {
      'sent': 'Message envoyé',
      'image_sent': 'Photo envoyée',
      'image_uploading': 'Envoi de la photo...',
      'error': 'Erreur lors de l\'envoi',
    },

    // Messages pour l'authentification
    'auth': {
      'login_success': 'Connexion réussie',
      'logout': 'Déconnexion réussie',
      'error': 'Erreur de connexion',
    },

    // Messages génériques
    'generic': {
      'loading': 'Chargement...',
      'success': 'Opération réussie',
      'error': 'Une erreur est survenue',
      'network_error': 'Vérifiez votre connexion',
    },
  };

  // Afficher une notification avec le système iOS
  void show({
    required BuildContext context,
    required String message,
    String? subtitle,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    context.showIOSNotification(
      message: message,
      subtitle: subtitle,
      type: type,
      duration: duration,
      onTap: onTap,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  // Méthodes raccourcies pour les types courants
  void success(BuildContext context, String message, {String? subtitle}) {
    context.showSuccess(message, subtitle: subtitle);
  }

  void error(BuildContext context, String message, {String? subtitle}) {
    context.showError(message, subtitle: subtitle);
  }

  void warning(BuildContext context, String message, {String? subtitle}) {
    context.showWarning(message, subtitle: subtitle);
  }

  void info(BuildContext context, String message, {String? subtitle}) {
    context.showInfo(message, subtitle: subtitle);
  }

  // Notification de loading avec possibilité de la fermer
  void showLoading(BuildContext context, String message, {String? subtitle}) {
    context.showLoading(message, subtitle: subtitle);
  }

  void hideLoading() {
    // Cette méthode est maintenant obsolète car les notifications se gèrent automatiquement
  }

  // Messages prédéfinis pour les cas courants
  void showPartRequestCreated(BuildContext context) {
    success(
      context,
      _messages['part_request']!['created']!,
      subtitle: _messages['part_request']!['created_subtitle'],
    );
  }

  void showPartRequestDeleted(BuildContext context) {
    success(
      context,
      _messages['part_request']!['deleted']!,
      subtitle: _messages['part_request']!['deleted_subtitle'],
    );
  }

  void showConversationClosed(BuildContext context) {
    info(
      context,
      _messages['conversation']!['closed']!,
    );
  }

  void showConversationDeleted(BuildContext context) {
    success(
      context,
      _messages['conversation']!['deleted']!,
    );
  }

  void showSellerBlocked(BuildContext context) {
    warning(
      context,
      _messages['conversation']!['blocked']!,
      subtitle: _messages['conversation']!['blocked_subtitle'],
    );
  }

  void showImageSent(BuildContext context) {
    success(
      context,
      _messages['message']!['image_sent']!,
    );
  }

  void showImageUploading(BuildContext context) {
    showLoading(
      context,
      _messages['message']!['image_uploading']!,
    );
  }

  void showNetworkError(BuildContext context) {
    error(
      context,
      _messages['generic']!['network_error']!,
    );
  }

  // Méthode pour afficher un message avec action
  void showWithAction({
    required BuildContext context,
    required String message,
    String? subtitle,
    required String actionLabel,
    required VoidCallback onAction,
    NotificationType type = NotificationType.info,
  }) {
    show(
      context: context,
      message: message,
      subtitle: subtitle,
      type: type,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  // Exemple d'utilisation avec action "Annuler"
  void showDeletingWithUndo({
    required BuildContext context,
    required String itemName,
    required VoidCallback onUndo,
  }) {
    showWithAction(
      context: context,
      message: '$itemName supprimé',
      actionLabel: 'Annuler',
      onAction: onUndo,
      type: NotificationType.info,
    );
  }
}

// Provider global pour accéder au service partout
final notificationService = NotificationService();
