import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/session_service.dart';

/// Provider pour accéder à SharedPreferences (doit être override dans main.dart)
final sessionSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

/// Provider pour accéder au client Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider pour le service de session
final sessionServiceProvider = Provider<SessionService>((ref) {
  final prefs = ref.watch(sessionSharedPreferencesProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return SessionService(prefs, supabase);
});

/// Provider pour écouter les changements d'authentification et mettre à jour le cache
final authStateListenerProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final sessionService = ref.watch(sessionServiceProvider);
  
  // Écouter les changements d'état d'authentification
  return supabase.auth.onAuthStateChange.map((authState) {
    print('🔄 [AuthListener] État auth changé: ${authState.event}');
    
    // Mettre à jour le cache selon l'événement
    switch (authState.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
        // Mettre à jour le cache de session
        sessionService.updateCachedSession();
        print('💾 [AuthListener] Cache mis à jour après ${authState.event}');
        break;
        
      case AuthChangeEvent.signedOut:
        // Nettoyer le cache
        sessionService.clearCache();
        print('🧹 [AuthListener] Cache nettoyé après déconnexion');
        break;
        
      default:
        break;
    }
    
    return authState;
  });
});

/// Provider pour vérifier rapidement si l'utilisateur est connecté
final isAuthenticatedProvider = Provider<bool>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.currentUser != null;
});

/// Provider pour obtenir l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.currentUser;
});

/// Provider pour obtenir le type d'utilisateur depuis le cache
final cachedUserTypeProvider = Provider<String?>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getCachedUserType();
});

/// Provider pour vérifier si l'auto-reconnexion est activée
final isAutoReconnectEnabledProvider = Provider<bool>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.isAutoReconnectEnabled();
});

/// Provider pour gérer l'état initial de connexion
final initialAuthCheckProvider = FutureProvider<bool>((ref) async {
  final sessionService = ref.watch(sessionServiceProvider);
  
  print('🔍 [InitialAuth] Vérification session initiale...');
  
  // Tenter l'auto-reconnexion
  final hasReconnected = await sessionService.autoReconnect();
  
  if (hasReconnected) {
    print('✅ [InitialAuth] Session restaurée avec succès');
    return true;
  }
  
  print('ℹ️ [InitialAuth] Pas de session à restaurer');
  return false;
});