import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../network/supabase_client.dart';

// Network Providers
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final supabaseClientProvider = Provider((ref) {
  return SupabaseConfig.client;
});