import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../entities/conversation_enums.dart';
import '../repositories/conversations_repository.dart';

class SendMessage implements UseCase<Message, SendMessageParams> {
  final ConversationsRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      conversationId: params.conversationId,
      senderId: params.senderId,
      content: params.content,
      messageType: params.messageType,
      attachments: params.attachments,
      metadata: params.metadata,
      offerPrice: params.offerPrice,
      offerAvailability: params.offerAvailability,
      offerDeliveryDays: params.offerDeliveryDays,
    );
  }
}

class SendMessageParams {
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType messageType;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final double? offerPrice;
  final String? offerAvailability;
  final int? offerDeliveryDays;

  SendMessageParams({
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = MessageType.text,
    this.attachments = const [],
    this.metadata = const {},
    this.offerPrice,
    this.offerAvailability,
    this.offerDeliveryDays,
  });
}
