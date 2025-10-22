import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/network_info.dart';
import '../../features/parts/data/datasources/seller_settings_remote_datasource.dart';
import '../../features/parts/data/repositories/seller_settings_repository_impl.dart';
import '../../features/parts/domain/repositories/seller_settings_repository.dart';
import '../../features/parts/domain/usecases/get_seller_settings.dart';
import '../../features/parts/domain/usecases/save_seller_settings.dart';

// DataSource
final sellerSettingsRemoteDataSourceProvider =
    Provider<SellerSettingsRemoteDataSource>((ref) {
  return SellerSettingsRemoteDataSourceImpl(
    Supabase.instance.client,
  );
});

// Repository
final sellerSettingsRepositoryProvider =
    Provider<SellerSettingsRepository>((ref) {
  return SellerSettingsRepositoryImpl(
    remoteDataSource: ref.watch(sellerSettingsRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use Cases
final getSellerSettingsProvider = Provider<GetSellerSettings>((ref) {
  return GetSellerSettings(ref.watch(sellerSettingsRepositoryProvider));
});

final saveSellerSettingsProvider = Provider<SaveSellerSettings>((ref) {
  return SaveSellerSettings(ref.watch(sellerSettingsRepositoryProvider));
});
