import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/conversations_repository.dart';

class MarkMessagesAsRead implements UseCase<void, MarkMessagesAsReadParams> {
  final ConversationsRepository repository;

  MarkMessagesAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkMessagesAsReadParams params) async {
    print('👀 [UseCase] MarkMessagesAsRead - conversationId: ${params.conversationId}');
    return await repository.markMessagesAsRead(
      conversationId: params.conversationId,
      userId: params.userId,
    );
  }
}

class DeleteConversation implements UseCase<void, ConversationParams> {
  final ConversationsRepository repository;

  DeleteConversation(this.repository);

  @override
  Future<Either<Failure, void>> call(ConversationParams params) async {
    print('🗑️ [UseCase] DeleteConversation - conversationId: ${params.conversationId}');
    return await repository.deleteConversation(conversationId: params.conversationId);
  }
}

class BlockConversation implements UseCase<void, ConversationParams> {
  final ConversationsRepository repository;

  BlockConversation(this.repository);

  @override
  Future<Either<Failure, void>> call(ConversationParams params) async {
    print('🚫 [UseCase] BlockConversation - conversationId: ${params.conversationId}');
    return await repository.blockConversation(conversationId: params.conversationId);
  }
}

class CloseConversation implements UseCase<void, ConversationParams> {
  final ConversationsRepository repository;

  CloseConversation(this.repository);

  @override
  Future<Either<Failure, void>> call(ConversationParams params) async {
    print('📪 [UseCase] CloseConversation - conversationId: ${params.conversationId}');
    return await repository.closeConversation(conversationId: params.conversationId);
  }
}

// Paramètres
class MarkMessagesAsReadParams {
  final String conversationId;
  final String userId;

  MarkMessagesAsReadParams({
    required this.conversationId,
    required this.userId,
  });
}

class ConversationParams {
  final String conversationId;

  ConversationParams({required this.conversationId});
}