import '../entities/particulier_conversation.dart';
import '../entities/particulier_conversation_group.dart';

/// Service pour grouper les conversations particulier par véhicule (marque + modèle + année)
class ParticulierConversationGroupingService {
  /// Groupe les conversations par véhicule (marque + modèle + année uniquement)
  ///
  /// Retourne une liste de groupes triés par message le plus récent
  List<ParticulierConversationGroup> groupConversations(
    List<ParticulierConversation> conversations,
  ) {
    if (conversations.isEmpty) {
      return [];
    }

    // Map pour stocker les groupes par clé
    final Map<String, List<ParticulierConversation>> groupedMap = {};

    // Grouper les conversations
    for (final conversation in conversations) {
      final groupKey = _generateGroupKey(conversation);

      if (!groupedMap.containsKey(groupKey)) {
        groupedMap[groupKey] = [];
      }
      groupedMap[groupKey]!.add(conversation);
    }

    // Créer les objets ParticulierConversationGroup
    final groups = groupedMap.entries.map((entry) {
      final groupKey = entry.key;
      final groupConversations = entry.value;

      // Trier les conversations par date du dernier message (plus récent en premier)
      groupConversations.sort((a, b) {
        return b.lastMessageAt.compareTo(a.lastMessageAt);
      });

      // Prendre les infos du premier élément du groupe (tous ont les mêmes infos véhicule)
      final firstConversation = groupConversations.first;

      // Calculer le nombre total de messages non lus
      final totalUnreadCount = groupConversations.fold<int>(
        0,
        (sum, conv) => sum + conv.unreadCount,
      );

      return ParticulierConversationGroup(
        groupKey: groupKey,
        vehicleInfo: _generateVehicleInfo(firstConversation),
        vehicleBrand: firstConversation.partRequest.vehicleBrand,
        vehicleModel: firstConversation.partRequest.vehicleModel,
        vehicleYear: firstConversation.partRequest.vehicleYear,
        vehiclePlate: firstConversation.partRequest.vehiclePlate,
        conversations: groupConversations,
        totalUnreadCount: totalUnreadCount,
      );
    }).toList();

    // Trier les groupes par date du message le plus récent
    groups.sort((a, b) {
      final aDate = a.lastMessageAt;
      final bDate = b.lastMessageAt;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1; // Les groupes sans date vont à la fin
      if (bDate == null) return -1;

      return bDate.compareTo(aDate); // Tri décroissant (plus récent en premier)
    });

    return groups;
  }

  /// Génère une clé unique pour le groupe basée sur marque + modèle + année
  /// Format: "renault_clio_2015"
  String _generateGroupKey(ParticulierConversation conversation) {
    final brand = (conversation.partRequest.vehicleBrand ?? 'inconnu')
        .toLowerCase()
        .replaceAll(' ', '_');
    final model = (conversation.partRequest.vehicleModel ?? 'inconnu')
        .toLowerCase()
        .replaceAll(' ', '_');
    final year = conversation.partRequest.vehicleYear?.toString() ?? 'inconnu';

    return '${brand}_${model}_$year';
  }

  /// Génère le texte d'affichage pour le véhicule
  /// Format: "Renault Clio 2015"
  String _generateVehicleInfo(ParticulierConversation conversation) {
    final parts = <String>[];

    if (conversation.partRequest.vehicleBrand != null &&
        conversation.partRequest.vehicleBrand!.isNotEmpty) {
      parts.add(conversation.partRequest.vehicleBrand!);
    }

    if (conversation.partRequest.vehicleModel != null &&
        conversation.partRequest.vehicleModel!.isNotEmpty) {
      parts.add(conversation.partRequest.vehicleModel!);
    }

    if (conversation.partRequest.vehicleYear != null) {
      parts.add(conversation.partRequest.vehicleYear.toString());
    }

    if (parts.isEmpty) {
      return 'Véhicule non spécifié';
    }

    return parts.join(' ');
  }
}
