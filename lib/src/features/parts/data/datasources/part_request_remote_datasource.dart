import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/device_service.dart';
import '../models/part_request_model.dart';
import '../models/seller_rejection_model.dart';
import '../../domain/entities/part_request.dart';
import '../../domain/entities/seller_rejection.dart';
import '../../domain/entities/particulier_conversation.dart';
import '../../domain/entities/particulier_message.dart';
import '../../domain/entities/conversation_enums.dart';

abstract class PartRequestRemoteDataSource {
  Future<List<PartRequestModel>> getUserPartRequests();
  Future<PartRequestModel> createPartRequest(CreatePartRequestParams params);
  Future<PartRequestModel> getPartRequestById(String id);
  Future<PartRequestModel> updatePartRequestStatus(String id, String status);
  Future<void> deletePartRequest(String id);
  Future<bool> hasActivePartRequest();
  Future<List<Map<String, dynamic>>> getPartRequestResponses(String requestId);
  Future<List<PartRequestModel>> searchPartRequests({
    String? partType,
    String? vehicleBrand,
    String? status,
    int limit = 20,
    int offset = 0,
  });
  Future<Map<String, int>> getPartRequestStats();
  Future<List<PartRequestModel>> getActivePartRequestsForSeller();
  Future<List<PartRequestModel>> getActivePartRequestsForSellerWithRejections();
  Future<List<PartRequestModel>> getSellerOwnRequests();

  // Seller Response methods
  Future<Map<String, dynamic>> createSellerResponse({
    required String requestId,
    required String sellerId,
    required String message,
    double? price,
    String? availability,
    int? estimatedDeliveryDays,
    List<String>? attachments,
  });

  Future<Map<String, dynamic>> acceptSellerResponse(String responseId);
  Future<Map<String, dynamic>> rejectSellerResponse(String responseId);

  // Messaging methods
  Future<List<Map<String, dynamic>>> getSellerConversations(String sellerId);
  Future<Map<String, dynamic>> getConversationById(String conversationId);
  Future<List<Map<String, dynamic>>> getConversationMessages(
      String conversationId);
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderType,
    required String content,
    String messageType = 'text',
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
  });
  Future<void> markMessagesAsRead(String conversationId, String userId);

  // Seller Rejections
  Future<SellerRejection> rejectPartRequest(SellerRejection rejection);
  Future<List<SellerRejection>> getSellerRejections(String sellerId);

  // Particulier Conversations
  Future<List<ParticulierConversation>> getParticulierConversations();
  Future<ParticulierConversation> getParticulierConversationById(
      String conversationId);
  Future<void> sendParticulierMessage({
    required String conversationId,
    required String content,
  });
  Future<void> markParticulierConversationAsRead(String conversationId);
  Future<void> incrementUnreadCountForUser({required String conversationId});
  Future<void> markParticulierMessagesAsRead({required String conversationId});
}

class PartRequestRemoteDataSourceImpl implements PartRequestRemoteDataSource {
  final SupabaseClient _supabase;

  PartRequestRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<PartRequestModel>> getUserPartRequests() async {
    try {
      final currentAuthUserId = _supabase.auth.currentUser?.id;

      if (currentAuthUserId == null) {
        throw const UnauthorizedException('User not authenticated');
      }

      // Pour les vendeurs, utiliser directement l'ID auth (stratégie 2)
      // Pour les particuliers, utiliser le device_id (stratégie 1)

      try {
        // Obtenir le device_id depuis le service device (plus fiable que l'auth ID)
        final prefs = await SharedPreferences.getInstance();
        final deviceService = DeviceService(prefs);
        final deviceId = await deviceService.getDeviceId();

        // Récupérer tous les particuliers avec ce device_id
        final allParticuliersWithDevice = await _supabase
            .from('particuliers')
            .select('id')
            .eq('device_id', deviceId);

        final allUserIds =
            allParticuliersWithDevice.map((p) => p['id'] as String).toList();

        if (allUserIds.isNotEmpty) {
          // Récupérer les demandes pour TOUS ces user_id (SEULEMENT les demandes particuliers)
          final response = await _supabase
              .from('part_requests_with_responses')
              .select()
              .inFilter('user_id', allUserIds)
              .neq('status', 'deleted') // Exclure les demandes supprimées
              .eq('is_seller_request',
                  false) // SEULEMENT les demandes particuliers
              .order('created_at', ascending: false);

          final models = (response as List)
              .map((json) => PartRequestModel.fromJson(json))
              .toList();

          // Si on a trouvé des demandes particuliers, les retourner
          // Sinon, laisser continuer vers la stratégie 2 pour les demandes vendeur
          if (models.isNotEmpty) {
            return models;
          } else {
            // Ne pas retourner, laisser continuer
          }
        } else {
          // NE PAS retourner ici, laisser continuer vers la stratégie 2
        }
      } catch (particulierError) {
        // Passer à la stratégie 2
      }

      // Utiliser l'ID de l'utilisateur actuellement connecté
      final currentUserId = _supabase.auth.currentUser?.id;

      if (currentUserId == null) {
        throw ServerException('Utilisateur non connecté');
      }

      // Récupérer les demandes de l'utilisateur connecté
      final response = await _supabase
          .from('part_requests_with_responses')
          .select()
          .eq('user_id', currentUserId)
          .neq('status', 'deleted') // Exclure les demandes supprimées
          .order('created_at', ascending: false);

      final models = (response as List)
          .map((json) => PartRequestModel.fromJson(json))
          .toList();

      return models;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PartRequestModel> createPartRequest(
      CreatePartRequestParams params) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      final data = PartRequestModel.fromCreateParams(params);

      // Pour les vendeurs, utiliser directement leur ID
      // Pour les particuliers, utiliser l'ID persistant du device
      if (userId != null) {
        // Vérifier si c'est une demande vendeur
        final isSellerRequest = data['is_seller_request'] as bool? ?? false;

        if (isSellerRequest) {
          // Pour les vendeurs, utiliser directement leur ID
          data['user_id'] = userId;
        } else {
          // Pour les particuliers, chercher l'ID persistant
          try {
            final prefs = await SharedPreferences.getInstance();
            final deviceService = DeviceService(prefs);
            final deviceId = await deviceService.getDeviceId();

            final particulierPersistant = await _supabase
                .from('particuliers')
                .select('id')
                .eq('device_id', deviceId)
                .limit(1)
                .single();

            final persistantUserId = particulierPersistant['id'] as String;
            data['user_id'] = persistantUserId;
          } catch (e) {
            data['user_id'] = userId;
          }
        }
      } else {
        throw const UnauthorizedException('User not authenticated');
      }

      final response =
          await _supabase.from('part_requests').insert(data).select().single();

      return PartRequestModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PartRequestModel> getPartRequestById(String id) async {
    try {
      final response = await _supabase
          .from('part_requests_with_responses')
          .select()
          .eq('id', id)
          .single();

      return PartRequestModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PartRequestModel> updatePartRequestStatus(
      String id, String status) async {
    try {
      final response = await _supabase
          .from('part_requests')
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();

      return PartRequestModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deletePartRequest(String id) async {
    try {
      final currentAuthUser = _supabase.auth.currentUser;
      if (currentAuthUser == null) {
        throw const UnauthorizedException('User not authenticated');
      }

      // Récupérer l'ID persistant du particulier pour ce device (même logique que création)
      String? persistantUserId;
      try {
        final prefs = await SharedPreferences.getInstance();
        final deviceService = DeviceService(prefs);
        final deviceId = await deviceService.getDeviceId();

        // Rechercher le particulier persistant avec ce device_id
        final particulierPersistant = await _supabase
            .from('particuliers')
            .select('id')
            .eq('device_id', deviceId)
            .limit(1)
            .single();

        persistantUserId = particulierPersistant['id'] as String;
      } catch (e) {
        // Fallback vers l'ID auth en cas d'erreur
        persistantUserId = currentAuthUser.id;
      }

      // Au lieu de DELETE, marquer comme 'deleted' (soft delete)
      final response = await _supabase
          .from('part_requests')
          .update({'status': 'deleted'})
          .eq('id', id)
          .eq('user_id', persistantUserId)
          .select();

      if (response.isEmpty) {
        throw ServerException('Impossible de supprimer cette demande');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> hasActivePartRequest() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        // Pour les utilisateurs anonymes, vérifier par device_id
        final prefs = await SharedPreferences.getInstance();
        final deviceService = DeviceService(prefs);
        final deviceId = await deviceService.getDeviceId();

        // Récupérer les particuliers avec ce device_id
        final particuliersResponse = await _supabase
            .from('particuliers')
            .select('id')
            .eq('device_id', deviceId);

        final userIds =
            particuliersResponse.map((p) => p['id'] as String).toList();

        if (userIds.isEmpty) return false;

        // Vérifier s'il y a une demande active pour ces user_ids
        final response = await _supabase
            .from('part_requests')
            .select('id')
            .inFilter('user_id', userIds)
            .eq('status', 'active')
            .limit(1);

        return (response as List).isNotEmpty;
      } else {
        // Pour les utilisateurs authentifiés, vérifier par user_id
        final response = await _supabase
            .from('part_requests')
            .select('id')
            .eq('user_id', currentUser.id)
            .eq('status', 'active')
            .limit(1);

        return (response as List).isNotEmpty;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPartRequestResponses(
      String requestId) async {
    try {
      final response = await _supabase
          .from('seller_responses')
          .select('''
            *,
            sellers:seller_id (
              id,
              first_name,
              last_name,
              company_name,
              email,
              phone
            )
          ''')
          .eq('request_id', requestId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PartRequestModel>> searchPartRequests({
    String? partType,
    String? vehicleBrand,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('part_requests_with_responses')
          .select()
          .eq('status', status ?? 'active');

      if (partType != null) {
        query = query.eq('part_type', partType);
      }

      if (vehicleBrand != null) {
        query = query.ilike('vehicle_brand', '%$vehicleBrand%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => PartRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, int>> getPartRequestStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not authenticated');
      }

      // Récupérer toutes les demandes et compter côté client
      final allRequests = await _supabase
          .from('part_requests')
          .select('status')
          .eq('user_id', userId);

      final stats = <String, int>{
        'active': 0,
        'closed': 0,
        'fulfilled': 0,
        'total': 0,
      };

      for (final request in allRequests) {
        final status = request['status'] as String;
        if (stats.containsKey(status)) {
          stats[status] = stats[status]! + 1;
        }
        stats['total'] = stats['total']! + 1;
      }

      return stats;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PartRequestModel>> getActivePartRequestsForSeller() async {
    try {
      final response = await _supabase
          .from('part_requests_with_responses')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => PartRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createSellerResponse({
    required String requestId,
    required String sellerId,
    required String message,
    double? price,
    String? availability,
    int? estimatedDeliveryDays,
    List<String>? attachments,
  }) async {
    try {
      // D'abord créer la réponse
      final responseData = {
        'request_id': requestId,
        'seller_id': sellerId,
        'message': message,
        if (price != null) 'price': price,
        if (availability != null) 'availability': availability,
        if (estimatedDeliveryDays != null)
          'estimated_delivery_days': estimatedDeliveryDays,
        'attachments': attachments ?? [],
        'status': 'pending',
      };

      final response = await _supabase
          .from('seller_responses')
          .insert(responseData)
          .select()
          .single();

      // Ensuite créer ou récupérer la conversation
      await _createOrGetConversation(requestId, sellerId);

      return response;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> acceptSellerResponse(String responseId) async {
    try {
      final response = await _supabase
          .from('seller_responses')
          .update({'status': 'accepted'})
          .eq('id', responseId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> rejectSellerResponse(String responseId) async {
    try {
      final response = await _supabase
          .from('seller_responses')
          .update({'status': 'rejected'})
          .eq('id', responseId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSellerConversations(
      String sellerId) async {
    try {
      final conversations = await _supabase
          .from('conversations')
          .select('''
            *,
            part_requests_with_responses!inner (
              id,
              vehicle_brand,
              vehicle_model,
              part_type,
              part_names,
              created_at
            )
          ''')
          .eq('seller_id', sellerId)
          .order('last_message_at', ascending: false);

      return List<Map<String, dynamic>>.from(conversations);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getConversationById(
      String conversationId) async {
    try {
      final conversation = await _supabase.from('conversations').select('''
            *,
            part_requests_with_responses!inner (
              id,
              vehicle_brand,
              vehicle_model,
              part_type,
              part_names,
              user_id,
              created_at
            )
          ''').eq('id', conversationId).single();

      return conversation;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getConversationMessages(
      String conversationId) async {
    try {
      final messages = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(messages);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderType,
    required String content,
    String messageType = 'text',
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
  }) async {
    try {
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_type': senderType,
        'content': content,
        'message_type': messageType,
        if (offerPrice != null) 'offer_price': offerPrice,
        if (offerAvailability != null) 'offer_availability': offerAvailability,
        if (offerDeliveryDays != null) 'offer_delivery_days': offerDeliveryDays,
        'attachments': <String>[],
      };

      final message = await _supabase
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      return message;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Helper method to create or get conversation
  Future<String> _createOrGetConversation(
      String requestId, String sellerId) async {
    try {
      // Récupérer le client_id depuis la part_request (utiliser la vue pour avoir toutes les demandes)
      final partRequest = await _supabase
          .from('part_requests_with_responses')
          .select('user_id')
          .eq('id', requestId)
          .single();

      final clientId = partRequest['user_id'];

      // Vérifier si une conversation existe déjà
      final existingConversations = await _supabase
          .from('conversations')
          .select('id')
          .eq('request_id', requestId)
          .eq('seller_id', sellerId);

      if (existingConversations.isNotEmpty) {
        return existingConversations.first['id'];
      }

      // Créer une nouvelle conversation
      final conversationData = {
        'request_id': requestId,
        'seller_id': sellerId,
        'client_id': clientId,
        'status': 'active',
      };

      final conversation = await _supabase
          .from('conversations')
          .insert(conversationData)
          .select('id')
          .single();

      return conversation['id'];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SellerRejection> rejectPartRequest(SellerRejection rejection) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      final rejectionModel = SellerRejectionModel.fromEntity(rejection);
      final insertData = rejectionModel.toInsertJson();

      // S'assurer que seller_id correspond à l'utilisateur connecté
      insertData['seller_id'] = currentUser.id;

      final result = await _supabase
          .from('seller_rejections')
          .insert(insertData)
          .select()
          .single();

      final savedRejection = SellerRejectionModel.fromJson(result).toEntity();

      return savedRejection;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<SellerRejection>> getSellerRejections(String sellerId) async {
    try {
      final result = await _supabase
          .from('seller_rejections')
          .select()
          .eq('seller_id', sellerId)
          .order('rejected_at', ascending: false);

      final rejections = result
          .map((json) => SellerRejectionModel.fromJson(json).toEntity())
          .toList();

      return rejections;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PartRequestModel>>
      getActivePartRequestsForSellerWithRejections() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Utiliser part_requests_with_responses pour avoir toutes les données du véhicule
      final result = await _supabase
          .from('part_requests_with_responses')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      // Récupérer les refus de ce vendeur pour filtrer
      final rejections = await _supabase
          .from('seller_rejections')
          .select('part_request_id')
          .eq('seller_id', currentUser.id);

      final rejectedIds =
          rejections.map((r) => r['part_request_id'] as String).toSet();

      // Récupérer les conversations de ce vendeur pour filtrer les demandes déjà contactées
      final conversations = await _supabase
          .from('conversations')
          .select('request_id')
          .eq('seller_id', currentUser.id);

      final contactedIds =
          conversations.map((c) => c['request_id'] as String).toSet();

      // Filtrer les demandes pour exclure celles refusées, contactées ET ses propres demandes
      final filteredResult = result.where((json) {
        final requestId = json['id'] as String;
        final requestUserId = json['user_id'] as String?;

        // Exclure si refusée, déjà contactée, ou si c'est sa propre demande
        return !rejectedIds.contains(requestId) &&
            !contactedIds.contains(requestId) &&
            requestUserId != currentUser.id;
      }).toList();

      final models = filteredResult.map((json) {
        return PartRequestModel.fromJson(json);
      }).toList();

      return models;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PartRequestModel>> getSellerOwnRequests() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Récupérer les demandes du vendeur actuel (ses propres demandes)
      final result = await _supabase
          .from('part_requests_with_responses')
          .select()
          .eq('user_id', currentUser.id)
          .eq('is_seller_request', true)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      final models = result.map((json) {
        return PartRequestModel.fromJson(json);
      }).toList();

      return models;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Particulier Conversations
  @override
  Future<List<ParticulierConversation>> getParticulierConversations() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Récupérer l'ID persistant du particulier comme dans getUserPartRequests
      List<String> allUserIds = [];

      try {
        final prefs = await SharedPreferences.getInstance();
        final deviceService = DeviceService(prefs);
        final deviceId = await deviceService.getDeviceId();

        // Récupérer tous les particuliers avec ce device_id
        final allParticuliersWithDevice = await _supabase
            .from('particuliers')
            .select('id')
            .eq('device_id', deviceId);

        allUserIds =
            allParticuliersWithDevice.map((p) => p['id'] as String).toList();

        if (allUserIds.isEmpty) {
          allUserIds = [currentUser.id];
        }
      } catch (e) {
        allUserIds = [currentUser.id];
      }

      final conversations = await _supabase
          .from('conversations')
          .select('''
            *,
            part_requests!inner(
              id,
              part_type,
              part_names,
              vehicle_brand,
              vehicle_model,
              vehicle_year,
              vehicle_plate,
              created_at,
              updated_at
            ),
            sellers!inner(
              id,
              first_name,
              last_name,
              company_name,
              avatar_url
            )
          ''')
          .inFilter('user_id', allUserIds)
          .order('last_message_at', ascending: false);

      List<ParticulierConversation> result = [];

      for (final convData in conversations) {
        try {
          // Récupérer les messages de cette conversation
          final messagesData = await _supabase
              .from('messages')
              .select('*')
              .eq('conversation_id', convData['id'])
              .order('created_at', ascending: true);

          // Convertir les messages
          final messages = messagesData.map<ParticulierMessage>((msgData) {
            return ParticulierMessage(
              id: msgData['id'],
              conversationId: msgData['conversation_id'],
              senderId: msgData['sender_id'],
              senderName: msgData['sender_name'] ?? 'Utilisateur',
              content: msgData['content'],
              type: MessageType.values.firstWhere(
                (type) => type.name == (msgData['message_type'] ?? 'text'),
                orElse: () => MessageType.text,
              ),
              isFromParticulier: msgData['sender_type'] == 'user',
              isRead: msgData['is_read'] ?? false,
              createdAt: DateTime.parse(msgData['created_at']),
              offerPrice: msgData['offer_price']?.toDouble(),
              offerDeliveryDays: msgData['offer_delivery_days'],
              offerAvailability: msgData['offer_availability'],
            );
          }).toList();

          // Récupérer les infos du vendeur
          final sellerData = convData['sellers'];

          final sellerName = sellerData != null
              ? '${sellerData['first_name'] ?? ''} ${sellerData['last_name'] ?? ''}'
                  .trim()
              : 'Vendeur inconnu';
          final sellerCompanyName = sellerData?['company_name'];
          final sellerAvatarUrl = sellerData?['avatar_url'];

          // Récupérer les infos de la demande de pièce
          final partRequestData = convData['part_requests'];
          final partRequest = PartRequest(
            id: partRequestData['id'],
            partType: partRequestData['part_type'] ?? 'unknown',
            partNames: List<String>.from(partRequestData['part_names'] ?? []),
            vehicleBrand: partRequestData['vehicle_brand'],
            vehicleModel: partRequestData['vehicle_model'],
            vehicleYear: partRequestData['vehicle_year'],
            vehiclePlate: partRequestData['vehicle_plate'],
            createdAt: DateTime.parse(partRequestData['created_at']),
            updatedAt: DateTime.parse(partRequestData['updated_at']),
          );

          // Créer la conversation
          final conversation = ParticulierConversation(
            id: convData['id'],
            partRequest: partRequest,
            sellerName: sellerName,
            sellerId: convData['seller_id'],
            messages: messages,
            lastMessageAt: messages.isNotEmpty
                ? messages.last.createdAt
                : DateTime.parse(convData['created_at']),
            status: ConversationStatus.values.firstWhere(
              (status) => status.name == (convData['status'] ?? 'pending'),
              orElse: () => ConversationStatus.active,
            ),
            hasUnreadMessages: () {
              final dbUnreadCount =
                  convData['unread_count_for_user'] as int? ?? 0;
              return dbUnreadCount > 0;
            }(),
            unreadCount: () {
              final dbUnreadCount =
                  convData['unread_count_for_user'] as int? ?? 0;
              return dbUnreadCount;
            }(),
            vehiclePlate: partRequestData['vehicle_plate'],
            partType: partRequestData['part_type'],
            partNames: List<String>.from(partRequestData['part_names'] ?? []),
            createdAt: DateTime.parse(convData['created_at']),
            updatedAt: DateTime.parse(convData['updated_at']),
            sellerCompany: sellerCompanyName,
            sellerAvatarUrl: sellerAvatarUrl,
          );

          result.add(conversation);
        } catch (e) {
          // Continue avec les autres conversations
        }
      }

      return result;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ParticulierConversation> getParticulierConversationById(
      String conversationId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // TODO: Implémenter la récupération de la conversation depuis Supabase
      // Pour l'instant, créer une conversation factice
      return ParticulierConversation(
        id: conversationId,
        partRequest: PartRequest(
          id: 'dummy-part-request',
          partType: 'engine',
          partNames: ['dummy part'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        sellerName: 'Vendeur Test',
        sellerId: 'seller-id',
        messages: [],
        lastMessageAt: DateTime.now(),
        status: ConversationStatus.active,
        vehiclePlate: 'AA-123-BB',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sellerCompany: 'Entreprise Test',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendParticulierMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Préparer les données du message
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': currentUser.id,
        'sender_type':
            'user', // Le particulier envoie toujours en tant que 'user'
        'content': content,
        'message_type': 'text',
        'is_read': false, // Message non lu par défaut
        // Supabase génère automatiquement created_at et updated_at en UTC
      };

      // Insérer le message dans la table messages
      final response = await _supabase
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      // Mettre à jour la conversation avec le dernier message et incrémenter le compteur pour le vendeur
      await _supabase.from('conversations').update({
        'last_message_content': content,
        'last_message_sender_type': 'user',
        'last_message_created_at': response['created_at'],
        'updated_at': 'now()',
        'unread_count_for_seller': 'unread_count_for_seller + 1',
      }).eq('id', conversationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markParticulierConversationAsRead(String conversationId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Vérifier si l'utilisateur actuel est un vendeur
      final isSeller = await _checkIfUserIsSeller(currentUser.id);

      Map<String, dynamic> updateData = {};

      if (isSeller) {
        // Si c'est un vendeur qui lit, reset unread_count_for_seller
        updateData['unread_count_for_seller'] = 0;
      } else {
        // Si c'est un particulier qui lit, reset unread_count_for_user
        updateData['unread_count_for_user'] = 0;
      }

      await _supabase
          .from('conversations')
          .update(updateData)
          .eq('id', conversationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> incrementUnreadCountForUser(
      {required String conversationId}) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Incrémenter le compteur côté particulier (unread_count_for_user)
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markParticulierMessagesAsRead(
      {required String conversationId}) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      final userId = currentUser.id;

      // Récupérer les infos de la conversation et de la demande pour déterminer le rôle
      final conversation = await _supabase
          .from('conversations')
          .select('user_id, seller_id, request_id')
          .eq('id', conversationId)
          .single();

      final clientId = conversation['user_id'];
      final sellerId = conversation['seller_id'];
      final requestId = conversation['request_id'];

      // Déterminer qui est le "particulier" (demandeur) et qui est le "vendeur" (répondeur)
      String particulierId = clientId;
      String vendeurId = sellerId;

      // Pour les conversations vendeur-vendeur, le "particulier" est celui qui a fait la demande
      if (requestId != null) {
        try {
          // Récupérer l'auteur de la demande depuis part_requests
          final partRequest = await _supabase
              .from('part_requests')
              .select('user_id')
              .eq('id', requestId)
              .single();

          final requestAuthorId = partRequest['user_id'];

          // L'auteur de la demande agit comme "particulier", l'autre comme "vendeur"
          particulierId = requestAuthorId;
          vendeurId = (requestAuthorId == clientId) ? sellerId : clientId;
        } catch (e) {
          // Garder les rôles par défaut si erreur récupération part_request
        }
      }

      bool isUserTheParticulier = (particulierId == userId);
      bool isUserTheVendeur = (vendeurId == userId);

      if (isUserTheParticulier) {
        // L'utilisateur est le particulier → marquer les messages du vendeur comme lus
        await _supabase
            .from('messages')
            .update({
              'is_read': true,
              'read_at': 'now()',
            })
            .eq('conversation_id', conversationId)
            .neq('sender_id', userId) // Messages des autres (pas de lui)
            .eq('is_read', false);
      } else if (isUserTheVendeur) {
        // L'utilisateur est le vendeur → marquer les messages du particulier comme lus
        await _supabase
            .from('messages')
            .update({
              'is_read': true,
              'read_at': 'now()',
            })
            .eq('conversation_id', conversationId)
            .neq('sender_id', userId) // Messages des autres (pas de lui)
            .eq('is_read', false);
      }

      // Reset du compteur côté particulier (garde la logique existante)
      try {
        await markParticulierConversationAsRead(conversationId);
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<bool> _checkIfUserIsSeller(String userId) async {
    try {
      final sellerResponse = await _supabase
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
}
