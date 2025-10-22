import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/conversations_controller.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation_group.dart';
import '../../domain/services/conversation_grouping_service.dart';
import '../../data/datasources/conversations_remote_datasource.dart';
import '../../data/repositories/conversations_repository_impl.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/get_conversation_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/manage_conversation.dart';
import '../../../../core/services/realtime_service.dart';

// DataSource Provider
final conversationsDataSourceProvider =
    Provider<ConversationsRemoteDataSource>((ref) {
  return ConversationsRemoteDataSourceImpl(
    supabaseClient: Supabase.instance.client,
  );
});

// Repository Provider
final conversationsRepositoryProvider = Provider((ref) {
  final dataSource = ref.read(conversationsDataSourceProvider);
  return ConversationsRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases Providers
final getConversationsUseCaseProvider = Provider((ref) {
  final repository = ref.read(conversationsRepositoryProvider);
  return GetConversations(repository);
});

final getConversationMessagesUseCaseProvider = Provider((ref) {
  final repository = ref.read(conversationsRepositoryProvider);
  return GetConversationMessages(repository);
});

final sendMessageUseCaseProvider = Provider((ref) {
  final repository = ref.read(conversationsRepositoryProvider);
  return SendMessage(repository);
});

final markMessagesAsReadUseCaseProvider = Provider((ref) {
  final repository = ref.read(conversationsRepositoryProvider);
  return MarkMessagesAsRead(repository);
});

final deleteConversationUseCaseProvider = Provider((ref) {
  final repository = ref.read(conversationsRepositoryProvider);
  return DeleteConversation(repository);
});

final blockConversationUseCaseProvider = Provider((ref) {
  final repository = ref.read(conversationsRepositoryProvider);
  return BlockConversation(repository);
});

final closeConversationUseCaseProvider = Provider((ref) {
  final repository = ref.read(conversationsRepositoryProvider);
  return CloseConversation(repository);
});

// RealtimeService Provider
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService();
});

// Controller Provider Principal
final conversationsControllerProvider =
    StateNotifierProvider<ConversationsController, ConversationsState>((ref) {
  return ConversationsController(
    getConversations: ref.read(getConversationsUseCaseProvider),
    getConversationMessages: ref.read(getConversationMessagesUseCaseProvider),
    sendMessage: ref.read(sendMessageUseCaseProvider),
    markMessagesAsRead: ref.read(markMessagesAsReadUseCaseProvider),
    deleteConversation: ref.read(deleteConversationUseCaseProvider),
    blockConversation: ref.read(blockConversationUseCaseProvider),
    closeConversation: ref.read(closeConversationUseCaseProvider),
    dataSource: ref.read(conversationsDataSourceProvider),
    realtimeService: ref.read(realtimeServiceProvider),
  );
});

// Providers utilisés pour l'UI - simplifiés avec compteurs locaux
final conversationsListProvider = Provider((ref) {
  final state = ref.watch(conversationsControllerProvider);
  // Les conversations sont déjà triées en DB par last_message_at DESC
  // Plus besoin de tri complexe - les indicateurs visuels utilisent conversation.unreadCount
  return state.conversations;
});

final totalUnreadCountProvider = Provider((ref) {
  final state = ref.watch(conversationsControllerProvider);
  // ✅ SIMPLE: Utiliser directement le compteur total géré en temps réel
  return state.totalUnreadCount;
});

final conversationMessagesProvider =
    Provider.family<List<Message>, String>((ref, conversationId) {
  final state = ref.watch(conversationsControllerProvider);
  return state.conversationMessages[conversationId] ?? [];
});

final conversationUnreadCountProvider =
    Provider.family<int, String>((ref, conversationId) {
  final state = ref.watch(conversationsControllerProvider);
  // ✅ DB-BASED: Utiliser le compteur DB directement de la conversation
  try {
    final conversation = state.conversations.firstWhere(
      (conv) => conv.id == conversationId,
    );
    return conversation.unreadCount;
  } catch (e) {
    // Si conversation non trouvée, retourner 0
    return 0;
  }
});

final isLoadingProvider = Provider((ref) {
  final state = ref.watch(conversationsControllerProvider);
  return state.isLoading;
});

final isLoadingMessagesProvider = Provider((ref) {
  final state = ref.watch(conversationsControllerProvider);
  return state.isLoadingMessages;
});

final isSendingMessageProvider = Provider((ref) {
  final state = ref.watch(conversationsControllerProvider);
  return state.isSendingMessage;
});

final conversationsErrorProvider = Provider((ref) {
  final state = ref.watch(conversationsControllerProvider);
  return state.error;
});

// Provider pour les groupes de conversations avec compteurs DB
final conversationGroupsProvider = Provider<List<ConversationGroup>>((ref) {
  final state = ref.watch(conversationsControllerProvider);

  // Regrouper les conversations en utilisant les compteurs DB
  return ConversationGroupingService.groupConversations(
    state.conversations,
  );
});
