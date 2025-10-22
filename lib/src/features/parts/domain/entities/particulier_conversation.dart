import 'package:freezed_annotation/freezed_annotation.dart';
import 'part_request.dart';
import 'particulier_message.dart';
import 'conversation_enums.dart';

part 'particulier_conversation.freezed.dart';

@freezed
class ParticulierConversation with _$ParticulierConversation {
  const factory ParticulierConversation({
    required String id,
    required PartRequest partRequest,
    required String sellerName,
    required String sellerId,
    required List<ParticulierMessage> messages,
    required DateTime lastMessageAt,
    required ConversationStatus status,
    @Default(false) bool hasUnreadMessages,
    @Default(0) int unreadCount,
    double? latestOfferPrice,
    int? latestOfferDeliveryDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vehiclePlate,
    String? partType,
    List<String>? partNames,
    bool? hasNewMessages,
    // Nouvelles données vendeur pour l'AppBar Instagram
    String? sellerCompany,
    String? sellerAvatarUrl,
    String? sellerPhone,
  }) = _ParticulierConversation;
}
