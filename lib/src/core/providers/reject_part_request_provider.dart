import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/parts/domain/usecases/reject_part_request.dart';
import '../../features/parts/data/repositories/part_request_repository_impl.dart';
import '../../features/parts/data/datasources/part_request_remote_datasource.dart';
import '../../features/parts/data/datasources/conversations_remote_datasource.dart';
import '../network/network_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final rejectPartRequestUseCaseProvider =
    Provider<RejectPartRequestUseCase>((ref) {
  return RejectPartRequestUseCase(
    repository: ref.read(partRequestRepositoryProvider),
  );
});

final partRequestRepositoryProvider =
    Provider<PartRequestRepositoryImpl>((ref) {
  return PartRequestRepositoryImpl(
    remoteDataSource: ref.read(partRequestRemoteDataSourceProvider),
    conversationsRemoteDataSource:
        ref.read(conversationsRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final partRequestRemoteDataSourceProvider =
    Provider<PartRequestRemoteDataSourceImpl>((ref) {
  return PartRequestRemoteDataSourceImpl(Supabase.instance.client);
});

final conversationsRemoteDataSourceProvider =
    Provider<ConversationsRemoteDataSource>((ref) {
  return ConversationsRemoteDataSourceImpl(
      supabaseClient: Supabase.instance.client);
});
