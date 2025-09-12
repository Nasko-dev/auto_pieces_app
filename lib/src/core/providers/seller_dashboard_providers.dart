import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'part_request_providers.dart';
import '../../features/parts/domain/usecases/get_seller_notifications.dart';
import '../../features/parts/presentation/controllers/seller_dashboard_controller.dart';

// Use case provider
final getSellerNotificationsProvider = Provider<GetSellerNotifications>((ref) {
  final repository = ref.watch(partRequestRepositoryProvider);
  return GetSellerNotifications(repository);
});

// Controller provider  
final sellerDashboardControllerProvider = StateNotifierProvider<SellerDashboardController, SellerDashboardState>((ref) {
  final getSellerNotifications = ref.watch(getSellerNotificationsProvider);
  
  return SellerDashboardController(
    getSellerNotifications: getSellerNotifications,
  );
});