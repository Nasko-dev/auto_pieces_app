import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/performance_optimizer.dart';

/// Service Supabase optimisé pour 500k+ utilisateurs
class OptimizedSupabaseService {
  static final OptimizedSupabaseService _instance = OptimizedSupabaseService._internal();
  factory OptimizedSupabaseService() => _instance;
  OptimizedSupabaseService._internal();

  final _supabase = Supabase.instance.client;
  final _cache = PerformanceOptimizer();

  /// Récupère les demandes de pièces avec pagination et cache
  Future<List<Map<String, dynamic>>> getPartRequests({
    int offset = 0,
    int limit = 20,
    String? partType,
    String? vehicleBrand,
    bool useCache = true,
  }) async {
    final cacheKey = 'part_requests_${offset}_${limit}_${partType ?? ''}_${vehicleBrand ?? ''}';
    
    if (useCache) {
      return await _cache.smartCache(
        cacheKey,
        () => _fetchPartRequests(offset, limit, partType, vehicleBrand),
        ttl: const Duration(minutes: 2), // Cache court pour données dynamiques
      );
    } else {
      return await _fetchPartRequests(offset, limit, partType, vehicleBrand);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPartRequests(
    int offset, 
    int limit, 
    String? partType, 
    String? vehicleBrand
  ) async {
    var query = _supabase
        .from('part_requests')
        .select('*')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    if (partType != null) {
      query = query.eq('part_type', partType);
    }
    
    if (vehicleBrand != null) {
      query = query.eq('vehicle_brand', vehicleBrand);
    }

    return await query;
  }

  /// Récupère les conversations vendeur avec cache optimisé
  Future<List<Map<String, dynamic>>> getSellerConversations({
    String? sellerId,
    int offset = 0,
    int limit = 20,
    bool useCache = true,
  }) async {
    final currentSellerId = sellerId ?? _supabase.auth.currentUser?.id;
    if (currentSellerId == null) return [];

    final cacheKey = 'seller_conversations_${currentSellerId}_${offset}_$limit';
    
    if (useCache) {
      return await _cache.smartCache(
        cacheKey,
        () => _fetchSellerConversations(currentSellerId, offset, limit),
        ttl: const Duration(minutes: 3),
      );
    } else {
      return await _fetchSellerConversations(currentSellerId, offset, limit);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSellerConversations(
    String sellerId, 
    int offset, 
    int limit
  ) async {
    return await _supabase
        .from('conversations')
        .select('''
          *,
          part_requests!inner(
            id,
            vehicle_brand,
            vehicle_model,
            part_type,
            part_names,
            created_at
          )
        ''')
        .eq('seller_id', sellerId)
        .order('last_message_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  /// Crée une réponse vendeur de manière optimisée
  Future<Map<String, dynamic>> createSellerResponse({
    required String requestId,
    required String message,
    double? price,
    int? deliveryDays,
    String status = 'accepted',
  }) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Utilisateur non connecté');

    // 1. Créer la réponse
    final response = await _supabase
        .from('seller_responses')
        .insert({
          'request_id': requestId,
          'seller_id': currentUser.id,
          'message': message,
          'price': price,
          'estimated_delivery_days': deliveryDays,
          'status': status,
        })
        .select()
        .single();

    // 2. Invalider les caches liés
    _invalidateConversationCaches(currentUser.id);
    
    return response;
  }

  /// Envoie un message optimisé
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
    double? offerPrice,
    int? offerDeliveryDays,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Utilisateur non connecté');

    final message = await _supabase
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': currentUser.id,
          'sender_type': 'seller',
          'content': content,
          'message_type': messageType,
          'offer_price': offerPrice,
          'offer_delivery_days': offerDeliveryDays,
        })
        .select()
        .single();

    // Invalider les caches de conversation
    _invalidateConversationCaches(currentUser.id);
    
    return message;
  }

  /// Crée ou récupère une conversation
  Future<Map<String, dynamic>> getOrCreateConversation({
    required String requestId,
    required String clientId,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Utilisateur non connecté');

    // Utiliser la déduplication pour éviter les créations multiples
    final cacheKey = 'conversation_${requestId}_${currentUser.id}';
    
    return await _cache.executeWithDeduplication(
      cacheKey,
      () async {
        // Chercher conversation existante
        final existing = await _supabase
            .from('conversations')
            .select()
            .eq('request_id', requestId)
            .eq('seller_id', currentUser.id)
            .limit(1);

        if (existing.isNotEmpty) {
          return existing.first;
        }

        // Créer nouvelle conversation
        return await _supabase
            .from('conversations')
            .insert({
              'request_id': requestId,
              'seller_id': currentUser.id,
              'client_id': clientId,
            })
            .select()
            .single();
      },
    );
  }

  /// Compte les éléments avec cache
  Future<int> countPartRequests({
    String? partType,
    String? vehicleBrand,
    bool useCache = true,
  }) async {
    final cacheKey = 'count_requests_${partType ?? ''}_${vehicleBrand ?? ''}';
    
    if (useCache) {
      return await _cache.smartCache(
        cacheKey,
        () => _fetchCountPartRequests(partType, vehicleBrand),
        ttl: const Duration(minutes: 5), // Cache plus long pour les compteurs
      );
    } else {
      return await _fetchCountPartRequests(partType, vehicleBrand);
    }
  }

  Future<int> _fetchCountPartRequests(String? partType, String? vehicleBrand) async {
    var query = _supabase
        .from('part_requests')
        .select('id', const FetchOptions(count: CountOption.exact));

    if (partType != null) query = query.eq('part_type', partType);
    if (vehicleBrand != null) query = query.eq('vehicle_brand', vehicleBrand);

    final response = await query;
    return response.count ?? 0;
  }

  /// Invalide les caches liés aux conversations
  void _invalidateConversationCaches(String sellerId) {
    // Pattern matching pour supprimer tous les caches de conversations
    final keysToRemove = <String>[];
    
    // Cette implémentation nécessiterait d'exposer les clés dans PerformanceOptimizer
    // Pour l'instant, on vide tout le cache lié aux conversations
    _cache.clearCache(); // Simplified - ideally would be more selective
  }

  /// Nettoie le cache périodiquement
  void cleanupCache() {
    _cache.cleanExpiredCache();
  }

  /// Obtient les statistiques de performance
  String getPerformanceStats() {
    return _cache.getStats().toString();
  }
}

/// Configuration des index optimaux pour Supabase
class DatabaseIndexes {
  static const String createIndexes = '''
    -- Index pour part_requests (recherche fréquente)
    CREATE INDEX IF NOT EXISTS idx_part_requests_type_brand_date 
    ON part_requests(part_type, vehicle_brand, created_at DESC);
    
    CREATE INDEX IF NOT EXISTS idx_part_requests_user_date 
    ON part_requests(user_id, created_at DESC);
    
    -- Index pour conversations (dashboard vendeur)
    CREATE INDEX IF NOT EXISTS idx_conversations_seller_date 
    ON conversations(seller_id, last_message_at DESC);
    
    CREATE INDEX IF NOT EXISTS idx_conversations_request_seller 
    ON conversations(request_id, seller_id);
    
    -- Index pour messages (chargement rapide)
    CREATE INDEX IF NOT EXISTS idx_messages_conversation_date 
    ON messages(conversation_id, created_at DESC);
    
    -- Index pour seller_responses
    CREATE INDEX IF NOT EXISTS idx_seller_responses_request_status 
    ON seller_responses(request_id, status);
    
    CREATE INDEX IF NOT EXISTS idx_seller_responses_seller_date 
    ON seller_responses(seller_id, created_at DESC);
  ''';
}