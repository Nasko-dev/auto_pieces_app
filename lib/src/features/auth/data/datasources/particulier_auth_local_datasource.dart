import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/particulier_model.dart';

abstract class ParticulierAuthLocalDataSource {
  Future<ParticulierModel?> getCachedParticulier();
  Future<void> cacheParticulier(ParticulierModel particulier);
  Future<void> clearCache();
}

class ParticulierAuthLocalDataSourceImpl
    implements ParticulierAuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedParticulierKey = 'CACHED_PARTICULIER';

  ParticulierAuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ParticulierModel?> getCachedParticulier() async {
    try {
      final jsonString = sharedPreferences.getString(cachedParticulierKey);
      if (jsonString != null) {
        final particulier = ParticulierModel.fromJson(jsonDecode(jsonString));
        return particulier;
      }
      return null;
    } catch (e) {
      throw CacheException('Erreur lors de la lecture du cache');
    }
  }

  @override
  Future<void> cacheParticulier(ParticulierModel particulier) async {
    try {
      await sharedPreferences.setString(
        cachedParticulierKey,
        jsonEncode(particulier.toJson()),
      );
    } catch (e) {
      throw CacheException('Erreur lors de la mise en cache');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(cachedParticulierKey);
    } catch (e) {
      throw CacheException('Erreur lors de la suppression du cache');
    }
  }
}
