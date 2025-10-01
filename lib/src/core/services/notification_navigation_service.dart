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

      if (context == null || !context.mounted) {
        return;
      }

      // Déterminer le type d'utilisateur actuel
      final userType = await _getCurrentUserType();

      if (!context.mounted) return;

      switch (type) {
        case 'new_message':
        case 'message':
          await _navigateToConversation(context, conversationId, userType);
          break;
        case 'part_request_response':
          await _navigateToRequests(context, userType);
          break;
        default:
          // Fallback vers la liste des conversations
          await _navigateToConversationsList(context, userType);
      }
    } catch (e) {
      // Erreur silencieuse en production
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
          .eq('id', user.id)
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
      return null;
    }
  }

  /// Navigation vers une conversation spécifique
  Future<void> _navigateToConversation(
    BuildContext context,
    String? conversationId,
    String? userType,
  ) async {
    if (conversationId == null || conversationId.isEmpty) {
      await _navigateToConversationsList(context, userType);
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
    } catch (e) {
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
    } catch (e) {
      // Erreur silencieuse en production
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
    } catch (e) {
      // Erreur silencieuse en production
    }
  }

  /// Navigation depuis les notifications sans contexte
  /// Cette méthode utilise GoRouter pour naviguer directement
  Future<void> navigateFromNotificationGlobal(
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final type = notificationData['type'];
      final conversationId = notificationData['conversation_group_id'] ??
                           notificationData['conversation_id'] ??
                           notificationData['conversationId'];

      // Déterminer le type d'utilisateur actuel
      final userType = await _getCurrentUserType();

      switch (type) {
        case 'new_message':
        case 'message':
          await _navigateToConversationGlobal(conversationId, userType);
          break;
        case 'part_request_response':
          await _navigateToRequestsGlobal(userType);
          break;
        default:
          // Fallback vers la liste des conversations
          await _navigateToConversationsListGlobal(userType);
      }
    } catch (e) {
      // En cas d'erreur, aller vers l'accueil
      try {
        _globalGoRouter?.go('/home');
      } catch (_) {
        // Erreur silencieuse en production
      }
    }
  }

  /// Navigation globale vers une conversation spécifique
  Future<void> _navigateToConversationGlobal(
    String? conversationId,
    String? userType,
  ) async {
    if (conversationId == null || conversationId.isEmpty) {
      // Fallback vers la liste des conversations
      await _navigateToConversationsListGlobal(userType);
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
    } catch (e) {
      // Fallback vers la liste des conversations
      await _navigateToConversationsListGlobal(userType);
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
    } catch (e) {
      // Fallback vers l'accueil
      _globalGoRouter?.go('/home');
    }
  }

  /// Navigation globale vers la liste des conversations
  Future<void> _navigateToConversationsListGlobal(String? userType) async {
    try {
      if (userType == 'vendeur') {
        _globalGoRouter?.goNamed('seller-messages');
      } else {
        _globalGoRouter?.goNamed('conversations');
      }
    } catch (e) {
      // Fallback vers l'accueil
      _globalGoRouter?.go('/home');
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