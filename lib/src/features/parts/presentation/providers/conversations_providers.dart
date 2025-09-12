import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/conversations_controller.dart';
import '../../domain/entities/message.dart';
import '../../data/datasources/conversations_remote_datasource.dart';
import '../../data/repositories/conversations_repository_impl.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/get_conversation_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/manage_conversation.dart';

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
  );
});

// Providers utiles pour l'UI
final conversationsListProvider = Provider((ref) {
  final state = ref.watch(conversationsControllerProvider);
  return state.conversations;
});

final totalUnreadCountProvider = Provider((ref) {
  final state = ref.watch(conversationsControllerProvider);
  return state.totalUnreadCount;
});

final conversationMessagesProvider = Provider.family<List<Message>, String>((ref, conversationId) {
  final state = ref.watch(conversationsControllerProvider);
  return state.conversationMessages[conversationId] ?? [];
});

final conversationUnreadCountProvider = Provider.family<int, String>((ref, conversationId) {
  final controller = ref.read(conversationsControllerProvider.notifier);
  return controller.getUnreadCountForConversation(conversationId);
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