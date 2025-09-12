import 'package:freezed_annotation/freezed_annotation.dart';
import 'conversation_enums.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required MessageSenderType senderType,
    required String content,
    @Default(MessageType.text) MessageType messageType,
    @Default([]) List<String> attachments,
    @Default({}) Map<String, dynamic> metadata,
    @Default(false) bool isRead,
    DateTime? readAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}