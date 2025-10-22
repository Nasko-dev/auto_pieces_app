import 'package:freezed_annotation/freezed_annotation.dart';
import 'particulier_conversation.dart';

part 'particulier_conversation_group.freezed.dart';

@freezed
class ParticulierConversationGroup with _$ParticulierConversationGroup {
  const factory ParticulierConversationGroup({
    required String groupKey, // Ex: "renault_clio_2015"
    required String vehicleInfo, // Ex: "Renault Clio 2015"
    String? vehicleBrand,
    String? vehicleModel,
    int? vehicleYear,
    String? vehiclePlate,
    required List<ParticulierConversation> conversations,
    @Default(0) int totalUnreadCount,
  }) = _ParticulierConversationGroup;

  const ParticulierConversationGroup._();

  // Helpers
  int get conversationCount => conversations.length;
  bool get hasUnreadMessages => totalUnreadCount > 0;

  String get displayTitle {
    if (vehicleInfo.isNotEmpty) {
      return vehicleInfo;
    }
    return 'Véhicule non spécifié';
  }

  DateTime? get lastMessageAt {
    if (conversations.isEmpty) return null;

    // Retourner la date du message le plus récent parmi toutes les conversations
    DateTime? latest;
    for (final conv in conversations) {
      if (latest == null || conv.lastMessageAt.isAfter(latest)) {
        latest = conv.lastMessageAt;
      }
    }
    return latest;
  }
}
