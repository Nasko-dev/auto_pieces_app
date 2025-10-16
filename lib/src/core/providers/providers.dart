import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../network/supabase_client.dart';
import '../services/realtime_service.dart';

// Network Providers
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final supabaseClientProvider = Provider((ref) {
  return SupabaseConfig.client;
});

// Realtime Service Provider
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService();
});
