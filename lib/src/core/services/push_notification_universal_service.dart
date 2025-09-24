import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service universel pour gérer les Player IDs de tous les types d'utilisateurs
/// Utilise une table 'user_push_tokens' qui fonctionne pour particuliers ET sellers
class PushNotificationUniversalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static PushNotificationUniversalService? _instance;
  static PushNotificationUniversalService get instance {
    _instance ??= PushNotificationUniversalService._();
    return _instance!;
  }

  PushNotificationUniversalService._();

  /// Sauvegarde le Player ID dans une table universelle
  Future<void> savePlayerIdUniversal() async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;
      final userId = _supabase.auth.currentUser?.id;
      final userEmail = _supabase.auth.currentUser?.email;

      debugPrint('\n🔧 SERVICE UNIVERSEL DE NOTIFICATION');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('   Player ID: $playerId');
      debugPrint('   User ID: $userId');
      debugPrint('   Email: $userEmail');

      if (playerId == null || userId == null) {
        debugPrint('❌ Player ID ou User ID manquant');
        return;
      }

      // Déterminer le type d'utilisateur
      String userType = 'unknown';

      // Vérifier dans particuliers
      final isParticulier = await _supabase
        .from('particuliers')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

      if (isParticulier != null) {
        userType = 'particulier';
      } else {
        // Vérifier dans sellers
        final isSeller = await _supabase
          .from('sellers')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

        if (isSeller != null) {
          userType = 'seller';
        }
      }

      debugPrint('   Type d\'utilisateur: $userType');

      // Créer ou mettre à jour dans la table user_push_tokens
      final existingToken = await _supabase
        .from('user_push_tokens')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

      if (existingToken != null) {
        // Mettre à jour
        await _supabase
          .from('user_push_tokens')
          .update({
            'onesignal_player_id': playerId,
            'user_type': userType,
            'platform': 'android',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

        debugPrint('✅ Player ID mis à jour dans user_push_tokens');
      } else {
        // Créer
        await _supabase
          .from('user_push_tokens')
          .insert({
            'user_id': userId,
            'onesignal_player_id': playerId,
            'user_type': userType,
            'platform': 'android',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

        debugPrint('✅ Player ID créé dans user_push_tokens');
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Sauvegarde universelle réussie');

    } catch (e) {
      debugPrint('❌ Erreur dans le service universel: $e');

      // Si la table n'existe pas, afficher les instructions SQL
      if (e.toString().contains('user_push_tokens')) {
        debugPrint('\n📋 CRÉATION DE LA TABLE REQUISE:');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('''
CREATE TABLE IF NOT EXISTS public.user_push_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE,
  onesignal_player_id TEXT,
  user_type TEXT CHECK (user_type IN ('particulier', 'seller', 'unknown')),
  platform TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX idx_user_push_tokens_user_id ON public.user_push_tokens(user_id);
CREATE INDEX idx_user_push_tokens_player_id ON public.user_push_tokens(onesignal_player_id);

-- RLS (Row Level Security)
ALTER TABLE public.user_push_tokens ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre aux utilisateurs de gérer leurs propres tokens
CREATE POLICY "Users can manage own push tokens"
  ON public.user_push_tokens
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
        ''');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    }
  }

  /// Récupère le Player ID pour un utilisateur donné
  Future<String?> getPlayerIdForUser(String userId) async {
    try {
      final result = await _supabase
        .from('user_push_tokens')
        .select('onesignal_player_id')
        .eq('user_id', userId)
        .maybeSingle();

      return result?['onesignal_player_id'];
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération du Player ID: $e');
      return null;
    }
  }

  /// Supprime le Player ID (déconnexion)
  Future<void> clearPlayerIdForUser(String userId) async {
    try {
      await _supabase
        .from('user_push_tokens')
        .delete()
        .eq('user_id', userId);

      debugPrint('✅ Player ID supprimé pour l\'utilisateur');
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression du Player ID: $e');
    }
  }
}