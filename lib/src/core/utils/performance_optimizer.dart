import 'dart:async';

/// Entrée de cache avec données et expiration
class CacheEntry {
  final dynamic data;
  final DateTime expiry;

  CacheEntry(this.data, this.expiry);
}

/// Statistiques du cache
class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final int activeRequests;
  final double cacheHitRate;

  const CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.activeRequests,
    required this.cacheHitRate,
  });
}

/// Système de cache et optimisation pour supporter 500k+ utilisateurs
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  // Cache LRU pour les données fréquemment consultées
  final _cache = <String, CacheEntry>{};
  static const int _maxCacheSize = 1000;
  static const Duration _defaultTTL = Duration(minutes: 5);

  // Pool de connexions pour limiter les requêtes simultanées
  final _requestPool = <String, Future<dynamic>>{};

  /// Cache une valeur avec TTL
  void cacheData(String key, dynamic data, {Duration? ttl}) {
    final expiry = DateTime.now().add(ttl ?? _defaultTTL);
    _cache[key] = CacheEntry(data, expiry);

    // Éviter de dépasser la limite de cache (LRU)
    if (_cache.length > _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Récupère une valeur du cache si elle n'est pas expirée
  T? getCachedData<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiry)) {
      _cache.remove(key);
      return null;
    }

    // Mettre en fin de cache (LRU)
    _cache.remove(key);
    _cache[key] = entry;
    
    return entry.data as T?;
  }

  /// Exécute une requête avec déduplication (évite les requêtes identiques simultanées)
  Future<T> executeWithDeduplication<T>(String key, Future<T> Function() operation) async {
    // Si une requête identique est déjà en cours, attendre le résultat
    if (_requestPool.containsKey(key)) {
      return await _requestPool[key] as T;
    }

    // Exécuter la nouvelle requête
    final future = operation();
    _requestPool[key] = future;

    try {
      final result = await future;
      return result;
    } finally {
      _requestPool.remove(key);
    }
  }

  /// Cache intelligent : vérifie le cache puis exécute si nécessaire
  Future<T> smartCache<T>(
    String key, 
    Future<T> Function() operation, 
    {Duration? ttl}
  ) async {
    // 1. Vérifier le cache
    final cached = getCachedData<T>(key);
    if (cached != null) return cached;

    // 2. Exécuter avec déduplication
    final result = await executeWithDeduplication(key, operation);
    
    // 3. Mettre en cache
    cacheData(key, result, ttl: ttl);
    
    return result;
  }

  /// Nettoie le cache expiré
  void cleanExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => now.isAfter(entry.expiry));
  }

  /// Vide le cache complètement
  void clearCache() {
    _cache.clear();
  }

  /// Statistiques de performance
  CacheStats getStats() {
    final now = DateTime.now();
    final expired = _cache.values.where((e) => now.isAfter(e.expiry)).length;
    
    return CacheStats(
      totalEntries: _cache.length,
      expiredEntries: expired,
      activeRequests: _requestPool.length,
      cacheHitRate: _cacheHits / (_cacheHits + _cacheMisses),
    );
  }

  // Compteurs pour statistiques
  final int _cacheHits = 0;
  final int _cacheMisses = 0;


  @override
  String toString() {
    final stats = getStats();
    return 'CacheStats(entries: ${stats.totalEntries}, expired: ${stats.expiredEntries}, '
           'requests: ${stats.activeRequests}, hitRate: ${(stats.cacheHitRate * 100).toStringAsFixed(1)}%)';
  }
}