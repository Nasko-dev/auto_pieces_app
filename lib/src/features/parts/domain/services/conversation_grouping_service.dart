import '../entities/conversation.dart';
import '../entities/conversation_group.dart';

class ConversationGroupingService {
  static List<ConversationGroup> groupConversations(
    List<Conversation> conversations, {
    Map<String, int>? localUnreadCounts,
  }) {
    print('🔄 [GroupingService] Groupement de ${conversations.length} conversations');

    // Map pour regrouper par clé unique
    final Map<String, List<Conversation>> grouped = {};

    for (final conversation in conversations) {
      final groupKey = _generateGroupKey(conversation);

      if (grouped.containsKey(groupKey)) {
        grouped[groupKey]!.add(conversation);
      } else {
        grouped[groupKey] = [conversation];
      }
    }

    print('🏷️ [GroupingService] ${grouped.length} groupes créés');

    // Convertir en ConversationGroup et trier
    final groups = grouped.entries.map((entry) {
      final conversations = entry.value;
      final firstConv = conversations.first;

      // Calculer le nombre total de messages non lus
      // Utiliser les compteurs locaux si disponibles, sinon les compteurs des conversations
      final totalUnreadCount = conversations
          .map((c) => localUnreadCounts?[c.id] ?? c.unreadCount)
          .fold(0, (sum, count) => sum + count);

      return ConversationGroup(
        groupKey: entry.key,
        partName: _extractPartName(firstConv),
        vehicleInfo: _extractVehicleInfo(firstConv),
        vehicleBrand: firstConv.vehicleBrand,
        vehicleModel: firstConv.vehicleModel,
        vehicleYear: firstConv.vehicleYear,
        partType: firstConv.partType,
        conversations: conversations,
        totalUnreadCount: totalUnreadCount,
      );
    }).toList();

    // Trier les groupes par date du dernier message
    groups.sort((a, b) {
      final aLastMessage = a.lastMessageAt;
      final bLastMessage = b.lastMessageAt;

      if (aLastMessage == null && bLastMessage == null) return 0;
      if (aLastMessage == null) return 1;
      if (bLastMessage == null) return -1;

      return bLastMessage.compareTo(aLastMessage); // Plus récent en premier
    });

    print('✅ [GroupingService] Groupement terminé');
    return groups;
  }

  static String _generateGroupKey(Conversation conversation) {
    // Créer une clé unique basée sur : pièce + véhicule
    final parts = <String>[];

    // Ajouter les informations de la pièce
    if (conversation.requestTitle != null && conversation.requestTitle!.isNotEmpty) {
      // Nettoyer le titre (enlever caractères spéciaux, mettre en minuscules)
      final cleanTitle = conversation.requestTitle!
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
          .replaceAll(RegExp(r'\s+'), '-');
      parts.add(cleanTitle);
    }

    // Ajouter les informations du véhicule
    if (conversation.vehicleBrand != null) {
      parts.add(conversation.vehicleBrand!.toLowerCase());
    }
    if (conversation.vehicleModel != null) {
      parts.add(conversation.vehicleModel!.toLowerCase());
    }
    if (conversation.vehicleYear != null) {
      parts.add(conversation.vehicleYear.toString());
    }

    // Si pas d'infos, utiliser l'ID de la demande
    if (parts.isEmpty) {
      parts.add('demande-${conversation.requestId}');
    }

    return parts.join('_');
  }

  static String _extractPartName(Conversation conversation) {
    if (conversation.requestTitle != null && conversation.requestTitle!.isNotEmpty) {
      return conversation.requestTitle!;
    }
    return 'Pièce demandée';
  }

  static String _extractVehicleInfo(Conversation conversation) {
    if (conversation.partType == 'engine') {
      // Pour les pièces moteur : afficher seulement la motorisation
      if (conversation.vehicleEngine != null && conversation.vehicleEngine!.isNotEmpty) {
        return conversation.vehicleEngine!;
      }
    } else {
      // Pour les pièces carrosserie : afficher marque + modèle + année
      final parts = <String>[];
      if (conversation.vehicleBrand != null) parts.add(conversation.vehicleBrand!);
      if (conversation.vehicleModel != null) parts.add(conversation.vehicleModel!);
      if (conversation.vehicleYear != null) parts.add(conversation.vehicleYear.toString());

      if (parts.isNotEmpty) {
        return parts.join(' ');
      }
    }

    // Fallback : toutes les infos disponibles
    final parts = <String>[];
    if (conversation.vehicleBrand != null) parts.add(conversation.vehicleBrand!);
    if (conversation.vehicleModel != null) parts.add(conversation.vehicleModel!);
    if (conversation.vehicleYear != null) parts.add(conversation.vehicleYear.toString());

    if (parts.isEmpty && conversation.vehicleEngine != null) {
      return conversation.vehicleEngine!;
    }

    return parts.isNotEmpty ? parts.join(' ') : 'Véhicule';
  }
}