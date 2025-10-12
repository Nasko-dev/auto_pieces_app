import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour récupérer les données du catalogue moteur depuis Supabase
class EngineCatalogService {
  final SupabaseClient _supabase;

  EngineCatalogService(this._supabase);

  /// Récupère toutes les cylindrées disponibles
  Future<List<String>> getCylinders() async {
    try {
      final response = await _supabase.rpc('get_engine_cylinders');

      if (response == null) return [];

      return (response as List)
          .map((item) => item['cylindree'] as String)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cylindrées: $e');
    }
  }

  /// Récupère tous les types de carburant disponibles
  Future<List<String>> getFuelTypes() async {
    try {
      final response = await _supabase.rpc('get_fuel_types');

      if (response == null) return [];

      return (response as List)
          .map((item) => item['fuel_type'] as String)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des types de carburant: $e');
    }
  }

  /// Récupère les codes moteur filtrés par cylindrée et type de carburant
  ///
  /// [cylindree] : Cylindrée à filtrer (ex: "1.6L", "2.0L")
  /// [fuelType] : Type de carburant à filtrer (ex: "Essence", "Diesel")
  Future<List<String>> getEngineModels({
    String? cylindree,
    String? fuelType,
  }) async {
    try {
      final response = await _supabase.rpc('get_engine_models', params: {
        'p_cylindree': cylindree,
        'p_fuel_type': fuelType,
      });

      if (response == null) return [];

      return (response as List)
          .map((item) {
            final engineCode = item['engine_code'] as String;
            final power = item['power'] as int?;
            // Formater: "2.0 TDI (150 cv)" ou "2.0 TDI" si pas de puissance
            return power != null ? '$engineCode ($power cv)' : engineCode;
          })
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des moteurs: $e');
    }
  }
}
