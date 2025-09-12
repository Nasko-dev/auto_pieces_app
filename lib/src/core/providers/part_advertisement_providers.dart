import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/parts/data/datasources/part_advertisement_remote_datasource.dart';
import '../../features/parts/data/repositories/part_advertisement_repository_impl.dart';
import '../../features/parts/domain/entities/part_advertisement.dart';
import '../../features/parts/domain/repositories/part_advertisement_repository.dart';
import '../../features/parts/data/models/part_advertisement_model.dart';
import '../network/network_info.dart';

// Providers de base
final partAdvertisementRemoteDataSourceProvider = Provider<PartAdvertisementRemoteDataSource>((ref) {
  final client = Supabase.instance.client;
  return PartAdvertisementRemoteDataSourceImpl(client: client);
});

final partAdvertisementRepositoryProvider = Provider<PartAdvertisementRepository>((ref) {
  final remoteDataSource = ref.watch(partAdvertisementRemoteDataSourceProvider);
  final networkInfo = NetworkInfoImpl();
  
  return PartAdvertisementRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Provider pour créer une annonce
final createPartAdvertisementProvider = FutureProvider.family<PartAdvertisement, CreatePartAdvertisementParams>(
  (ref, params) async {
    final repository = ref.watch(partAdvertisementRepositoryProvider);
    
    final result = await repository.createPartAdvertisement(params);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (advertisement) => advertisement,
    );
  },
);

// Provider pour obtenir une annonce par ID
final partAdvertisementByIdProvider = FutureProvider.family<PartAdvertisement, String>(
  (ref, id) async {
    final repository = ref.watch(partAdvertisementRepositoryProvider);
    
    final result = await repository.getPartAdvertisementById(id);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (advertisement) => advertisement,
    );
  },
);

// Provider pour obtenir mes annonces
final myPartAdvertisementsProvider = FutureProvider<List<PartAdvertisement>>((ref) async {
  final repository = ref.watch(partAdvertisementRepositoryProvider);
  
  final result = await repository.getMyPartAdvertisements();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (advertisements) => advertisements,
  );
});

// Provider pour rechercher des annonces
final searchPartAdvertisementsProvider = FutureProvider.family<List<PartAdvertisement>, SearchPartAdvertisementsParams>(
  (ref, params) async {
    final repository = ref.watch(partAdvertisementRepositoryProvider);
    
    final result = await repository.searchPartAdvertisements(params);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (advertisements) => advertisements,
    );
  },
);

// Provider pour marquer comme vendu
final markAdvertisementAsSoldProvider = FutureProvider.family<void, String>(
  (ref, id) async {
    final repository = ref.watch(partAdvertisementRepositoryProvider);
    
    final result = await repository.markAsSold(id);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  },
);

// Provider pour supprimer une annonce
final deletePartAdvertisementProvider = FutureProvider.family<void, String>(
  (ref, id) async {
    final repository = ref.watch(partAdvertisementRepositoryProvider);
    
    final result = await repository.deletePartAdvertisement(id);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  },
);