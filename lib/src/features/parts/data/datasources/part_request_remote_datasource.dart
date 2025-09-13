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
  Future<List<Map<String, dynamic>>> getConversationMessages(String conversationId);
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
  Future<ParticulierConversation> getParticulierConversationById(String conversationId);
  Future<void> sendParticulierMessage({
    required String conversationId,
    required String content,
  });
  Future<void> markParticulierConversationAsRead(String conversationId);
}

class PartRequestRemoteDataSourceImpl implements PartRequestRemoteDataSource {
  final SupabaseClient _supabase;

  PartRequestRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<PartRequestModel>> getUserPartRequests() async {
    try {
      print('🔐 [DataSource] Vérification auth utilisateur');
      final currentAuthUserId = _supabase.auth.currentUser?.id;
      
      if (currentAuthUserId == null) {
        print('❌ [DataSource] Utilisateur non authentifié');
        throw const UnauthorizedException('User not authenticated');
      }
      
      print('✅ [DataSource] Utilisateur authentifié: $currentAuthUserId');
      
      // D'abord, récupérer le device_id depuis le cache local ou service
      print('🔍 [DataSource] Recherche du particulier persistant...');
      
      try {
        // Obtenir le device_id depuis le service device (plus fiable que l'auth ID)
        final prefs = await SharedPreferences.getInstance();
        final deviceService = DeviceService(prefs);
        final deviceId = await deviceService.getDeviceId();
        print('📱 [DataSource] Device ID obtenu: $deviceId');
        
        // Récupérer tous les particuliers avec ce device_id
        final allParticuliersWithDevice = await _supabase
            .from('particuliers')
            .select('id')
            .eq('device_id', deviceId);
            
        final allUserIds = allParticuliersWithDevice
            .map((p) => p['id'] as String)
            .toList();
            
        print('🆔 [DataSource] IDs utilisateur trouvés pour ce device: $allUserIds');
        
        if (allUserIds.isNotEmpty) {
          // Récupérer les demandes pour TOUS ces user_id
          print('📡 [DataSource] Requête vers part_requests_with_responses pour tous les IDs');
          
          final response = await _supabase
              .from('part_requests_with_responses')
              .select()
              .inFilter('user_id', allUserIds)
              .order('created_at', ascending: false);
              
          print('📦 [DataSource] Réponse reçue: ${response.length} éléments');
          print('🗂️ [DataSource] Données brutes: $response');

          final models = (response as List)
              .map((json) => PartRequestModel.fromJson(json))
              .toList();
              
          print('✅ [DataSource] ${models.length} demandes converties en modèles');
          
          return models;
        } else {
          print('⚠️ [DataSource] Aucun utilisateur trouvé pour ce device_id');
        }
        
      } catch (particulierError) {
        print('⚠️ [DataSource] Erreur recherche particulier: $particulierError');
      }
      
      print('🔄 [DataSource] Fallback: recherche directe par auth ID');
      
      // Fallback : recherche directe par l'auth ID actuel
      final response = await _supabase
          .from('part_requests_with_responses')
          .select()
          .eq('user_id', currentAuthUserId)
          .order('created_at', ascending: false);

      print('📦 [DataSource] Réponse fallback reçue: ${response.length} éléments');

      final models = (response as List)
          .map((json) => PartRequestModel.fromJson(json))
          .toList();
          
      print('✅ [DataSource] ${models.length} demandes converties (fallback)');
      
      return models;
      
    } catch (e) {
      print('💥 [DataSource] Erreur: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PartRequestModel> createPartRequest(CreatePartRequestParams params) async {
    try {
      print('🔐 [DataSource] Vérification auth pour création');
      final userId = _supabase.auth.currentUser?.id;
      
      print('📋 [DataSource] Conversion des paramètres');
      final data = PartRequestModel.fromCreateParams(params);
      print('🗂️ [DataSource] Données à insérer: $data');
      
      // Récupérer l'ID persistant du particulier pour ce device
      if (userId != null) {
        try {
          // Obtenir le device_id pour ce user
          final prefs = await SharedPreferences.getInstance();
          final deviceService = DeviceService(prefs);
          final deviceId = await deviceService.getDeviceId();
          print('📱 [DataSource] Device ID pour création: $deviceId');
          
          // Rechercher le particulier persistant avec ce device_id
          final particulierPersistant = await _supabase
              .from('particuliers')
              .select('id')
              .eq('device_id', deviceId)
              .limit(1)
              .single();
              
          final persistantUserId = particulierPersistant['id'] as String;
          data['user_id'] = persistantUserId;
          print('👤 [DataSource] user_id persistant utilisé: $persistantUserId (au lieu de $userId)');
          
        } catch (e) {
          print('⚠️ [DataSource] Erreur récupération ID persistant: $e');
          print('🔄 [DataSource] Fallback: utilisation auth_id');
          data['user_id'] = userId;
          print('👤 [DataSource] user_id auth ajouté en fallback: $userId');
        }
      } else {
        print('❌ [DataSource] Aucun utilisateur authentifié');
        throw const UnauthorizedException('User not authenticated');
      }

      print('📡 [DataSource] Insertion dans part_requests');
      final response = await _supabase
          .from('part_requests')
          .insert(data)
          .select()
          .single();

      print('✅ [DataSource] Demande créée avec succès');
      print('🆔 [DataSource] Réponse: $response');

      return PartRequestModel.fromJson(response);
    } catch (e) {
      print('💥 [DataSource] Erreur lors de la création: $e');
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
  Future<PartRequestModel> updatePartRequestStatus(String id, String status) async {
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
      await _supabase
          .from('part_requests')
          .delete()
          .eq('id', id);
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
            
        final userIds = particuliersResponse
            .map((p) => p['id'] as String)
            .toList();
            
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
      print('❌ [DataSource] Erreur vérification demande active: $e');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPartRequestResponses(String requestId) async {
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
      if (userId == null) throw const UnauthorizedException('User not authenticated');

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
      print('📡 [DataSource] Récupération demandes actives pour vendeur');

      final response = await _supabase
          .from('part_requests_with_responses')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(20);

      print('📦 [DataSource] ${response.length} demandes actives trouvées');

      return (response as List)
          .map((json) => PartRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      print('💥 [DataSource] Erreur récupération demandes vendeur: $e');
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
      print('📡 [DataSource] Création réponse vendeur');
      print('🆔 RequestId: $requestId, SellerId: $sellerId');

      // D'abord créer la réponse
      final responseData = {
        'request_id': requestId,
        'seller_id': sellerId,
        'message': message,
        if (price != null) 'price': price,
        if (availability != null) 'availability': availability,
        if (estimatedDeliveryDays != null) 'estimated_delivery_days': estimatedDeliveryDays,
        'attachments': attachments ?? [],
        'status': 'pending',
      };

      final response = await _supabase
          .from('seller_responses')
          .insert(responseData)
          .select()
          .single();

      print('✅ [DataSource] Réponse vendeur créée: ${response['id']}');

      // Ensuite créer ou récupérer la conversation
      await _createOrGetConversation(requestId, sellerId);

      return response;
    } catch (e) {
      print('💥 [DataSource] Erreur création réponse vendeur: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> acceptSellerResponse(String responseId) async {
    try {
      print('📡 [DataSource] Acceptation réponse: $responseId');

      final response = await _supabase
          .from('seller_responses')
          .update({'status': 'accepted'})
          .eq('id', responseId)
          .select()
          .single();

      print('✅ [DataSource] Réponse acceptée');
      return response;
    } catch (e) {
      print('💥 [DataSource] Erreur acceptation réponse: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> rejectSellerResponse(String responseId) async {
    try {
      print('📡 [DataSource] Rejet réponse: $responseId');

      final response = await _supabase
          .from('seller_responses')
          .update({'status': 'rejected'})
          .eq('id', responseId)
          .select()
          .single();

      print('✅ [DataSource] Réponse rejetée');
      return response;
    } catch (e) {
      print('💥 [DataSource] Erreur rejet réponse: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSellerConversations(String sellerId) async {
    try {
      print('📡 [DataSource] Récupération conversations vendeur: $sellerId');

      final conversations = await _supabase
          .from('conversations')
          .select('''
            *,
            part_requests!inner (
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

      print('📦 [DataSource] ${conversations.length} conversations trouvées');
      return List<Map<String, dynamic>>.from(conversations);
    } catch (e) {
      print('💥 [DataSource] Erreur récupération conversations: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getConversationById(String conversationId) async {
    try {
      print('📡 [DataSource] Récupération conversation: $conversationId');

      final conversation = await _supabase
          .from('conversations')
          .select('''
            *,
            part_requests!inner (
              id,
              vehicle_brand,
              vehicle_model,
              part_type,
              part_names,
              user_id,
              created_at
            )
          ''')
          .eq('id', conversationId)
          .single();

      print('✅ [DataSource] Conversation trouvée');
      return conversation;
    } catch (e) {
      print('💥 [DataSource] Erreur récupération conversation: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getConversationMessages(String conversationId) async {
    try {
      print('📡 [DataSource] Récupération messages conversation: $conversationId');

      final messages = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      print('📦 [DataSource] ${messages.length} messages trouvés');
      return List<Map<String, dynamic>>.from(messages);
    } catch (e) {
      print('💥 [DataSource] Erreur récupération messages: $e');
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
      print('📡 [DataSource] Envoi message dans conversation: $conversationId');

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

      print('✅ [DataSource] Message envoyé: ${message['id']}');
      return message;
    } catch (e) {
      print('💥 [DataSource] Erreur envoi message: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      print('📡 [DataSource] Marquage messages comme lus');

      await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);

      print('✅ [DataSource] Messages marqués comme lus');
    } catch (e) {
      print('💥 [DataSource] Erreur marquage messages: $e');
      throw ServerException(e.toString());
    }
  }

  // Helper method to create or get conversation
  Future<String> _createOrGetConversation(String requestId, String sellerId) async {
    try {
      // Récupérer le client_id depuis la part_request
      final partRequest = await _supabase
          .from('part_requests')
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

      print('✅ [DataSource] Conversation créée: ${conversation['id']}');
      return conversation['id'];
    } catch (e) {
      print('💥 [DataSource] Erreur création conversation: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SellerRejection> rejectPartRequest(SellerRejection rejection) async {
    try {
      print('🚫 [DataSource] Refus de demande: ${rejection.partRequestId}');
      
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
      
      print('✅ [DataSource] Refus enregistré: ${savedRejection.id}');
      return savedRejection;
    } catch (e) {
      print('💥 [DataSource] Erreur refus: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<SellerRejection>> getSellerRejections(String sellerId) async {
    try {
      print('📋 [DataSource] Récupération refus vendeur: $sellerId');

      final result = await _supabase
          .from('seller_rejections')
          .select()
          .eq('seller_id', sellerId)
          .order('rejected_at', ascending: false);

      final rejections = result
          .map((json) => SellerRejectionModel.fromJson(json).toEntity())
          .toList();

      print('✅ [DataSource] ${rejections.length} refus récupérés');
      return rejections;
    } catch (e) {
      print('💥 [DataSource] Erreur récupération refus: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PartRequestModel>> getActivePartRequestsForSellerWithRejections() async {
    try {
      print('🔍 [DataSource] Récupération demandes actives (filtrage refus)');
      
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Pour l'instant, on utilise une approche simple : récupérer toutes les demandes actives
      // et filtrer côté client en attendant d'optimiser la requête SQL
      final result = await _supabase
          .from('part_requests')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      // Récupérer les refus de ce vendeur pour filtrer
      final rejections = await _supabase
          .from('seller_rejections')
          .select('part_request_id')
          .eq('seller_id', currentUser.id);

      final rejectedIds = rejections.map((r) => r['part_request_id'] as String).toSet();

      // Filtrer les demandes pour exclure celles refusées par ce vendeur
      final filteredResult = result.where((json) => 
        !rejectedIds.contains(json['id'] as String)
      ).toList();

      print('📊 [DataSource] ${filteredResult.length}/${result.length} demandes après filtrage refus');

      final models = filteredResult.map((json) {
        return PartRequestModel.fromJson(json);
      }).toList();

      return models;
    } catch (e) {
      print('💥 [DataSource] Erreur récupération demandes avec filtrage: $e');
      throw ServerException(e.toString());
    }
  }

  // Particulier Conversations
  @override
  Future<List<ParticulierConversation>> getParticulierConversations() async {
    try {
      print('🔍 [DataSource] Récupération conversations particulier');
      
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
        print('📱 [DataSource] Device ID obtenu: $deviceId');
        
        // Récupérer tous les particuliers avec ce device_id
        final allParticuliersWithDevice = await _supabase
            .from('particuliers')
            .select('id')
            .eq('device_id', deviceId);
            
        allUserIds = allParticuliersWithDevice
            .map((p) => p['id'] as String)
            .toList();
            
        print('🆔 [DataSource] IDs particulier trouvés pour ce device: $allUserIds');
        
        if (allUserIds.isEmpty) {
          print('⚠️ [DataSource] Aucun particulier trouvé pour ce device, fallback vers auth ID');
          allUserIds = [currentUser.id];
        }
      } catch (e) {
        print('⚠️ [DataSource] Erreur récupération ID persistant: $e');
        print('🔄 [DataSource] Fallback: utilisation auth_id');
        allUserIds = [currentUser.id];
      }

      // Récupérer les conversations pour tous les IDs de particulier
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
              company_name
            )
          ''')
          .inFilter('user_id', allUserIds)
          .order('updated_at', ascending: false);

      print('📦 [DataSource] ${conversations.length} conversations trouvées');

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
              isFromParticulier: msgData['sender_type'] == 'particulier',
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
              ? '${sellerData['first_name'] ?? ''} ${sellerData['last_name'] ?? ''}'.trim()
              : 'Vendeur inconnu';

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
            hasUnreadMessages: (() {
              print('=============== CALCUL UNREAD PARTICULIER ${convData['id']} ===============');
              print('👥 [Datasource-Particulier] Current User ID: ${currentUser.id}');
              print('📨 [Datasource-Particulier] Total messages: ${messages.length}');
              
              for (final msg in messages) {
                print('📧 [Datasource-Particulier] Message ${msg.id}: senderId=${msg.senderId}, isRead=${msg.isRead}, isFromParticulier=${msg.isFromParticulier}, content="${msg.content.length > 20 ? msg.content.substring(0, 20) + "..." : msg.content}"');
              }
              
              final unreadMessages = messages.where((msg) => !msg.isRead && msg.senderId != currentUser.id).toList();
              print('🔴 [Datasource-Particulier] Messages non lus trouvés: ${unreadMessages.length}');
              for (final msg in unreadMessages) {
                print('🔴   → Message: ${msg.content.length > 30 ? msg.content.substring(0, 30) + "..." : msg.content}');
              }
              print('================================================================');
              
              return unreadMessages.isNotEmpty;
            })(),
            unreadCount: (() {
              final unreadCount = messages.where((msg) => !msg.isRead && msg.senderId != currentUser.id).length;
              print('💬 [Datasource-Particulier] FINAL Conversation ${convData['id']}: $unreadCount messages non lus');
              return unreadCount;
            })(),
            vehiclePlate: partRequestData['vehicle_plate'],
            partType: partRequestData['part_type'],
            partNames: List<String>.from(partRequestData['part_names'] ?? []),
            createdAt: DateTime.parse(convData['created_at']),
            updatedAt: DateTime.parse(convData['updated_at']),
          );

          result.add(conversation);
        } catch (e) {
          print('⚠️ [DataSource] Erreur traitement conversation ${convData['id']}: $e');
          // Continue avec les autres conversations
        }
      }

      print('✅ [DataSource] ${result.length} conversations traitées avec succès');
      return result;
    } catch (e) {
      print('💥 [DataSource] Erreur récupération conversations: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ParticulierConversation> getParticulierConversationById(String conversationId) async {
    try {
      print('🔍 [DataSource] Récupération conversation $conversationId');
      
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
      );
    } catch (e) {
      print('💥 [DataSource] Erreur récupération conversation: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendParticulierMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      print('💬 [DataSource] Envoi message particulier: $content');
      
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Préparer les données du message
      final messageData = {
        'conversation_id': conversationId,
        'sender_id': currentUser.id,
        'sender_type': 'user', // Le particulier envoie toujours en tant que 'user'
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

      print('✅ [DataSource] Message particulier envoyé avec succès: ${response['id']}');
      
      // Mettre à jour la conversation avec le dernier message
      await _supabase
          .from('conversations')
          .update({
            'last_message_content': content,
            'last_message_sender_type': 'user',
            'last_message_created_at': response['created_at'],
            'updated_at': 'now()',
          })
          .eq('id', conversationId);

      print('✅ [DataSource] Conversation mise à jour');
      
    } catch (e) {
      print('💥 [DataSource] Erreur envoi message particulier: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markParticulierConversationAsRead(String conversationId) async {
    try {
      print('✓ [DataSource] Marquer conversation $conversationId comme lue');
      
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Marquer tous les messages de cette conversation comme lus
      // Pour le particulier, on marque comme lus les messages envoyés par le vendeur (seller)
      final result = await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'read_at': 'now()',
          })
          .eq('conversation_id', conversationId)
          .eq('sender_type', 'seller') // Messages du vendeur à marquer comme lus
          .eq('is_read', false); // Seulement les messages non lus

      print('✅ [DataSource] Messages du vendeur marqués comme lus: $conversationId');
      
    } catch (e) {
      print('💥 [DataSource] Erreur marquage conversation: $e');
      throw ServerException(e.toString());
    }
  }
}