import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour récupérer les données du catalogue de véhicules
/// Utilise les fonctions SQL créées dans Supabase
class VehicleCatalogService {
  final SupabaseClient _supabase;

  VehicleCatalogService(this._supabase);

  /// Récupérer toutes les marques disponibles
  Future<List<String>> getBrands() async {
    try {
      final response = await _supabase.rpc('get_vehicle_brands');

      if (response == null) return [];

      // La fonction retourne directement une liste d'objets {brand: "..."}
      return (response as List).map((item) {
        if (item is Map) {
          return item['brand'] as String;
        }
        return item.toString();
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des marques: $e');
    }
  }

  /// Récupérer les modèles pour une marque donnée
  Future<List<String>> getModels(String brand) async {
    try {
      if (brand.isEmpty) return [];

      final response = await _supabase.rpc(
        'get_vehicle_models',
        params: {'brand_name': brand},
      );

      if (response == null) return [];

      // La fonction retourne directement une liste d'objets {model: "..."}
      return (response as List).map((item) {
        if (item is Map) {
          return item['model'] as String;
        }
        return item.toString();
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des modèles: $e');
    }
  }

  /// Récupérer les années pour une marque et un modèle donnés
  Future<List<int>> getYears(String brand, String model) async {
    try {
      if (brand.isEmpty || model.isEmpty) return [];

      final response = await _supabase.rpc(
        'get_vehicle_years',
        params: {
          'brand_name': brand,
          'model_name': model,
        },
      );

      if (response == null) return [];

      // La fonction retourne directement une liste d'objets {year: 2020}
      return (response as List).map((item) {
        if (item is Map) {
          return item['year'] as int;
        }
        if (item is int) {
          return item;
        }
        return int.parse(item.toString());
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des années: $e');
    }
  }
}
