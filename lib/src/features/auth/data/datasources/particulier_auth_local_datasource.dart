import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/particulier_model.dart';

abstract class ParticulierAuthLocalDataSource {
  Future<ParticulierModel?> getCachedParticulier();
  Future<void> cacheParticulier(ParticulierModel particulier);
  Future<void> clearCache();
}

class ParticulierAuthLocalDataSourceImpl implements ParticulierAuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedParticulierKey = 'CACHED_PARTICULIER';

  ParticulierAuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ParticulierModel?> getCachedParticulier() async {
    try {
      print('🔍 [LocalDataSource] Récupération cache particulier');
      final jsonString = sharedPreferences.getString(cachedParticulierKey);
      if (jsonString != null) {
        final particulier = ParticulierModel.fromJson(jsonDecode(jsonString));
        print('✅ [LocalDataSource] Particulier trouvé en cache: ${particulier.email}');
        return particulier;
      }
      print('ℹ️ [LocalDataSource] Aucun particulier en cache');
      return null;
    } catch (e) {
      print('❌ [LocalDataSource] Erreur lecture cache: $e');
      throw CacheException('Erreur lors de la lecture du cache');
    }
  }

  @override
  Future<void> cacheParticulier(ParticulierModel particulier) async {
    try {
      print('💾 [LocalDataSource] Mise en cache particulier: ${particulier.email}');
      await sharedPreferences.setString(
        cachedParticulierKey,
        jsonEncode(particulier.toJson()),
      );
      print('✅ [LocalDataSource] Particulier mis en cache');
    } catch (e) {
      print('❌ [LocalDataSource] Erreur mise en cache: $e');
      throw CacheException('Erreur lors de la mise en cache');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      print('🗑️ [LocalDataSource] Suppression cache particulier');
      await sharedPreferences.remove(cachedParticulierKey);
      print('✅ [LocalDataSource] Cache supprimé');
    } catch (e) {
      print('❌ [LocalDataSource] Erreur suppression cache: $e');
      throw CacheException('Erreur lors de la suppression du cache');
    }
  }
}