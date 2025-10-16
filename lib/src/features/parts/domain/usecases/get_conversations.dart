import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversations_repository.dart';

class GetConversations
    implements UseCase<List<Conversation>, GetConversationsParams> {
  final ConversationsRepository repository;

  GetConversations(this.repository);

  @override
  Future<Either<Failure, List<Conversation>>> call(
      GetConversationsParams params) async {
    return await repository.getConversations(userId: params.userId);
  }
}

class GetConversationsParams {
  final String userId;

  GetConversationsParams({required this.userId});
}
