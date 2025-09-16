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
          total_messages,
          sellers!inner(avatar_url),
          part_requests (
            vehicle_brand,
            vehicle_model,
            vehicle_year,
            vehicle_engine,
            part_type
          )
        ''')
        .eq('seller_id', sellerId)
        .eq('status', 'active')
        .order('last_message_at', ascending: false);

    print('📋 [Datasource] Reçu ${response.length} conversations vendeur');

    final conversations = <Conversation>[];
    
    for (final json in response) {
      print('📄 [Datasource] Conversion conversation vendeur: ${json['id']}');
      
      // Charger les messages pour cette conversation et calculer unreadCount localement
      final messagesResponse = await _supabaseClient
          .from('messages')
          .select('*')
          .eq('conversation_id', json['id'])
          .order('created_at', ascending: true);
      
      final messages = messagesResponse.map((msgData) {
        return Message(
          id: msgData['id'],
          conversationId: msgData['conversation_id'],
          senderId: msgData['sender_id'],
          senderType: msgData['sender_type'] == 'user' 
              ? MessageSenderType.user 
              : MessageSenderType.seller,
          content: msgData['content'],
          isRead: msgData['is_read'] ?? false,
          createdAt: DateTime.parse(msgData['created_at']),
          updatedAt: DateTime.parse(msgData['updated_at']),
        );
      }).toList();
      
      // Calculer unreadCount : messages des autres utilisateurs non lus
      print('=============== CALCUL UNREAD VENDEUR ${json['id']} ===============');
      print('👥 [Datasource-Vendeur] Seller ID: $sellerId');
      print('📨 [Datasource-Vendeur] Total messages: ${messages.length}');
      
      for (final msg in messages) {
        print('📧 [Datasource-Vendeur] Message ${msg.id}: senderId=${msg.senderId}, isRead=${msg.isRead}, content="${msg.content.length > 20 ? msg.content.substring(0, 20) + "..." : msg.content}"');
      }
      
      final unreadMessages = messages.where((msg) => !msg.isRead && msg.senderId != sellerId).toList();
      final unreadCount = unreadMessages.length;
      
      print('🔴 [Datasource-Vendeur] Messages non lus trouvés: $unreadCount');
      for (final msg in unreadMessages) {
        print('🔴   → Message: ${msg.content.length > 30 ? msg.content.substring(0, 30) + "..." : msg.content}');
      }
      print('💬 [Datasource-Vendeur] FINAL Conversation ${json['id']}: $unreadCount messages non lus');
      print('================================================================');
      
      // Récupérer les informations du particulier
      final userInfo = await _getUserInfo(json['user_id']);

      // Modifier le JSON pour inclure notre unreadCount calculé et les infos utilisateur
      final modifiedJson = Map<String, dynamic>.from(json);
      modifiedJson['unread_count'] = unreadCount;
      modifiedJson['user_info'] = userInfo;

      conversations.add(Conversation.fromJson(_mapSupabaseToConversation(modifiedJson)));
    }

    return conversations;
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
                total_messages,
                sellers!inner(avatar_url)
              ''')
              .inFilter('user_id', allUserIds)
              .order('last_message_at', ascending: false);

          print('📋 [Datasource] Reçu ${response.length} conversations pour tous les user_ids');

          final conversations = <Conversation>[];
          for (final json in response) {
            print('📄 [Datasource] Conversion conversation: ${json['id']} (user: ${json['user_id']})');
            // Récupérer les informations du vendeur
            final sellerInfo = await _getSellerInfo(json['seller_id']);
            final modifiedJson = Map<String, dynamic>.from(json);
            modifiedJson['seller_info'] = sellerInfo;
            conversations.add(Conversation.fromJson(_mapSupabaseToConversation(modifiedJson)));
          }
          return conversations;
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
            total_messages,
            sellers!inner(avatar_url)
          ''')
          .eq('user_id', userId)
          .order('last_message_at', ascending: false);

      print('📋 [Datasource] Reçu ${response.length} conversations (fallback)');

      final conversations = <Conversation>[];
      for (final json in response) {
        print('📄 [Datasource] Conversion conversation: ${json['id']}');
        // Récupérer les informations du vendeur
        final sellerInfo = await _getSellerInfo(json['seller_id']);
        final modifiedJson = Map<String, dynamic>.from(json);
        modifiedJson['seller_info'] = sellerInfo;
        conversations.add(Conversation.fromJson(_mapSupabaseToConversation(modifiedJson)));
      }
      return conversations;
      
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
            'last_message_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
            'last_message_sender_type': 'user',
            'last_message_created_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
            'updated_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
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
            'read_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
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
  Future<Map<String, dynamic>?> _getUserInfo(String userId) async {
    try {
      final response = await _supabaseClient
          .from('particuliers')
          .select('first_name, last_name, phone, avatar_url')
          .eq('id', userId)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first;
      }
    } catch (e) {
      print('⚠️ [Datasource] Erreur récupération info particulier: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getSellerInfo(String sellerId) async {
    try {
      final response = await _supabaseClient
          .from('sellers')
          .select('id, first_name, last_name, company_name, phone, avatar_url')
          .eq('id', sellerId)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first;
      }
    } catch (e) {
      print('⚠️ [Datasource] Erreur récupération info vendeur: $e');
    }
    return null;
  }

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

    // Extraire l'avatar du vendeur depuis sellers
    String? sellerAvatarUrl;
    if (json['sellers'] != null) {
      final sellers = json['sellers'];
      if (sellers is Map<String, dynamic>) {
        sellerAvatarUrl = sellers['avatar_url'];
      } else if (sellers is List && sellers.isNotEmpty) {
        sellerAvatarUrl = sellers.first['avatar_url'];
      }
    }

    // Extraire les informations complètes du vendeur depuis seller_info
    String? sellerPhone;
    if (json['seller_info'] != null) {
      final sellerInfo = json['seller_info'] as Map<String, dynamic>;
      sellerPhone = sellerInfo['phone'];

      // Mettre à jour l'avatar depuis seller_info si pas déjà récupéré
      if (sellerAvatarUrl == null) {
        sellerAvatarUrl = sellerInfo['avatar_url'];
      }
    }

    // Extraire les informations du particulier depuis user_info
    String? userName;
    String? userDisplayName;
    String? userAvatarUrl;
    if (json['user_info'] != null) {
      final userInfo = json['user_info'] as Map<String, dynamic>;
      final firstName = userInfo['first_name'];
      final lastName = userInfo['last_name'];
      final phone = userInfo['phone'];

      userName = phone; // Utiliser le téléphone comme nom d'utilisateur
      userDisplayName = (firstName != null && lastName != null)
          ? '$firstName $lastName'.trim()
          : (firstName ?? lastName ?? phone ?? 'Particulier');
      userAvatarUrl = userInfo['avatar_url'];
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
      'sellerAvatarUrl': sellerAvatarUrl,
      'sellerPhone': sellerPhone,
      'userName': userName,
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
      'requestTitle': json['request_title'],
      'lastMessageContent': json['last_message_content'],
      'lastMessageSenderType': json['last_message_sender_type'] ?? 'user', // Garder la string directement
      'lastMessageCreatedAt': json['last_message_created_at'],
      'unreadCount': json['unread_count'] ?? 0,
      'totalMessages': json['total_messages'] ?? 0,
      // Nouvelles données du véhicule
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehicleEngine': vehicleEngine,
      'partType': partType,
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