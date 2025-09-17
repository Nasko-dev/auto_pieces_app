import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service de gestion de session avec persistance locale
/// Gère l'auto-reconnexion et le cache de session
class SessionService {
  final SharedPreferences _prefs;
  final SupabaseClient _supabase;
  
  static const String _keyUserType = 'user_type'; // 'particulier' ou 'vendeur'
  static const String _keyLastSessionTime = 'last_session_time';
  static const String _keyAutoReconnect = 'auto_reconnect';
  static const String _keyUserId = 'cached_user_id';
  static const String _keyUserEmail = 'cached_user_email';
  static const String _keyUserRole = 'cached_user_role';
  
  // Durée de validité du cache (7 jours)
  static const Duration _cacheValidity = Duration(days: 7);
  
  SessionService(this._prefs, this._supabase);
  
  /// Vérifie si une session est en cache et toujours valide
  Future<bool> hasValidCachedSession() async {
    try {
      
      // Vérifier si l'auto-reconnexion est activée
      final autoReconnect = _prefs.getBool(_keyAutoReconnect) ?? true;
      if (!autoReconnect) {
        return false;
      }
      
      // Vérifier la date de dernière session
      final lastSessionStr = _prefs.getString(_keyLastSessionTime);
      if (lastSessionStr == null) {
        return false;
      }
      
      final lastSession = DateTime.parse(lastSessionStr);
      final now = DateTime.now();
      
      if (now.difference(lastSession) > _cacheValidity) {
        await clearCache();
        return false;
      }
      
      // Vérifier si Supabase a déjà une session
      final currentSession = _supabase.auth.currentSession;
      if (currentSession != null) {
        await updateCachedSession();
        return true;
      }
      
      // Si pas de session Supabase mais cache présent, le cache est invalide
      await clearCache();
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Restaure automatiquement la session depuis le cache
  Future<bool> autoReconnect() async {
    try {
      
      // Vérifier d'abord si une session est déjà active
      if (_supabase.auth.currentSession != null) {
        await updateCachedSession();
        return true;
      }
      
      // Vérifier le cache - cela nettoiera automatiquement si invalide
      final hasCache = await hasValidCachedSession();
      if (!hasCache) {
        return false;
      }
      
      // Si on arrive ici, c'est qu'il y a une incohérence
      // Le cache dit qu'il y a une session mais Supabase n'en a pas
      // On nettoie le cache pour éviter les problèmes
      await clearCache();
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Met à jour les informations de session en cache
  Future<void> updateCachedSession() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      await _prefs.setString(_keyUserId, user.id);
      await _prefs.setString(_keyUserEmail, user.email ?? '');
      await _prefs.setString(_keyLastSessionTime, DateTime.now().toIso8601String());
      
      // Déterminer le type d'utilisateur en vérifiant dans la table sellers
      String userType = 'particulier'; // Par défaut
      
      try {
        
        // Vérifier directement dans la table sellers si l'utilisateur est un vendeur
        final response = await _supabase
            .from('sellers')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();
        
        
        if (response != null) {
          userType = 'vendeur';
        } else {
          // Vérifier aussi les métadonnées au cas où
          final metadata = user.userMetadata;
          if (metadata != null && (metadata['role'] == 'vendeur' || metadata['is_seller'] == true)) {
            userType = 'vendeur';
          }
        }
      } catch (e) {
        // En cas d'erreur, se baser sur les métadonnées
        final metadata = user.userMetadata;
        if (metadata != null && (metadata['role'] == 'vendeur' || metadata['is_seller'] == true)) {
          userType = 'vendeur';
        }
      }
      
      await _prefs.setString(_keyUserType, userType);
      await _prefs.setString(_keyUserRole, userType);
      
    } catch (e) {
      // Ignorer l'erreur silencieusement
    }
  }
  
  /// Récupère le type d'utilisateur en cache
  String? getCachedUserType() {
    return _prefs.getString(_keyUserType);
  }
  
  /// Récupère l'ID utilisateur en cache
  String? getCachedUserId() {
    return _prefs.getString(_keyUserId);
  }
  
  /// Récupère l'email utilisateur en cache
  String? getCachedUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }
  
  /// Récupère le rôle utilisateur en cache
  String? getCachedUserRole() {
    return _prefs.getString(_keyUserRole);
  }
  
  /// Active ou désactive l'auto-reconnexion
  Future<void> setAutoReconnect(bool enabled) async {
    await _prefs.setBool(_keyAutoReconnect, enabled);
  }
  
  /// Vérifie si l'auto-reconnexion est activée
  bool isAutoReconnectEnabled() {
    return _prefs.getBool(_keyAutoReconnect) ?? true;
  }
  
  /// Nettoie le cache de session
  Future<void> clearCache() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserType);
    await _prefs.remove(_keyLastSessionTime);
  }
  
  /// Déconnecte l'utilisateur et nettoie le cache
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      await clearCache();
    } catch (e) {
      // Nettoyer le cache même en cas d'erreur
      await clearCache();
    }
  }
}
