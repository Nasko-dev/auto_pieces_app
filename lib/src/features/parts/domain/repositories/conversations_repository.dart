import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/conversation_enums.dart';

abstract class ConversationsRepository {
  Future<Either<Failure, List<Conversation>>> getConversations({required String userId});
  
  Future<Either<Failure, List<Message>>> getConversationMessages({
    required String conversationId
  });
  
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType messageType = MessageType.text,
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
  });
  
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  });

  Future<Either<Failure, void>> incrementUnreadCount({
    required String conversationId,
  });

  Future<Either<Failure, void>> deleteConversation({
    required String conversationId
  });
  
  Future<Either<Failure, void>> blockConversation({
    required String conversationId
  });
  
  Future<Either<Failure, void>> closeConversation({
    required String conversationId
  });
  
  Stream<Either<Failure, Message>> subscribeToNewMessages({
    required String conversationId
  });
  
  Stream<Either<Failure, List<Conversation>>> subscribeToConversationUpdates({
    required String userId
  });
}