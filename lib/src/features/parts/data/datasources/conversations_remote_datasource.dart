import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation_enums.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/device_service.dart';

abstract class ConversationsRemoteDataSource {
  Future<List<Conversation>> getConversations({required String userId});
  Future<List<Message>> getConversationMessages({required String conversationId});
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType messageType = MessageType.text,
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
    MessageSenderType? senderType, // Nouveau paramètre optionnel
  });
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  });
  Future<void> incrementUnreadCount({
    required String conversationId,
  });
  Future<void> incrementUnreadCountForUser({
    required String conversationId,
  });
  Future<void> incrementUnreadCountForSeller({
    required String conversationId,
  });
  Future<void> updateConversationStatus({
    required String conversationId,
    required ConversationStatus status,
  });
  Future<void> deleteConversation({required String conversationId});
  Future<void> blockConversation({required String conversationId});
  Stream<Message> subscribeToNewMessages({required String conversationId});
  Stream<Conversation> subscribeToConversationUpdates({required String userId});
  Future<Conversation> createOrGetConversation({
    required String requestId,
    required String userId,
    required String sellerId,
    required String sellerName,
    String? sellerCompany,
    required String requestTitle,
  });
}

class ConversationsRemoteDataSourceImpl implements ConversationsRemoteDataSource {
  final SupabaseClient _supabaseClient;

  ConversationsRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<List<Conversation>> getConversations({required String userId}) async {
    print('🔍 [Datasource] Récupération conversations pour user: $userId');
    
    try {
      // Détecter si c'est un vendeur ou un particulier
      final isSellerResult = await _checkIfUserIsSeller(userId);
      
      if (isSellerResult) {
        print('🏪 [Datasource] Mode vendeur détecté');
        return _getSellerConversations(userId);
      } else {
        print('👤 [Datasource] Mode particulier détecté');
        return _getParticulierConversations(userId);
      }
      
    } catch (e) {
      print('❌ [Datasource] Erreur récupération conversations: $e');
      throw ServerException('Erreur lors de la récupération des conversations: $e');
    }
  }

  Future<bool> _checkIfUserIsSeller(String userId) async {
    try {
      final sellerResponse = await _supabaseClient
          .from('sellers')
          .select('id')
          .eq('id', userId)
          .limit(1);
      
      final isSeller = sellerResponse.isNotEmpty;
      print('🔍 [Datasource] User $userId est ${isSeller ? 'vendeur' : 'particulier'}');
      return isSeller;
    } catch (e) {
      print('⚠️ [Datasource] Erreur vérification vendeur: $e');
      return false;
    }
  }

  Future<List<Conversation>> _getSellerConversations(String sellerId) async {
    print('🏪 [Datasource] Récupération conversations vendeur: $sellerId');

    final response = await _supabaseClient
        .from('conversations')
        .select('''
          id,
          request_id,
          user_id,
          seller_id,
          status,
          last_message_at,
          created_at,
          updated_at,
          seller_name,
          seller_company,
          request_title,
          last_message_content,
          last_message_sender_type,
          last_message_created_at,
          unread_count,
          unread_count_for_user,
          unread_count_for_seller,
          total_messages,
          part_requests (
            vehicle_brand,
            vehicle_model,
            vehicle_year,
            vehicle_engine,
            part_type
          ),
          particuliers (
            first_name
          )
        ''')
        .eq('seller_id', sellerId)
        .eq('status', 'active')
        .order('last_message_at', ascending: false);

    print('📋 [Datasource] Reçu ${response.length} conversations vendeur');

    return response.map((json) {
      final unreadForSeller = json['unread_count_for_seller'] ?? 0;
      print('📄 [Datasource] Conversion conversation vendeur: ${json['id']} (unread_count_for_seller: $unreadForSeller)');
      return Conversation.fromJson(_mapSupabaseToConversationForSeller(json));
    }).toList();
  }

  Future<List<Conversation>> _getParticulierConversations(String userId) async {
    print('👤 [Datasource] Récupération conversations particulier: $userId');
    
    try {
      // Utiliser la même logique que les part_requests : récupérer par device_id
      print('🔍 [Datasource] Recherche du device_id pour récupération persistante...');
      
      try {
        // Obtenir le device_id depuis le service device (plus fiable que l'auth ID)
        final prefs = await SharedPreferences.getInstance();
        final deviceService = DeviceService(prefs);
        final deviceId = await deviceService.getDeviceId();
        print('📱 [Datasource] Device ID obtenu: $deviceId');
        
        // Récupérer tous les particuliers avec ce device_id
        final allParticuliersWithDevice = await _supabaseClient
            .from('particuliers')
            .select('id')
            .eq('device_id', deviceId);
            
        final allUserIds = allParticuliersWithDevice
            .map((p) => p['id'] as String)
            .toList();
            
        print('🆔 [Datasource] IDs utilisateur trouvés pour ce device: $allUserIds');
        
        if (allUserIds.isNotEmpty) {
          // Récupérer les conversations pour TOUS ces user_id
          print('📡 [Datasource] Requête vers conversations pour tous les IDs');
          
          final response = await _supabaseClient
              .from('conversations')
              .select('''
                id,
                request_id,
                user_id,
                seller_id,
                status,
                last_message_at,
                created_at,
                updated_at,
                seller_name,
                seller_company,
                request_title,
                last_message_content,
                last_message_sender_type,
                last_message_created_at,
                unread_count,
                total_messages
              ''')
              .inFilter('user_id', allUserIds)
              .order('last_message_at', ascending: false);

          print('📋 [Datasource] Reçu ${response.length} conversations pour tous les user_ids');

          return response.map((json) {
            print('📄 [Datasource] Conversion conversation: ${json['id']} (user: ${json['user_id']})');
            return Conversation.fromJson(_mapSupabaseToConversation(json));
          }).toList();
        } else {
          print('⚠️ [Datasource] Aucun utilisateur trouvé pour ce device_id');
        }
        
      } catch (particulierError) {
        print('⚠️ [Datasource] Erreur recherche particulier: $particulierError');
      }
      
      print('🔄 [Datasource] Fallback: recherche directe par auth ID actuel');
      
      // Fallback : recherche directe par l'auth ID actuel
      final response = await _supabaseClient
          .from('conversations')
          .select('''
            id,
            request_id,
            user_id,
            seller_id,
            status,
            last_message_at,
            created_at,
            updated_at,
            seller_name,
            seller_company,
            request_title,
            last_message_content,
            last_message_sender_type,
            last_message_created_at,
            unread_count,
            total_messages
          ''')
          .eq('user_id', userId)
          .order('last_message_at', ascending: false);

      print('📋 [Datasource] Reçu ${response.length} conversations (fallback)');

      return response.map((json) {
        print('📄 [Datasource] Conversion conversation: ${json['id']}');
        return Conversation.fromJson(_mapSupabaseToConversation(json));
      }).toList();
      
    } catch (e) {
      print('❌ [Datasource] Erreur récupération conversations particulier: $e');
      throw ServerException('Erreur lors de la récupération des conversations: $e');
    }
  }

  @override
  Future<List<Message>> getConversationMessages({required String conversationId}) async {
    print('📨 [Datasource] Récupération messages pour conversation: $conversationId');
    
    try {
      final response = await _supabaseClient
          .from('messages')
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      print('💬 [Datasource] Reçu ${response.length} messages');

      return response.map((json) {
        return Message.fromJson(_mapSupabaseToMessage(json));
      }).toList();
      
    } catch (e) {
      print('❌ [Datasource] Erreur récupération messages: $e');
      throw ServerException('Erreur lors de la récupération des messages: $e');
    }
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType messageType = MessageType.text,
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
    MessageSenderType? senderType,
  }) async {
    print('📤 [Datasource] Envoi message: $content');
    
    try {
      // Déterminer automatiquement le sender_type si pas fourni
      String senderTypeString;
      if (senderType != null) {
        senderTypeString = senderType == MessageSenderType.user ? 'user' : 'seller';
      } else {
        // Auto-détection : vérifier si l'expéditeur est dans la table sellers
        senderTypeString = await _determineSenderType(senderId);
      }
      
      print('👤 [Datasource] Sender type déterminé: $senderTypeString');
      
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_type': senderTypeString,
        'content': content,
        'message_type': messageType.toString().split('.').last,
        'offer_price': offerPrice,
        'offer_availability': offerAvailability,
        'offer_delivery_days': offerDeliveryDays,
        // Laisser Supabase générer les timestamps (UTC) pour éviter les problèmes de fuseau horaire
        // 'created_at' et 'updated_at' seront générés automatiquement par Supabase
      };

      final response = await _supabaseClient
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      print('✅ [Datasource] Message envoyé avec succès');
      
      // Mettre à jour la conversation avec le bon sender type
      await _updateConversationLastMessage(conversationId, content, senderTypeString);

      // ✅ NOUVEAU: Avec trigger intelligent, plus besoin de reset manuel
      // Le trigger DB gère automatiquement les bons compteurs selon sender_type
      print('✅ [Datasource] Trigger DB gère les compteurs automatiquement');

      return Message.fromJson(_mapSupabaseToMessage(response));
      
    } catch (e) {
      print('❌ [Datasource] Erreur envoi message: $e');
      throw ServerException('Erreur lors de l\'envoi du message: $e');
    }
  }

  Future<void> _updateConversationLastMessage(String conversationId, String content, String senderType) async {
    try {
      await _supabaseClient
          .from('conversations')
          .update({
            'last_message_content': content,
            'last_message_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
            'last_message_sender_type': senderType, // ✅ CORRECTION: Utiliser le vrai sender type
            'last_message_created_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
            'updated_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
          })
          .eq('id', conversationId);

      print('✅ [Datasource] Conversation mise à jour avec sender_type: $senderType');
    } catch (e) {
      print('⚠️ [Datasource] Erreur mise à jour conversation: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    print('👀 [Datasource] Marquage messages comme lus: $conversationId');

    try {
      // Déterminer le type d'utilisateur pour savoir quels messages marquer
      final isSellerResult = await _checkIfUserIsSeller(userId);

      if (isSellerResult) {
        // Vendeur : marquer les messages des particuliers comme lus
        await _supabaseClient
            .from('messages')
            .update({
              'is_read': true,
              'read_at': 'now()',
            })
            .eq('conversation_id', conversationId)
            .eq('sender_type', 'user')
            .eq('is_read', false);
      } else {
        // Particulier : marquer les messages des vendeurs comme lus
        await _supabaseClient
            .from('messages')
            .update({
              'is_read': true,
              'read_at': 'now()',
            })
            .eq('conversation_id', conversationId)
            .eq('sender_type', 'seller')
            .eq('is_read', false);
      }

      // Remettre les compteurs à 0 selon le type d'utilisateur
      if (isSellerResult) {
        // Vendeur lit → reset son compteur
        await _supabaseClient
            .from('conversations')
            .update({'unread_count_for_seller': 0})
            .eq('id', conversationId);
      } else {
        // Particulier lit → reset son compteur
        await _supabaseClient
            .from('conversations')
            .update({'unread_count_for_user': 0})
            .eq('id', conversationId);
      }

      print('✅ [Datasource] Messages marqués comme lus');

    } catch (e) {
      print('❌ [Datasource] Erreur marquage lecture: $e');
      throw ServerException('Erreur lors du marquage des messages comme lus: $e');
    }
  }

  @override
  Future<void> incrementUnreadCount({
    required String conversationId,
  }) async {
    print('📈 [Datasource] Incrémentation compteur non lu: $conversationId');

    try {
      // Utiliser une requête SQL pour incrémenter atomiquement
      await _supabaseClient.rpc('increment_unread_count', params: {
        'conversation_id_param': conversationId,
      });

      print('✅ [Datasource] Compteur non lu incrémenté');

    } catch (e) {
      print('❌ [Datasource] Erreur incrémentation compteur: $e');
      // Fallback : récupérer le compteur actuel et incrémenter
      try {
        final response = await _supabaseClient
            .from('conversations')
            .select('unread_count')
            .eq('id', conversationId)
            .single();

        final currentCount = (response['unread_count'] as int?) ?? 0;

        await _supabaseClient
            .from('conversations')
            .update({'unread_count': currentCount + 1})
            .eq('id', conversationId);

        print('✅ [Datasource] Compteur incrémenté (fallback)');
      } catch (fallbackError) {
        print('❌ [Datasource] Erreur fallback incrémentation: $fallbackError');
        throw ServerException('Erreur lors de l\'incrémentation du compteur: $fallbackError');
      }
    }
  }

  @override
  Future<void> incrementUnreadCountForUser({
    required String conversationId,
  }) async {
    print('📈 [Datasource] Incrémentation compteur particulier: $conversationId');

    try {
      await _supabaseClient
          .from('conversations')
          .update({'unread_count_for_user': 'unread_count_for_user + 1'})
          .eq('id', conversationId);

      print('✅ [Datasource] Compteur particulier incrémenté');
    } catch (e) {
      print('❌ [Datasource] Erreur incrémentation particulier: $e');
      throw ServerException('Erreur lors de l\'incrémentation du compteur particulier: $e');
    }
  }

  @override
  Future<void> incrementUnreadCountForSeller({
    required String conversationId,
  }) async {
    print('📈 [Datasource] Incrémentation compteur vendeur: $conversationId');

    try {
      await _supabaseClient
          .from('conversations')
          .update({'unread_count_for_seller': 'unread_count_for_seller + 1'})
          .eq('id', conversationId);

      print('✅ [Datasource] Compteur vendeur incrémenté');
    } catch (e) {
      print('❌ [Datasource] Erreur incrémentation vendeur: $e');
      throw ServerException('Erreur lors de l\'incrémentation du compteur vendeur: $e');
    }
  }

  @override
  Future<void> updateConversationStatus({
    required String conversationId,
    required ConversationStatus status,
  }) async {
    print('🔄 [Datasource] Mise à jour statut conversation: ${status.toString()}');
    
    try {
      await _supabaseClient
          .from('conversations')
          .update({
            'status': _conversationStatusToString(status),
            'updated_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
          })
          .eq('id', conversationId);

      print('✅ [Datasource] Statut conversation mis à jour');
      
    } catch (e) {
      print('❌ [Datasource] Erreur mise à jour statut: $e');
      throw ServerException('Erreur lors de la mise à jour du statut: $e');
    }
  }

  @override
  Future<void> deleteConversation({required String conversationId}) async {
    print('🗑️ [Datasource] Suppression conversation: $conversationId');
    
    try {
      await updateConversationStatus(
        conversationId: conversationId,
        status: ConversationStatus.deletedByUser,
      );
      print('✅ [Datasource] Conversation supprimée (marquée comme deleted_by_user)');
      
    } catch (e) {
      print('❌ [Datasource] Erreur suppression conversation: $e');
      throw ServerException('Erreur lors de la suppression de la conversation: $e');
    }
  }

  @override
  Future<void> blockConversation({required String conversationId}) async {
    print('🚫 [Datasource] Blocage conversation: $conversationId');
    
    try {
      await updateConversationStatus(
        conversationId: conversationId,
        status: ConversationStatus.blockedByUser,
      );
      print('✅ [Datasource] Conversation bloquée');
      
    } catch (e) {
      print('❌ [Datasource] Erreur blocage conversation: $e');
      throw ServerException('Erreur lors du blocage de la conversation: $e');
    }
  }

  @override
  Stream<Message> subscribeToNewMessages({required String conversationId}) {
    print('📡 [Datasource] Abonnement realtime messages: $conversationId');
    
    return _supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .map((data) {
          print('📨 [Realtime] Nouveau message reçu');
          return Message.fromJson(_mapSupabaseToMessage(data.last));
        });
  }

  @override
  Stream<Conversation> subscribeToConversationUpdates({required String userId}) {
    print('📡 [Datasource] Abonnement realtime conversations: $userId');
    
    // Utiliser la même logique que getConversations pour trouver les vrais user_ids
    return Stream.fromFuture(_getAllUserIdsForDevice()).asyncExpand((userIds) {
      if (userIds.isEmpty) {
        print('⚠️ [Realtime] Aucun user_id trouvé, fallback vers auth ID: $userId');
        return _supabaseClient
            .from('conversations')
            .stream(primaryKey: ['id'])
            .eq('user_id', userId)
            .where((data) => data.isNotEmpty)
            .map((data) {
              print('🔄 [Realtime] Conversation mise à jour (fallback)');
              return Conversation.fromJson(_mapSupabaseToConversation(data.last));
            });
      }
      
      print('📡 [Realtime] Abonnement pour user_ids: $userIds');
      return _supabaseClient
          .from('conversations')
          .stream(primaryKey: ['id'])
          .inFilter('user_id', userIds)
          .where((data) => data.isNotEmpty)
          .map((data) {
            print('🔄 [Realtime] Conversation mise à jour');
            return Conversation.fromJson(_mapSupabaseToConversation(data.last));
          });
    });
  }

  // Helper method pour récupérer tous les user_ids du device
  Future<List<String>> _getAllUserIdsForDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceService = DeviceService(prefs);
      final deviceId = await deviceService.getDeviceId();
      
      final allParticuliersWithDevice = await _supabaseClient
          .from('particuliers')
          .select('id')
          .eq('device_id', deviceId);
          
      final allUserIds = allParticuliersWithDevice
          .map((p) => p['id'] as String)
          .toList();
          
      print('🆔 [Realtime] User IDs trouvés pour device: $allUserIds');
      return allUserIds;
    } catch (e) {
      print('⚠️ [Realtime] Erreur récupération user_ids: $e');
      return [];
    }
  }

  // Helper methods pour la conversion
  Map<String, dynamic> _mapSupabaseToConversation(Map<String, dynamic> json) {
    // Extraire les données du véhicule depuis part_requests
    String? vehicleBrand;
    String? vehicleModel;
    int? vehicleYear;
    String? vehicleEngine;
    String? partType;

    if (json['part_requests'] != null) {
      final partRequest = json['part_requests'] as Map<String, dynamic>;
      vehicleBrand = partRequest['vehicle_brand'];
      vehicleModel = partRequest['vehicle_model'];
      vehicleYear = partRequest['vehicle_year'];
      vehicleEngine = partRequest['vehicle_engine'];
      partType = partRequest['part_type'];
    }

    // Extraire le prénom du particulier depuis particuliers
    String? particulierFirstName;
    if (json['particuliers'] != null) {
      final particulier = json['particuliers'] as Map<String, dynamic>;
      particulierFirstName = particulier['first_name'];
    }

    return {
      'id': json['id'],
      'requestId': json['request_id'],
      'userId': json['user_id'],
      'sellerId': json['seller_id'],
      'status': json['status'] ?? 'active', // Garder la string directement
      'lastMessageAt': json['last_message_at'],
      'createdAt': json['created_at'],
      'updatedAt': json['updated_at'],
      'sellerName': json['seller_name'],
      'sellerCompany': json['seller_company'],
      'requestTitle': json['request_title'],
      'lastMessageContent': json['last_message_content'],
      'lastMessageSenderType': json['last_message_sender_type'] ?? 'user', // Garder la string directement
      'lastMessageCreatedAt': json['last_message_created_at'],
      'unreadCount': json['unread_count'] ?? 0, // ⚠️ Ancien champ, à supprimer plus tard
      'totalMessages': json['total_messages'] ?? 0,
      // Nouvelles données du véhicule
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehicleEngine': vehicleEngine,
      'partType': partType,
      // Nom du particulier
      'particulierFirstName': particulierFirstName,
    };
  }

  // ✅ NOUVEAU: Mapping spécifique vendeur
  Map<String, dynamic> _mapSupabaseToConversationForSeller(Map<String, dynamic> json) {
    final baseMapping = _mapSupabaseToConversation(json);
    // Remplacer par le compteur vendeur
    baseMapping['unreadCount'] = json['unread_count_for_seller'] ?? 0;
    return baseMapping;
  }

  // ✅ NOUVEAU: Mapping spécifique particulier
  Map<String, dynamic> _mapSupabaseToConversationForUser(Map<String, dynamic> json) {
    final baseMapping = _mapSupabaseToConversation(json);
    // Remplacer par le compteur particulier
    baseMapping['unreadCount'] = json['unread_count_for_user'] ?? 0;
    return baseMapping;
  }

  Map<String, dynamic> _mapSupabaseToMessage(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'conversationId': json['conversation_id'],
      'senderId': json['sender_id'],
      'senderType': json['sender_type'] ?? 'user', // Garder la string directement
      'content': json['content'],
      'messageType': json['message_type'] ?? 'text', // Garder la string directement
      'attachments': json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : <String>[],
      'metadata': json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : <String, dynamic>{},
      'isRead': json['is_read'] ?? false,
      'readAt': json['read_at'],
      'createdAt': json['created_at'],
      'updatedAt': json['updated_at'],
      'offerPrice': json['offer_price']?.toDouble(),
      'offerAvailability': json['offer_availability'],
      'offerDeliveryDays': json['offer_delivery_days'],
    };
  }

  ConversationStatus _stringToConversationStatus(String? status) {
    switch (status) {
      case 'active':
        return ConversationStatus.active;
      case 'closed':
        return ConversationStatus.closed;
      case 'deleted_by_user':
        return ConversationStatus.deletedByUser;
      case 'blocked_by_user':
        return ConversationStatus.blockedByUser;
      default:
        return ConversationStatus.active;
    }
  }

  String _conversationStatusToString(ConversationStatus status) {
    switch (status) {
      case ConversationStatus.active:
        return 'active';
      case ConversationStatus.closed:
        return 'closed';
      case ConversationStatus.deletedByUser:
        return 'deleted_by_user';
      case ConversationStatus.blockedByUser:
        return 'blocked_by_user';
    }
  }

  MessageSenderType _stringToSenderType(String? type) {
    switch (type) {
      case 'user':
        return MessageSenderType.user;
      case 'seller':
        return MessageSenderType.seller;
      default:
        return MessageSenderType.user;
    }
  }

  MessageType _stringToMessageType(String? type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'offer':
        return MessageType.offer;
      default:
        return MessageType.text;
    }
  }

  Future<String> _determineSenderType(String senderId) async {
    try {
      // Vérifier si l'ID est dans la table sellers
      final sellerCheck = await _supabaseClient
          .from('sellers')
          .select('id')
          .eq('id', senderId)
          .limit(1);
      
      if (sellerCheck.isNotEmpty) {
        print('✅ [Datasource] $senderId est un vendeur');
        return 'seller';
      } else {
        print('👤 [Datasource] $senderId est un particulier');
        return 'user';
      }
    } catch (e) {
      print('⚠️ [Datasource] Erreur détermination sender_type: $e');
      return 'user'; // Fallback vers user par défaut
    }
  }

  @override
  Future<Conversation> createOrGetConversation({
    required String requestId,
    required String userId,
    required String sellerId,
    required String sellerName,
    String? sellerCompany,
    required String requestTitle,
  }) async {
    print('🔍 [Datasource] Vérification conversation existante pour request: $requestId');
    
    try {
      // 1. Vérifier si une conversation existe déjà pour cette demande spécifique
      final existingConversations = await _supabaseClient
          .from('conversations')
          .select('''
            id,
            request_id,
            user_id,
            seller_id,
            status,
            last_message_at,
            created_at,
            updated_at,
            seller_name,
            seller_company,
            request_title,
            last_message_content,
            last_message_sender_type,
            last_message_created_at,
            unread_count,
            total_messages
          ''')
          .eq('request_id', requestId)
          .eq('user_id', userId)
          .eq('seller_id', sellerId);

      if (existingConversations.isNotEmpty) {
        print('✅ [Datasource] Conversation existante trouvée');
        return Conversation.fromJson(_mapSupabaseToConversation(existingConversations.first));
      }

      // 2. Créer une nouvelle conversation pour cette demande
      print('📝 [Datasource] Création nouvelle conversation pour request: $requestId');
      
      final newConversation = {
        'request_id': requestId,
        'user_id': userId,
        'seller_id': sellerId,
        'status': 'active',
        'seller_name': sellerName,
        'seller_company': sellerCompany,
        'request_title': requestTitle,
        'last_message_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
        'created_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
        'updated_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
        'unread_count': 0,
        'total_messages': 0,
      };

      final response = await _supabaseClient
          .from('conversations')
          .insert(newConversation)
          .select()
          .single();

      print('✅ [Datasource] Nouvelle conversation créée: ${response['id']}');
      
      return Conversation.fromJson(_mapSupabaseToConversation(response));
      
    } catch (e) {
      print('❌ [Datasource] Erreur création/récupération conversation: $e');
      throw ServerException('Erreur lors de la création de la conversation: $e');
    }
  }
}