import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/network_info.dart';
import '../../features/auth/data/datasources/seller_auth_remote_datasource.dart';
import '../../features/auth/data/repositories/seller_auth_repository_impl.dart';
import '../../features/auth/domain/repositories/seller_auth_repository.dart';
import '../../features/auth/domain/entities/seller.dart';
import 'particulier_auth_providers.dart';

// Core providers
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

// Data source provider
final sellerAuthRemoteDataSourceProvider = Provider<SellerAuthRemoteDataSource>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SellerAuthRemoteDataSourceImpl(supabaseClient);
});

// Repository provider
final sellerAuthRepositoryProvider = Provider<SellerAuthRepository>((ref) {
  final remoteDataSource = ref.watch(sellerAuthRemoteDataSourceProvider);
  final particulierLocalDataSource = ref.watch(particulierAuthLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  
  return SellerAuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    particulierLocalDataSource: particulierLocalDataSource,
    networkInfo: networkInfo,
  );
});

// Stream provider pour écouter les changements d'auth
final sellerAuthStreamProvider = StreamProvider<AuthState>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return supabaseClient.auth.onAuthStateChange;
});

// Provider pour le vendeur authentifié
final currentSellerProvider = FutureProvider<Seller?>((ref) async {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final repository = ref.watch(sellerAuthRepositoryProvider);


  // Vérifier s'il y a un utilisateur connecté
  final currentUser = supabaseClient.auth.currentUser;
  if (currentUser == null) {
    return null;
  }


  try {
    final result = await repository.getCurrentSeller();
    return result.fold(
      (failure) {
        return null;
      },
      (seller) {
        return seller;
      },
    );
  } catch (e) {
    return null;
  }
});

// Provider alternatif - test direct
final currentSellerProviderAlt = FutureProvider.autoDispose<Seller?>((ref) async {

  final supabaseClient = ref.watch(supabaseClientProvider);
  final repository = ref.watch(sellerAuthRepositoryProvider);

  final currentUser = supabaseClient.auth.currentUser;
  if (currentUser == null) {
    return null;
  }


  final result = await repository.getCurrentSeller();
  return result.fold(
    (failure) {
      return null;
    },
    (seller) {
      return seller;
    },
  );
});