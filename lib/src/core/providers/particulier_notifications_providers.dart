import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'part_request_providers.dart';
import '../../features/parts/domain/usecases/get_seller_notifications.dart';
import '../../features/parts/presentation/controllers/seller_dashboard_controller.dart';

// Use case provider pour les notifications particulier (réutilise le même que vendeur)
final getParticulierNotificationsProvider =
    Provider<GetSellerNotifications>((ref) {
  final repository = ref.watch(partRequestRepositoryProvider);
  return GetSellerNotifications(repository);
});

// Controller provider pour les notifications particulier
final particulierNotificationsControllerProvider =
    StateNotifierProvider<SellerDashboardController, SellerDashboardState>(
        (ref) {
  final getNotifications = ref.watch(getParticulierNotificationsProvider);

  return SellerDashboardController(
    getSellerNotifications: getNotifications,
  );
});
