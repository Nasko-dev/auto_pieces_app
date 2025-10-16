import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/engine_catalog_service.dart';

/// Provider du client Supabase
final _supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider du service EngineCatalogService
final engineCatalogServiceProvider = Provider<EngineCatalogService>((ref) {
  final supabase = ref.watch(_supabaseClientProvider);
  return EngineCatalogService(supabase);
});

/// Provider pour récupérer toutes les cylindrées disponibles
final engineCylindersProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(engineCatalogServiceProvider);
  return await service.getCylinders();
});

/// Provider pour récupérer tous les types de carburant disponibles
final engineFuelTypesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(engineCatalogServiceProvider);
  return await service.getFuelTypes();
});

/// Provider pour récupérer les codes moteur filtrés par cylindrée et carburant
///
/// Le paramètre est une clé composite au format "cylindree|fuelType"
/// Exemples:
/// - "1.6L|Diesel" -> filtre cylindrée 1.6L ET diesel
/// - "1.6L|" -> filtre uniquement cylindrée 1.6L
/// - "|Diesel" -> filtre uniquement diesel
/// - "|" -> aucun filtre (tous les moteurs)
final engineModelsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, filterKey) async {
  final service = ref.watch(engineCatalogServiceProvider);

  // Parser la clé composite
  final parts = filterKey.split('|');
  final cylindree = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : null;
  final fuelType = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;

  // Si aucun filtre n'est défini, retourner une liste vide
  if (cylindree == null && fuelType == null) {
    return [];
  }

  return await service.getEngineModels(
    cylindree: cylindree,
    fuelType: fuelType,
  );
});
