import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/part_advertisement_model.dart';

abstract class PartAdvertisementRemoteDataSource {
  Future<PartAdvertisementModel> createPartAdvertisement(
    CreatePartAdvertisementParams params,
  );

  Future<PartAdvertisementModel> getPartAdvertisementById(String id);

  Future<List<PartAdvertisementModel>> getMyPartAdvertisements();

  Future<List<PartAdvertisementModel>> searchPartAdvertisements(
    SearchPartAdvertisementsParams params,
  );

  Future<PartAdvertisementModel> updatePartAdvertisement(
    String id,
    Map<String, dynamic> updates,
  );

  Future<void> deletePartAdvertisement(String id);

  Future<void> markAsSold(String id);

  Future<void> incrementViewCount(String id);

  Future<void> incrementContactCount(String id);
}

class PartAdvertisementRemoteDataSourceImpl implements PartAdvertisementRemoteDataSource {
  final SupabaseClient client;

  PartAdvertisementRemoteDataSourceImpl({required this.client});

  @override
  Future<PartAdvertisementModel> createPartAdvertisement(
    CreatePartAdvertisementParams params,
  ) async {
    try {
      // Utiliser la fonction SQL create_part_advertisement
      final response = await client.rpc('create_part_advertisement', params: {
        'p_part_type': params.partType,
        'p_part_name': params.partName,
        'p_vehicle_plate': params.vehiclePlate,
        'p_vehicle_brand': params.vehicleBrand,
        'p_vehicle_model': params.vehicleModel,
        'p_vehicle_year': params.vehicleYear,
        'p_vehicle_engine': params.vehicleEngine,
        'p_description': params.description,
        'p_price': params.price,
        'p_condition': params.condition,
        'p_images': params.images,
        'p_contact_phone': params.contactPhone,
        'p_contact_email': params.contactEmail,
      });

      if (response == null) {
        throw ServerException('Erreur lors de la création de l\'annonce');
      }

      // La fonction SQL retourne maintenant un tableau d'objets
      final responseList = response as List<dynamic>;
      if (responseList.isEmpty) {
        throw ServerException('Aucune annonce retournée après création');
      }
      
      // Convertir le premier (et seul) élément en PartAdvertisementModel
      final adData = responseList.first as Map<String, dynamic>;
      return PartAdvertisementModel.fromJson(adData);
    } catch (e) {
      throw ServerException('Erreur lors de la création: $e');
    }
  }

  @override
  Future<PartAdvertisementModel> getPartAdvertisementById(String id) async {
    try {
      final response = await client
          .from('part_advertisements')
          .select()
          .eq('id', id)
          .single();

      return PartAdvertisementModel.fromSupabase(response);
    } catch (e) {
      throw ServerException('Annonce non trouvée: $e');
    }
  }

  @override
  Future<List<PartAdvertisementModel>> getMyPartAdvertisements() async {
    try {
      final response = await client
          .from('part_advertisements')
          .select()
          .eq('user_id', client.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => PartAdvertisementModel.fromSupabase(data))
          .toList();
    } catch (e) {
      throw ServerException('Erreur lors de la récupération: $e');
    }
  }

  @override
  Future<List<PartAdvertisementModel>> searchPartAdvertisements(
    SearchPartAdvertisementsParams params,
  ) async {
    try {
      // Utiliser la fonction SQL search_part_advertisements
      final response = await client.rpc('search_part_advertisements', params: {
        'search_query': params.query,
        'filter_part_type': params.partType,
        'filter_city': params.city,
        'min_price': params.minPrice,
        'max_price': params.maxPrice,
        'limit_results': params.limit,
        'offset_results': params.offset,
      });

      if (response == null) return [];

      return (response as List)
          .map((data) => PartAdvertisementModel.fromSupabase(data))
          .toList();
    } catch (e) {
      throw ServerException('Erreur lors de la recherche: $e');
    }
  }

  @override
  Future<PartAdvertisementModel> updatePartAdvertisement(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await client
          .from('part_advertisements')
          .update({
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return PartAdvertisementModel.fromSupabase(response);
    } catch (e) {
      throw ServerException('Erreur lors de la mise à jour: $e');
    }
  }

  @override
  Future<void> deletePartAdvertisement(String id) async {
    try {
      await client
          .from('part_advertisements')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerException('Erreur lors de la suppression: $e');
    }
  }

  @override
  Future<void> markAsSold(String id) async {
    try {
      await client
          .from('part_advertisements')
          .update({
            'status': 'sold',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw ServerException('Erreur lors du marquage: $e');
    }
  }

  @override
  Future<void> incrementViewCount(String id) async {
    try {
      await client.rpc('increment_view_count', params: {'ad_id': id});
    } catch (e) {
      // Pas critique, on peut ignorer l'erreur
      print('Erreur lors de l\'incrémentation des vues: $e');
    }
  }

  @override
  Future<void> incrementContactCount(String id) async {
    try {
      await client.rpc('increment_contact_count', params: {'ad_id': id});
    } catch (e) {
      // Pas critique, on peut ignorer l'erreur
      print('Erreur lors de l\'incrémentation des contacts: $e');
    }
  }
}