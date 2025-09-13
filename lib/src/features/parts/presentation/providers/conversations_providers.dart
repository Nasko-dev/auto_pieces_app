import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/conversations_controller.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';
import '../../data/datasources/conversations_remote_datasource.dart';
import '../../data/repositories/conversations_repository_impl.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/get_conversation_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/manage_conversation.dart';
import '../../../../core/services/realtime_service.dart';

// DataSource Provider
final conversationsDataSourceProvider = Provider<ConversationsRemoteDataSource>((ref) {
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
final conversationsControllerProvider = StateNotifierProvider<ConversationsController, ConversationsState>((ref) {
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

// Providers utiles pour l'UI
final conversationsListProvider = Provider((ref) {
  final state = ref.watch(conversationsControllerProvider);
  // Trier les conversations : non lues en premier, puis par date du dernier message
  final conversations = [...state.conversations];
  conversations.sort((a, b) {
    // Si une conversation a des messages non lus, elle passe en premier
    if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
    if (a.unreadCount == 0 && b.unreadCount > 0) return 1;
    // Sinon, trier par date du dernier message
    return b.lastMessageAt.compareTo(a.lastMessageAt);
  });
  return conversations;
});

final totalUnreadCountProvider = Provider((ref) {
  final conversations = ref.watch(conversationsListProvider);
  // Calculer le total des messages non lus depuis les conversations
  print('================== CALCUL TOTAL UNREAD COUNT ==================');
  int total = 0;
  for (final conversation in conversations) {
    print('🔍 [Provider] Conversation ${conversation.id}: unreadCount = ${conversation.unreadCount}');
    total += conversation.unreadCount;
  }
  print('📊 [Provider] TOTAL FINAL messages non lus: $total');
  print('==============================================================');
  return total;
});

final conversationMessagesProvider = Provider.family<List<Message>, String>((ref, conversationId) {
  final state = ref.watch(conversationsControllerProvider);
  return state.conversationMessages[conversationId] ?? [];
});

final conversationUnreadCountProvider = Provider.family<int, String>((ref, conversationId) {
  final conversations = ref.watch(conversationsListProvider);
  // Trouver la conversation et retourner son unreadCount
  final conversation = conversations.firstWhere(
    (c) => c.id == conversationId,
    orElse: () => Conversation(
      id: '',
      requestId: '',
      userId: '',
      sellerId: '',
      lastMessageAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      unreadCount: 0,
    ),
  );
  print('🔢 [Provider] Messages non lus pour conversation $conversationId: ${conversation.unreadCount}');
  return conversation.unreadCount;
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