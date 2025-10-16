import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/part_request.dart';
import '../../domain/usecases/get_seller_notifications.dart';

part 'seller_dashboard_controller.freezed.dart';

class SellerNotification {
  final PartRequest partRequest;
  final bool isNew;
  final DateTime createdAt;

  const SellerNotification({
    required this.partRequest,
    required this.isNew,
    required this.createdAt,
  });

  factory SellerNotification.fromPartRequest(PartRequest partRequest) {
    // Considérer comme nouvelle si créée dans les dernières 24h
    final isNew = DateTime.now().difference(partRequest.createdAt).inHours < 24;

    return SellerNotification(
      partRequest: partRequest,
      isNew: isNew,
      createdAt: partRequest.createdAt,
    );
  }
}

@freezed
class SellerDashboardState with _$SellerDashboardState {
  const factory SellerDashboardState.initial() = _Initial;
  const factory SellerDashboardState.loading() = _Loading;
  const factory SellerDashboardState.loaded({
    required List<SellerNotification> notifications,
    required int unreadCount,
  }) = _Loaded;
  const factory SellerDashboardState.error(String message) = _Error;
}

class SellerDashboardController extends StateNotifier<SellerDashboardState> {
  final GetSellerNotifications _getSellerNotifications;

  SellerDashboardController({
    required GetSellerNotifications getSellerNotifications,
  })  : _getSellerNotifications = getSellerNotifications,
        super(const SellerDashboardState.initial());

  Future<void> loadNotifications() async {
    state = const SellerDashboardState.loading();

    final result = await _getSellerNotifications(NoParams());

    result.fold(
      (failure) {
        state = SellerDashboardState.error(failure.toString());
      },
      (partRequests) {
        final notifications = partRequests
            .map((request) => SellerNotification.fromPartRequest(request))
            .toList();

        final unreadCount = notifications.where((n) => n.isNew).length;

        state = SellerDashboardState.loaded(
          notifications: notifications,
          unreadCount: unreadCount,
        );
      },
    );
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}

// Extension pour faciliter l'utilisation
extension SellerDashboardStateX on SellerDashboardState {
  bool get isLoading => this is _Loading;
  bool get isLoaded => this is _Loaded;
  bool get isError => this is _Error;
  bool get isInitial => this is _Initial;

  List<SellerNotification>? get notifications => mapOrNull(
        loaded: (state) => state.notifications,
      );

  int? get unreadCount => mapOrNull(
        loaded: (state) => state.unreadCount,
      );

  String? get errorMessage => mapOrNull(
        error: (state) => state.message,
      );
}
