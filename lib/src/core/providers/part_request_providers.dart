import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/network_info.dart';
import '../../features/parts/data/datasources/part_request_remote_datasource.dart';
import '../../features/parts/data/repositories/part_request_repository_impl.dart';
import '../../features/parts/domain/repositories/part_request_repository.dart';
import '../../features/parts/domain/usecases/create_part_request.dart';
import '../../features/parts/domain/usecases/get_user_part_requests.dart';
import '../../features/parts/domain/usecases/get_part_request_responses.dart';

// ========================================
// DataSources
// ========================================
final partRequestRemoteDataSourceProvider = Provider<PartRequestRemoteDataSource>((ref) {
  return PartRequestRemoteDataSourceImpl(Supabase.instance.client);
});

// ========================================
// Repositories
// ========================================
final partRequestRepositoryProvider = Provider<PartRequestRepository>((ref) {
  return PartRequestRepositoryImpl(
    remoteDataSource: ref.read(partRequestRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// ========================================
// Use Cases
// ========================================
final createPartRequestProvider = Provider<CreatePartRequest>((ref) {
  return CreatePartRequest(ref.read(partRequestRepositoryProvider));
});

final getUserPartRequestsProvider = Provider<GetUserPartRequests>((ref) {
  return GetUserPartRequests(ref.read(partRequestRepositoryProvider));
});

final getPartRequestResponsesProvider = Provider<GetPartRequestResponses>((ref) {
  return GetPartRequestResponses(ref.read(partRequestRepositoryProvider));
});