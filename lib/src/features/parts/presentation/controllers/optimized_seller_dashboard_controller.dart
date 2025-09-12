import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/part_request.dart';
import '../../../../core/services/optimized_supabase_service.dart';
import '../../../../core/utils/performance_monitor.dart';
import '../../../../core/utils/paginated_list.dart';

part 'optimized_seller_dashboard_controller.freezed.dart';

@freezed
class OptimizedDashboardState with _$OptimizedDashboardState {
  const factory OptimizedDashboardState.initial() = _Initial;
  const factory OptimizedDashboardState.loading() = _Loading;
  const factory OptimizedDashboardState.loaded({
    required List<DashboardNotification> notifications,
    required int totalCount,
    required bool hasMoreData,
  }) = _Loaded;
  const factory OptimizedDashboardState.error(String message) = _Error;
}

@freezed
class DashboardNotification with _$DashboardNotification {
  const factory DashboardNotification({
    required PartRequest partRequest,
    required DateTime timestamp,
    required NotificationPriority priority,
    @Default(false) bool isRead,
  }) = _DashboardNotification;
}

enum NotificationPriority { low, medium, high, urgent }

class OptimizedSellerDashboardController extends StateNotifier<OptimizedDashboardState> {
  OptimizedSellerDashboardController() : super(const OptimizedDashboardState.initial()) {
    _initializePaginatedList();
  }

  final _supabaseService = OptimizedSupabaseService();
  final _performanceMonitor = PerformanceMonitor();
  late final PaginatedList<DashboardNotification> _paginatedNotifications;

  void _initializePaginatedList() {
    _paginatedNotifications = PaginatedList<DashboardNotification>(
      fetchPage: _fetchNotificationsPage,
      pageSize: 15, // Taille optimale pour mobile
    );

    // Écouter les changements de la liste paginée
    _paginatedNotifications.stream.listen((notifications) {
      if (mounted) {
        state = OptimizedDashboardState.loaded(
          notifications: notifications,
          totalCount: notifications.length,
          hasMoreData: _paginatedNotifications.hasMoreData,
        );
      }
    });
  }

  Future<List<DashboardNotification>> _fetchNotificationsPage(int offset, int limit) async {
    return await _performanceMonitor.measureAsync(
      'dashboard_fetch_notifications',
      () async {
        try {
          // Récupérer les demandes de pièces avec cache
          final requestsData = await _supabaseService.getPartRequests(
            offset: offset,
            limit: limit,
            useCache: true,
          );

          // Convertir en notifications avec priorité
          return requestsData.map((data) => _mapToNotification(data)).toList();
        } catch (e) {
          throw Exception('Erreur lors du chargement des notifications: $e');
        }
      },
    );
  }

  DashboardNotification _mapToNotification(Map<String, dynamic> data) {
    final partRequest = PartRequest(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      vehicleBrand: data['vehicle_brand'] ?? '',
      vehicleModel: data['vehicle_model'] ?? '',
      partType: data['part_type'] ?? '',
      partNames: List<String>.from(data['part_names'] ?? []),
      additionalInfo: data['additional_info'],
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updated_at'] ?? DateTime.now().toIso8601String()),
    );

    // Calculer la priorité basée sur l'âge et le type de pièce
    final priority = _calculatePriority(partRequest);

    return DashboardNotification(
      partRequest: partRequest,
      timestamp: partRequest.createdAt,
      priority: priority,
      isRead: false, // TODO: Implémenter le statut de lecture
    );
  }

  NotificationPriority _calculatePriority(PartRequest request) {
    final now = DateTime.now();
    final age = now.difference(request.createdAt);

    // Pièces critiques (sécurité)
    final criticalParts = ['Frein', 'Direction', 'Suspension', 'Moteur'];
    final isCritical = criticalParts.any((part) => 
        request.partType.toLowerCase().contains(part.toLowerCase()) ||
        request.partNames.any((name) => name.toLowerCase().contains(part.toLowerCase())));

    if (isCritical) {
      return age.inHours < 2 ? NotificationPriority.urgent : NotificationPriority.high;
    }

    // Basé sur l'âge
    if (age.inMinutes < 30) return NotificationPriority.high;
    if (age.inHours < 2) return NotificationPriority.medium;
    return NotificationPriority.low;
  }

  /// Charge les notifications initiales
  Future<void> loadNotifications() async {
    if (state is! OptimizedDashboardState.loading) {
      state = const OptimizedDashboardState.loading();
    }
    
    try {
      await _paginatedNotifications.loadInitial();
    } catch (e) {
      state = OptimizedDashboardState.error(e.toString());
    }
  }

  /// Charge plus de notifications
  Future<void> loadMoreNotifications() async {
    await _paginatedNotifications.loadMore();
  }

  /// Actualise les notifications
  Future<void> refreshNotifications() async {
    await _performanceMonitor.measureAsync(
      'dashboard_refresh',
      () => _paginatedNotifications.refresh(),
    );
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    await _performanceMonitor.measureAsync('mark_notification_read', () async {
      // TODO: Implémenter le marquage comme lu en base
      // Pour l'instant, juste update local
      final currentState = state;
      if (currentState is _Loaded) {
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.partRequest.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        state = currentState.copyWith(notifications: updatedNotifications);
      }
    });
  }

  /// Obtient les statistiques de performance
  Map<String, dynamic> getPerformanceStats() {
    return _performanceMonitor.exportMetrics();
  }

  @override
  void dispose() {
    _paginatedNotifications.dispose();
    super.dispose();
  }
}

// Provider
final optimizedSellerDashboardControllerProvider = 
    StateNotifierProvider<OptimizedSellerDashboardController, OptimizedDashboardState>(
  (ref) => OptimizedSellerDashboardController(),
);

// Provider pour la liste paginée
final dashboardNotificationsPaginatedProvider = Provider<PaginatedList<DashboardNotification>>(
  (ref) {
    final controller = ref.watch(optimizedSellerDashboardControllerProvider.notifier);
    return controller._paginatedNotifications;
  },
);