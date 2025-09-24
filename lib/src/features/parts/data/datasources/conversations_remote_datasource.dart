import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation_enums.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/services/send_notification_service.dart';

abstract class ConversationsRemoteDataSource {
  Future<List<Conversation>> getConversations({required String userId});
  Future<List<Message>> getConversationMessages({required String conversationId});
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType messageType = MessageType.text,
    List<String> attachments = const [],
    Map<String, dynamic> metadata = const {},
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
    
    try {
      // Détecter si c'est un vendeur ou un particulier
      final isSellerResult = await _checkIfUserIsSeller(userId);
      
      if (isSellerResult) {
        return _getSellerConversations(userId);
      } else {
        return _getParticulierConversations(userId);
      }
      
    } catch (e) {
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
      return isSeller;
    } catch (e) {
      return false;
    }
  }

  Future<List<Conversation>> _getSellerConversations(String sellerId) async {

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


    final conversations = <Conversation>[];
    
    for (final json in response) {
      
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
      
      final unreadMessages = messages.where((msg) => !msg.isRead && msg.senderId != sellerId).toList();
      final unreadCount = unreadMessages.length;
      
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
    
    try {
      // Utiliser la même logique que les part_requests : récupérer par device_id
      
      try {
        // Obtenir le device_id depuis le service device (plus fiable que l'auth ID)
        final prefs = await SharedPreferences.getInstance();
        final deviceService = DeviceService(prefs);
        final deviceId = await deviceService.getDeviceId();
        
        // Récupérer tous les particuliers avec ce device_id
        final allParticuliersWithDevice = await _supabaseClient
            .from('particuliers')
            .select('id')
            .eq('device_id', deviceId);
            
        final allUserIds = allParticuliersWithDevice
            .map((p) => p['id'] as String)
            .toList();
            
        
        if (allUserIds.isNotEmpty) {
          // Récupérer les conversations pour TOUS ces user_id
          
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


          final conversations = <Conversation>[];
          for (final json in response) {
            // Récupérer les informations du vendeur
            final sellerInfo = await _getSellerInfo(json['seller_id']);
            final modifiedJson = Map<String, dynamic>.from(json);
            modifiedJson['seller_info'] = sellerInfo;
            conversations.add(Conversation.fromJson(_mapSupabaseToConversation(modifiedJson)));
          }
          return conversations;
        } else {
        }
        
      } catch (particulierError) {
      // Ignorer l'erreur silencieusement
      }
      
      
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


      final conversations = <Conversation>[];
      for (final json in response) {
        // Récupérer les informations du vendeur
        final sellerInfo = await _getSellerInfo(json['seller_id']);
        final modifiedJson = Map<String, dynamic>.from(json);
        modifiedJson['seller_info'] = sellerInfo;
        conversations.add(Conversation.fromJson(_mapSupabaseToConversation(modifiedJson)));
      }
      return conversations;
      
    } catch (e) {
      throw ServerException('Erreur lors de la récupération des conversations: $e');
    }
  }

  @override
  Future<List<Message>> getConversationMessages({required String conversationId}) async {
    
    try {
      final response = await _supabaseClient
          .from('messages')
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);


      return response.map((json) {
        return Message.fromJson(_mapSupabaseToMessage(json));
      }).toList();
      
    } catch (e) {
      throw ServerException('Erreur lors de la récupération des messages: $e');
    }
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType messageType = MessageType.text,
    List<String> attachments = const [],
    Map<String, dynamic> metadata = const {},
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
    MessageSenderType? senderType,
  }) async {

    try {
      debugPrint('🔍 DEBUG SEND MESSAGE - Début');
      debugPrint('💬 conversationId: $conversationId');
      debugPrint('👤 senderId: $senderId');
      debugPrint('📝 content: $content');

      // Déterminer automatiquement le sender_type si pas fourni
      String senderTypeString;
      if (senderType != null) {
        senderTypeString = senderType == MessageSenderType.user ? 'user' : 'seller';
      } else {
        // Auto-détection : vérifier si l'expéditeur est dans la table sellers
        senderTypeString = await _determineSenderType(senderId);
      }

      debugPrint('🏷️ senderTypeString: $senderTypeString');

      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_type': senderTypeString,
        'content': content,
        'message_type': messageType.toString().split('.').last,
        'attachments': attachments,
        'metadata': metadata,
        'offer_price': offerPrice,
        'offer_availability': offerAvailability,
        'offer_delivery_days': offerDeliveryDays,
        // Laisser Supabase générer les timestamps (UTC) pour éviter les problèmes de fuseau horaire
        // 'created_at' et 'updated_at' seront générés automatiquement par Supabase
      };

      debugPrint('📦 messageData: $messageData');

      final response = await _supabaseClient
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      debugPrint('✅ Message inséré avec succès: ${response['id']}');
      debugPrint('🕒 created_at: ${response['created_at']}');

      // Mettre à jour la conversation avec le bon sender type
      await _updateConversationLastMessage(conversationId, content, senderTypeString);

      // ✅ NOUVEAU: Avec trigger intelligent, plus besoin de reset manuel
      // Le trigger DB gère automatiquement les bons compteurs selon sender_type

      // Envoyer une notification au destinataire
      await _sendMessageNotification(conversationId, senderId, content, senderTypeString);

      debugPrint('🚀 DEBUG SEND MESSAGE - Fin avec succès');
      return Message.fromJson(_mapSupabaseToMessage(response));

    } catch (e) {
      debugPrint('❌ DEBUG SEND MESSAGE - Erreur: $e');
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

    } catch (e) {
      // Ignorer l'erreur silencieusement
    }
  }

  @override
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {

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


    } catch (e) {
      throw ServerException('Erreur lors du marquage des messages comme lus: $e');
    }
  }

  @override
  Future<void> incrementUnreadCount({
    required String conversationId,
  }) async {

    try {
      // Utiliser une requête SQL pour incrémenter atomiquement
      await _supabaseClient.rpc('increment_unread_count', params: {
        'conversation_id_param': conversationId,
      });


    } catch (e) {
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

      } catch (fallbackError) {
        throw ServerException('Erreur lors de l\'incrémentation du compteur: $fallbackError');
      }
    }
  }

  @override
  Future<void> incrementUnreadCountForUser({
    required String conversationId,
  }) async {

    try {
      // Utiliser rpc pour les incrémentations atomiques
      await _supabaseClient.rpc('increment_unread_count_for_user', params: {
        'conversation_id_param': conversationId,
      });

    } catch (e) {
      // Fallback : récupérer et incrémenter manuellement
      try {
        final response = await _supabaseClient
            .from('conversations')
            .select('unread_count_for_user')
            .eq('id', conversationId)
            .single();

        final currentCount = (response['unread_count_for_user'] as int?) ?? 0;

        await _supabaseClient
            .from('conversations')
            .update({'unread_count_for_user': currentCount + 1})
            .eq('id', conversationId);

      } catch (fallbackError) {
        throw ServerException('Erreur lors de l\'incrémentation du compteur particulier: $fallbackError');
      }
    }
  }

  @override
  Future<void> incrementUnreadCountForSeller({
    required String conversationId,
  }) async {

    try {
      // Utiliser rpc pour les incrémentations atomiques
      await _supabaseClient.rpc('increment_unread_count_for_seller', params: {
        'conversation_id_param': conversationId,
      });

    } catch (e) {
      // Fallback : récupérer et incrémenter manuellement
      try {
        final response = await _supabaseClient
            .from('conversations')
            .select('unread_count_for_seller')
            .eq('id', conversationId)
            .single();

        final currentCount = (response['unread_count_for_seller'] as int?) ?? 0;

        await _supabaseClient
            .from('conversations')
            .update({'unread_count_for_seller': currentCount + 1})
            .eq('id', conversationId);

      } catch (fallbackError) {
        throw ServerException('Erreur lors de l\'incrémentation du compteur vendeur: $fallbackError');
      }
    }
  }

  @override
  Future<void> updateConversationStatus({
    required String conversationId,
    required ConversationStatus status,
  }) async {
    
    try {
      await _supabaseClient
          .from('conversations')
          .update({
            'status': _conversationStatusToString(status),
            'updated_at': 'now()',  // Utiliser la fonction Supabase pour timestamp UTC
          })
          .eq('id', conversationId);

      
    } catch (e) {
      throw ServerException('Erreur lors de la mise à jour du statut: $e');
    }
  }

  @override
  Future<void> deleteConversation({required String conversationId}) async {
    
    try {
      await updateConversationStatus(
        conversationId: conversationId,
        status: ConversationStatus.deletedByUser,
      );
      
    } catch (e) {
      throw ServerException('Erreur lors de la suppression de la conversation: $e');
    }
  }

  @override
  Future<void> blockConversation({required String conversationId}) async {
    
    try {
      await updateConversationStatus(
        conversationId: conversationId,
        status: ConversationStatus.blockedByUser,
      );
      
    } catch (e) {
      throw ServerException('Erreur lors du blocage de la conversation: $e');
    }
  }

  @override
  Stream<Message> subscribeToNewMessages({required String conversationId}) {
    
    return _supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .map((data) {
          return Message.fromJson(_mapSupabaseToMessage(data.last));
        });
  }

  @override
  Stream<Conversation> subscribeToConversationUpdates({required String userId}) {
    
    // Utiliser la même logique que getConversations pour trouver les vrais user_ids
    return Stream.fromFuture(_getAllUserIdsForDevice()).asyncExpand((userIds) {
      if (userIds.isEmpty) {
        return _supabaseClient
            .from('conversations')
            .stream(primaryKey: ['id'])
            .eq('user_id', userId)
            .where((data) => data.isNotEmpty)
            .map((data) {
              return Conversation.fromJson(_mapSupabaseToConversation(data.last));
            });
      }
      
      return _supabaseClient
          .from('conversations')
          .stream(primaryKey: ['id'])
          .inFilter('user_id', userIds)
          .where((data) => data.isNotEmpty)
          .map((data) {
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
          
      return allUserIds;
    } catch (e) {
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
      // Ignorer l'erreur silencieusement
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getSellerInfo(String sellerId) async {
    try {
      // Récupérer toutes les infos du vendeur incluant les paramètres professionnels
      final response = await _supabaseClient
          .from('sellers')
          .select('id, first_name, last_name, company_name, phone, avatar_url, address, city')
          .eq('id', sellerId)
          .limit(1);

      if (response.isNotEmpty) {
        final sellerData = response.first;
        return sellerData;
      }
    } catch (e) {
      // Ignorer l'erreur silencieusement
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
      sellerAvatarUrl ??= sellerInfo['avatar_url'];
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
      'unreadCount': json['unread_count'] ?? 0, // ⚠️ Ancien champ, à supprimer plus tard
      'totalMessages': json['total_messages'] ?? 0,
      // Nouvelles données du véhicule
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehicleEngine': vehicleEngine,
      'partType': partType,
      // Nom du particulier
      'particulierFirstName': userDisplayName,
    };
  }

  // ✅ NOUVEAU: Mapping spécifique vendeur

  // ✅ NOUVEAU: Mapping spécifique particulier

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



  Future<String> _determineSenderType(String senderId) async {
    try {
      // Vérifier si l'ID est dans la table sellers
      final sellerCheck = await _supabaseClient
          .from('sellers')
          .select('id')
          .eq('id', senderId)
          .limit(1);

      if (sellerCheck.isNotEmpty) {
        return 'seller';
      } else {
        return 'user';
      }
    } catch (e) {
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
        return Conversation.fromJson(_mapSupabaseToConversation(existingConversations.first));
      }

      // 2. Créer une nouvelle conversation pour cette demande
      
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

      
      return Conversation.fromJson(_mapSupabaseToConversation(response));
      
    } catch (e) {
      throw ServerException('Erreur lors de la création de la conversation: $e');
    }
  }

  /// Envoie une notification de nouveau message
  Future<void> _sendMessageNotification(
    String conversationId,
    String senderId,
    String content,
    String senderType,
  ) async {
    try {
      debugPrint('📤 Envoi notification de message...');

      // Récupérer les infos de la conversation pour connaître les participants
      final conversationResponse = await _supabaseClient
        .from('conversations')
        .select('user_id, seller_id')
        .eq('id', conversationId)
        .single();

      final userId = conversationResponse['user_id'] as String;
      final sellerId = conversationResponse['seller_id'] as String;

      // Déterminer qui est le destinataire (pas l'expéditeur)
      // IMPORTANT: Pour les particuliers, leur User ID peut changer à cause de l'auth anonyme
      // On doit vérifier par le senderType plutôt que par l'User ID exact
      String recipientId;
      if (senderType == 'user') {
        // L'expéditeur est un particulier → destinataire = seller
        recipientId = sellerId;
      } else {
        // L'expéditeur est un seller → destinataire = user (particulier)
        recipientId = userId;
      }

      // Récupérer le nom de l'expéditeur
      String senderName = 'Un utilisateur';
      if (senderType == 'seller') {
        // L'expéditeur est un vendeur
        final sellerInfo = await _getSellerInfo(senderId);
        if (sellerInfo != null) {
          final firstName = sellerInfo['first_name'] ?? '';
          final lastName = sellerInfo['last_name'] ?? '';
          final companyName = sellerInfo['company_name'] ?? '';

          if (companyName.isNotEmpty) {
            senderName = companyName;
          } else if (firstName.isNotEmpty || lastName.isNotEmpty) {
            senderName = '$firstName $lastName'.trim();
          }
        }
      } else {
        // L'expéditeur est un particulier - utiliser device_id pour récupérer les infos
        try {
          final prefs = await SharedPreferences.getInstance();
          final deviceService = DeviceService(prefs);
          final currentDeviceId = await deviceService.getDeviceId();

          // Récupérer les infos du particulier par device_id
          final userInfo = await _supabaseClient
            .from('particuliers')
            .select('first_name, last_name')
            .eq('device_id', currentDeviceId)
            .maybeSingle();

          if (userInfo != null) {
            final firstName = userInfo['first_name'] ?? '';
            final lastName = userInfo['last_name'] ?? '';

            if (firstName.isNotEmpty || lastName.isNotEmpty) {
              senderName = '$firstName $lastName'.trim();
            } else {
              senderName = 'Particulier';
            }
          } else {
            senderName = 'Particulier';
          }
        } catch (e) {
          senderName = 'Particulier';
        }
      }

      // Tronquer le message si trop long
      String messagePreview = content;
      if (messagePreview.length > 50) {
        messagePreview = '${messagePreview.substring(0, 50)}...';
      }

      debugPrint('📤 Notification: $senderName → $recipientId');
      debugPrint('📝 Message: $messagePreview');
      debugPrint('🎯 Sender: $senderId ($senderType)');
      debugPrint('🎯 Recipient User ID: $recipientId');

      // Envoyer la notification - Utiliser device_id pour TOUS les particuliers
      final notificationService = SendNotificationService.instance;

      // Déterminer si le destinataire est un particulier ou un seller
      // Les sellers ont un User ID dans la table 'sellers'
      final sellerCheck = await _supabaseClient
        .from('sellers')
        .select('id')
        .eq('id', recipientId)
        .maybeSingle();

      if (sellerCheck != null) {
        // C'est un seller - envoyer par user_id classique
        debugPrint('📤 Seller détecté, envoi par user_id');
        await notificationService.sendMessageNotification(
          toUserId: recipientId,
          fromUserName: senderName,
          messagePreview: messagePreview,
          conversationId: conversationId,
        );
      } else {
        // C'est un particulier - TOUJOURS envoyer par device_id
        debugPrint('👤 Particulier détecté, recherche device_id...');

        // Récupérer le device_id du destinataire particulier
        // Pour cela, on recherche dans la table particuliers par user_id
        debugPrint('🔍 Recherche device_id du destinataire $recipientId...');

        try {
          // Récupérer le device_id du destinataire depuis particuliers
          final particulierInfo = await _supabaseClient
            .from('particuliers')
            .select('device_id')
            .eq('id', recipientId)
            .maybeSingle();

          if (particulierInfo != null && particulierInfo['device_id'] != null) {
            final deviceId = particulierInfo['device_id'] as String;
            debugPrint('✅ Device_id trouvé: $deviceId');

            await notificationService.sendMessageNotificationByDeviceId(
              deviceId: deviceId,
              fromUserName: senderName,
              messagePreview: messagePreview,
              conversationId: conversationId,
            );
          } else {
            debugPrint('⚠️ Aucun device_id trouvé pour ce particulier');
            throw Exception('Device ID non trouvé');
          }
        } catch (e) {
          debugPrint('❌ Erreur récupération device_id: $e');
          // Fallback vers user_id si problème avec device_id
          await notificationService.sendMessageNotification(
            toUserId: recipientId,
            fromUserName: senderName,
            messagePreview: messagePreview,
            conversationId: conversationId,
          );
        }
      }

      debugPrint('✅ Notification envoyée avec succès');
    } catch (e) {
      debugPrint('⚠️ Erreur envoi notification: $e');
      // Ne pas faire échouer l'envoi du message si la notification échoue
    }
  }
}