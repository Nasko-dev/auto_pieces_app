import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/parts/data/datasources/part_advertisement_remote_datasource.dart';
import '../../features/parts/data/repositories/part_advertisement_repository_impl.dart';
import '../../features/parts/domain/entities/part_advertisement.dart';
import '../../features/parts/domain/repositories/part_advertisement_repository.dart';
import '../../features/parts/data/models/part_advertisement_model.dart'
    as models;
import '../network/network_info.dart';
import 'particulier_auth_providers.dart' show deviceServiceProvider;

// Providers de base
final partAdvertisementRemoteDataSourceProvider =
    Provider<PartAdvertisementRemoteDataSource>((ref) {
  final client = Supabase.instance.client;
  final deviceService = ref.watch(deviceServiceProvider);
  return PartAdvertisementRemoteDataSourceImpl(
    client: client,
    deviceService: deviceService,
  );
});

final partAdvertisementRepositoryProvider =
    Provider<PartAdvertisementRepository>((ref) {
  final remoteDataSource = ref.watch(partAdvertisementRemoteDataSourceProvider);
  final networkInfo = NetworkInfoImpl();

  return PartAdvertisementRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Provider pour créer une annonce
final createPartAdvertisementProvider = FutureProvider.family<PartAdvertisement,
    models.CreatePartAdvertisementParams>(
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
final partAdvertisementByIdProvider =
    FutureProvider.family<PartAdvertisement, String>(
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
final myPartAdvertisementsProvider =
    FutureProvider<List<PartAdvertisement>>((ref) async {
  final repository = ref.watch(partAdvertisementRepositoryProvider);

  final result = await repository.getMyPartAdvertisements();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (advertisements) => advertisements,
  );
});

// Provider pour rechercher des annonces
final searchPartAdvertisementsProvider = FutureProvider.family<
    List<PartAdvertisement>, models.SearchPartAdvertisementsParams>(
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

// Provider pour détecter si le particulier a des annonces actives
final hasActiveAdvertisementsProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final repository = ref.watch(partAdvertisementRepositoryProvider);

  final result = await repository.getMyPartAdvertisements();

  return result.fold(
    (failure) =>
        false, // En cas d'erreur, on considère qu'il n'y a pas d'annonces
    (advertisements) => advertisements.any((ad) => ad.status == 'active'),
  );
});
