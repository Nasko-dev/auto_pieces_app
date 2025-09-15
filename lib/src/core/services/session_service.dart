import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      print('🔍 [SessionService] Vérification session en cache...');
      
      // Vérifier si l'auto-reconnexion est activée
      final autoReconnect = _prefs.getBool(_keyAutoReconnect) ?? true;
      if (!autoReconnect) {
        print('⏹️ [SessionService] Auto-reconnexion désactivée');
        return false;
      }
      
      // Vérifier la date de dernière session
      final lastSessionStr = _prefs.getString(_keyLastSessionTime);
      if (lastSessionStr == null) {
        print('❌ [SessionService] Pas de session en cache');
        return false;
      }
      
      final lastSession = DateTime.parse(lastSessionStr);
      final now = DateTime.now();
      
      if (now.difference(lastSession) > _cacheValidity) {
        print('⏰ [SessionService] Session expirée (${now.difference(lastSession).inDays} jours)');
        await clearCache();
        return false;
      }
      
      // Vérifier si Supabase a déjà une session
      final currentSession = _supabase.auth.currentSession;
      if (currentSession != null) {
        print('✅ [SessionService] Session Supabase active trouvée');
        await updateCachedSession();
        return true;
      }
      
      print('🔄 [SessionService] Session en cache valide, reconnexion nécessaire');
      return true;
    } catch (e) {
      print('❌ [SessionService] Erreur vérification cache: $e');
      return false;
    }
  }
  
  /// Restaure automatiquement la session depuis le cache
  Future<bool> autoReconnect() async {
    try {
      print('🔄 [SessionService] Tentative d\'auto-reconnexion...');
      
      // Vérifier d'abord si une session est déjà active
      if (_supabase.auth.currentSession != null) {
        print('✅ [SessionService] Déjà connecté');
        await updateCachedSession();
        return true;
      }
      
      // Vérifier le cache
      if (!await hasValidCachedSession()) {
        print('❌ [SessionService] Pas de session valide en cache');
        return false;
      }
      
      // Tenter de restaurer la session avec Supabase
      // Supabase gère automatiquement la persistance avec son propre stockage
      // On vérifie juste si une session peut être récupérée
      await _supabase.auth.refreshSession();
      
      final session = _supabase.auth.currentSession;
      if (session != null) {
        print('✅ [SessionService] Session restaurée avec succès');
        await updateCachedSession();
        return true;
      }
      
      print('⚠️ [SessionService] Impossible de restaurer la session');
      return false;
    } catch (e) {
      print('❌ [SessionService] Erreur auto-reconnexion: $e');
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
      
      // Déterminer le type d'utilisateur basé sur les métadonnées
      final metadata = user.userMetadata;
      String userType = 'particulier'; // Par défaut
      
      if (metadata != null) {
        // Vérifier si c'est un vendeur
        if (metadata['role'] == 'vendeur' || metadata['is_seller'] == true) {
          userType = 'vendeur';
          await _prefs.setString(_keyUserRole, 'vendeur');
        } else {
          await _prefs.setString(_keyUserRole, 'particulier');
        }
      }
      
      await _prefs.setString(_keyUserType, userType);
      
      print('💾 [SessionService] Session mise en cache - Type: $userType');
    } catch (e) {
      print('❌ [SessionService] Erreur mise à jour cache: $e');
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
    print('⚙️ [SessionService] Auto-reconnexion: ${enabled ? 'activée' : 'désactivée'}');
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
    print('🧹 [SessionService] Cache de session nettoyé');
  }
  
  /// Déconnecte l'utilisateur et nettoie le cache
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      await clearCache();
      print('👋 [SessionService] Déconnexion réussie');
    } catch (e) {
      print('❌ [SessionService] Erreur déconnexion: $e');
      // Nettoyer le cache même en cas d'erreur
      await clearCache();
    }
  }
}

