import 'package:freezed_annotation/freezed_annotation.dart';
import 'conversation.dart';

part 'conversation_group.freezed.dart';

@freezed
class ConversationGroup with _$ConversationGroup {
  const factory ConversationGroup({
    required String groupKey, // Ex: "phare-avant_renault-clio_2015"
    required String partName, // Ex: "Phare avant"
    required String vehicleInfo, // Ex: "Renault Clio 2015"
    String? vehicleBrand,
    String? vehicleModel,
    int? vehicleYear,
    String? partType, // "engine" ou "body"
    required List<Conversation> conversations,
    @Default(0) int totalUnreadCount,
  }) = _ConversationGroup;

  const ConversationGroup._();

  // Helpers
  int get conversationCount => conversations.length;
  bool get hasUnreadMessages => totalUnreadCount > 0;

  String get displayTitle {
    if (partName.isNotEmpty && vehicleInfo.isNotEmpty) {
      return '$partName - $vehicleInfo';
    } else if (partName.isNotEmpty) {
      return partName;
    } else if (vehicleInfo.isNotEmpty) {
      return vehicleInfo;
    }
    return 'Demande pièces';
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