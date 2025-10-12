import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/vehicle_catalog_service.dart';

/// Provider pour le client Supabase
final _supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider pour le service VehicleCatalogService
final vehicleCatalogServiceProvider = Provider<VehicleCatalogService>((ref) {
  final supabase = ref.watch(_supabaseClientProvider);
  return VehicleCatalogService(supabase);
});

/// Provider pour récupérer toutes les marques de véhicules
final vehicleBrandsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(vehicleCatalogServiceProvider);
  return await service.getBrands();
});

/// Provider pour récupérer les modèles d'une marque spécifique
/// Prend la marque en paramètre
final vehicleModelsProvider = FutureProvider.autoDispose.family<List<String>, String>(
  (ref, brand) async {
    if (brand.isEmpty) return [];
    final service = ref.watch(vehicleCatalogServiceProvider);
    return await service.getModels(brand);
  },
);

/// Provider pour récupérer les années d'un modèle spécifique
/// Prend une String avec 'brand|model' en paramètre (séparateur |)
final vehicleYearsProvider = FutureProvider.autoDispose.family<List<int>, String>(
  (ref, brandModel) async {
    final parts = brandModel.split('|');
    if (parts.length != 2) return [];

    final brand = parts[0].trim();
    final model = parts[1].trim();

    if (brand.isEmpty || model.isEmpty) return [];

    final service = ref.watch(vehicleCatalogServiceProvider);
    return await service.getYears(brand, model);
  },
);
