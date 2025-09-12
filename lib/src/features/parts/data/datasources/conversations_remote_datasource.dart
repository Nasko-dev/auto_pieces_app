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
  });
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
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
          total_messages
        ''')
        .eq('seller_id', sellerId)
        .eq('status', 'active')
        .order('last_message_at', ascending: false);

    print('📋 [Datasource] Reçu ${response.length} conversations vendeur');

    return response.map((json) {
      print('📄 [Datasource] Conversion conversation vendeur: ${json['id']}');
      return Conversation.fromJson(_mapSupabaseToConversation(json));
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
  }) async {
    print('📤 [Datasource] Envoi message: $content');
    
    try {
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_type': 'user', // Toujours user côté particulier
        'content': content,
        'message_type': messageType.toString().split('.').last,
        'offer_price': offerPrice,
        'offer_availability': offerAvailability,
        'offer_delivery_days': offerDeliveryDays,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      print('✅ [Datasource] Message envoyé avec succès');
      
      // Mettre à jour la conversation
      await _updateConversationLastMessage(conversationId, content);

      return Message.fromJson(_mapSupabaseToMessage(response));
      
    } catch (e) {
      print('❌ [Datasource] Erreur envoi message: $e');
      throw ServerException('Erreur lors de l\'envoi du message: $e');
    }
  }

  Future<void> _updateConversationLastMessage(String conversationId, String content) async {
    try {
      await _supabaseClient
          .from('conversations')
          .update({
            'last_message_content': content,
            'last_message_at': DateTime.now().toIso8601String(),
            'last_message_sender_type': 'user',
            'last_message_created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationId);
      
      print('✅ [Datasource] Conversation mise à jour');
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
      // Marquer les messages comme lus (seulement ceux du vendeur)
      await _supabaseClient
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('conversation_id', conversationId)
          .eq('sender_type', 'seller')
          .eq('is_read', false);

      // Mettre à jour le compteur de la conversation
      await _supabaseClient
          .from('conversations')
          .update({'unread_count': 0})
          .eq('id', conversationId);

      print('✅ [Datasource] Messages marqués comme lus');
      
    } catch (e) {
      print('❌ [Datasource] Erreur marquage lecture: $e');
      throw ServerException('Erreur lors du marquage des messages comme lus: $e');
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
            'updated_at': DateTime.now().toIso8601String(),
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
      'unreadCount': json['unread_count'] ?? 0,
      'totalMessages': json['total_messages'] ?? 0,
    };
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
        'last_message_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
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