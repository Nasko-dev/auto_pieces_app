import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationNavigationService {
  static NotificationNavigationService? _instance;
  static NotificationNavigationService get instance {
    _instance ??= NotificationNavigationService._();
    return _instance!;
  }

  NotificationNavigationService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Navigation globale depuis une notification
  Future<void> navigateFromNotification(
    BuildContext? context,
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final type = notificationData['type'];
      final conversationId = notificationData['conversation_group_id'] ?? notificationData['conversation_id'];

      debugPrint('Navigation notification - Type: $type, Conversation: $conversationId');

      if (context == null || !context.mounted) {
        debugPrint('Contexte non disponible pour la navigation');
        return;
      }

      // Déterminer le type d'utilisateur actuel
      final userType = await _getCurrentUserType();

      if (!context.mounted) return;

      switch (type) {
        case 'new_message':
          await _navigateToConversation(context, conversationId, userType);
          break;
        case 'part_request_response':
          await _navigateToRequests(context, userType);
          break;
        default:
          debugPrint('Type de notification non géré: $type');
      }
    } catch (e) {
      debugPrint('Erreur lors de la navigation depuis notification: $e');
    }
  }

  /// Détermine le type d'utilisateur actuel
  Future<String?> _getCurrentUserType() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Vérifier d'abord dans la table sellers
      final seller = await _supabase
          .from('sellers')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (seller != null) {
        return 'vendeur';
      }

      // Sinon, vérifier dans la table particuliers
      final particulier = await _supabase
          .from('particuliers')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      return particulier != null ? 'particulier' : null;
    } catch (e) {
      debugPrint('Erreur lors de la détermination du type utilisateur: $e');
      return null;
    }
  }

  /// Navigation vers une conversation spécifique
  Future<void> _navigateToConversation(
    BuildContext context,
    String? conversationId,
    String? userType,
  ) async {
    if (conversationId == null) {
      debugPrint('ID de conversation manquant');
      return;
    }

    try {
      if (userType == 'vendeur') {
        // Navigation vendeur
        context.goNamed(
          'seller-conversation-detail',
          pathParameters: {'conversationId': conversationId},
        );
      } else {
        // Navigation particulier
        context.goNamed(
          'chat',
          pathParameters: {'conversationId': conversationId},
        );
      }
      debugPrint('Navigation vers conversation: $conversationId (type: $userType)');
    } catch (e) {
      debugPrint('Erreur lors de la navigation vers conversation: $e');
      // Fallback: aller vers la liste des conversations
      await _navigateToConversationsList(context, userType);
    }
  }

  /// Navigation vers la liste des conversations
  Future<void> _navigateToConversationsList(
    BuildContext context,
    String? userType,
  ) async {
    try {
      if (userType == 'vendeur') {
        context.goNamed('seller-messages');
      } else {
        context.goNamed('conversations');
      }
      debugPrint('Navigation vers liste conversations (type: $userType)');
    } catch (e) {
      debugPrint('Erreur lors de la navigation vers liste conversations: $e');
    }
  }

  /// Navigation vers les demandes
  Future<void> _navigateToRequests(
    BuildContext context,
    String? userType,
  ) async {
    try {
      if (userType == 'vendeur') {
        // Pour les vendeurs, aller vers les notifications
        context.goNamed('seller-notifications');
      } else {
        // Pour les particuliers, aller vers les demandes
        context.goNamed('requests');
      }
      debugPrint('Navigation vers demandes/notifications (type: $userType)');
    } catch (e) {
      debugPrint('Erreur lors de la navigation vers demandes: $e');
    }
  }

  /// Navigation depuis les notifications sans contexte
  /// Cette méthode utilise GoRouter pour naviguer directement
  Future<void> navigateFromNotificationGlobal(
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final type = notificationData['type'];
      final conversationId = notificationData['conversation_group_id'] ?? notificationData['conversation_id'];

      debugPrint('Navigation notification global - Type: $type, Conversation: $conversationId');

      // Déterminer le type d'utilisateur actuel
      final userType = await _getCurrentUserType();

      switch (type) {
        case 'new_message':
          await _navigateToConversationGlobal(conversationId, userType);
          break;
        case 'part_request_response':
          await _navigateToRequestsGlobal(userType);
          break;
        default:
          debugPrint('Type de notification non géré: $type');
      }
    } catch (e) {
      debugPrint('Erreur lors de la navigation depuis notification: $e');
    }
  }

  /// Navigation globale vers une conversation spécifique
  Future<void> _navigateToConversationGlobal(
    String? conversationId,
    String? userType,
  ) async {
    if (conversationId == null) {
      debugPrint('ID de conversation manquant');
      return;
    }

    try {
      if (userType == 'vendeur') {
        // Navigation vendeur
        _globalGoRouter?.goNamed(
          'seller-conversation-detail',
          pathParameters: {'conversationId': conversationId},
        );
      } else {
        // Navigation particulier
        _globalGoRouter?.goNamed(
          'chat',
          pathParameters: {'conversationId': conversationId},
        );
      }
      debugPrint('Navigation globale vers conversation: $conversationId (type: $userType)');
    } catch (e) {
      debugPrint('Erreur lors de la navigation globale vers conversation: $e');
    }
  }

  /// Navigation globale vers les demandes
  Future<void> _navigateToRequestsGlobal(String? userType) async {
    try {
      if (userType == 'vendeur') {
        _globalGoRouter?.goNamed('seller-notifications');
      } else {
        _globalGoRouter?.goNamed('requests');
      }
      debugPrint('Navigation globale vers demandes/notifications (type: $userType)');
    } catch (e) {
      debugPrint('Erreur lors de la navigation globale vers demandes: $e');
    }
  }

  /// Obtenir le contexte de navigation global si disponible
  BuildContext? getGlobalContext() {
    // Cette méthode n'est plus utilisée avec l'approche globale
    return null;
  }

  // Instance globale de GoRouter
  static GoRouter? _globalGoRouter;

  /// Setter pour définir l'instance globale de GoRouter
  static void setGlobalRouter(GoRouter router) {
    _globalGoRouter = router;
  }
}