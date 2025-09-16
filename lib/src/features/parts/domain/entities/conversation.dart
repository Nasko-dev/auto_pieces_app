import 'package:freezed_annotation/freezed_annotation.dart';
import 'conversation_enums.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String requestId,
    required String userId,
    required String sellerId,
    @Default(ConversationStatus.active) ConversationStatus status,
    required DateTime lastMessageAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? sellerName,
    String? sellerCompany,
    String? sellerAvatarUrl,
    String? userName,
    String? userDisplayName,
    String? userAvatarUrl,
    String? requestTitle,
    String? lastMessageContent,
    MessageSenderType? lastMessageSenderType,
    DateTime? lastMessageCreatedAt,
    @Default(0) int unreadCount,
    @Default(0) int totalMessages,
    // Informations du véhicule depuis part_request
    String? vehicleBrand,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleEngine,
    String? partType,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}