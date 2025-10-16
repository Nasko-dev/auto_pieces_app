import 'package:freezed_annotation/freezed_annotation.dart';
import 'conversation_enums.dart';

part 'particulier_message.freezed.dart';

@freezed
class ParticulierMessage with _$ParticulierMessage {
  const factory ParticulierMessage({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    required MessageType type,
    required DateTime createdAt,
    @Default(false) bool isFromParticulier,
    @Default(false) bool isRead,
    double? offerPrice,
    int? offerDeliveryDays,
    String? offerAvailability,
  }) = _ParticulierMessage;
}
