import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/conversations_repository.dart';

class GetConversationMessages
    implements UseCase<List<Message>, GetConversationMessagesParams> {
  final ConversationsRepository repository;

  GetConversationMessages(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(
      GetConversationMessagesParams params) async {
    return await repository.getConversationMessages(
        conversationId: params.conversationId);
  }
}

class GetConversationMessagesParams {
  final String conversationId;

  GetConversationMessagesParams({required this.conversationId});
}
