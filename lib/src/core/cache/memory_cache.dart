import 'dart:async';

/// Cache en mémoire simple avec TTL (Time To Live)
class MemoryCache<T> {
  final Duration _ttl;
  final Map<String, _CacheEntry<T>> _cache = {};
  Timer? _cleanupTimer;

  MemoryCache({Duration ttl = const Duration(minutes: 5)}) : _ttl = ttl {
    // Nettoyer le cache toutes les minutes
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) => _cleanup());
  }

  /// Récupère une valeur du cache ou appelle le loader si absent/expiré
  Future<T> getOrLoad(String key, Future<T> Function() loader) async {
    final entry = _cache[key];

    if (entry != null && !entry.isExpired) {
      return entry.value;
    }

    // Charger la nouvelle valeur
    final value = await loader();
    _cache[key] = _CacheEntry(value, DateTime.now().add(_ttl));
    return value;
  }

  /// Met une valeur en cache
  void put(String key, T value) {
    _cache[key] = _CacheEntry(value, DateTime.now().add(_ttl));
  }

  /// Récupère une valeur du cache
  T? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.value;
    }
    return null;
  }

  /// Invalide une entrée du cache
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Invalide tout le cache
  void invalidateAll() {
    _cache.clear();
  }

  /// Nettoie les entrées expirées
  void _cleanup() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  /// Dispose le cache et arrête le timer
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime expireAt;

  _CacheEntry(this.value, this.expireAt);

  bool get isExpired => DateTime.now().isAfter(expireAt);
}