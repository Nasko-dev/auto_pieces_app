import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_advertisement.freezed.dart';

@freezed
class SellerAdvertisement with _$SellerAdvertisement {
  const factory SellerAdvertisement({
    required String id,
    required String sellerId,
    required String title,
    required String description,
    required String partType,
    required String vehicleBrand,
    required String vehicleModel,
    int? vehicleYear,
    required double price,
    required AdvertisementStatus status,
    required List<String> imageUrls,
    @Default(0) int viewCount,
    @Default(0) int messageCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? soldAt,
  }) = _SellerAdvertisement;
}

enum AdvertisementStatus {
  draft,
  active,
  paused,
  sold,
  expired,
}

extension AdvertisementStatusX on AdvertisementStatus {
  String get displayName {
    switch (this) {
      case AdvertisementStatus.draft:
        return 'Brouillon';
      case AdvertisementStatus.active:
        return 'Active';
      case AdvertisementStatus.paused:
        return 'Pausée';
      case AdvertisementStatus.sold:
        return 'Vendue';
      case AdvertisementStatus.expired:
        return 'Expirée';
    }
  }

  bool get canEdit => this != AdvertisementStatus.sold;
  bool get canTogglePause =>
      this == AdvertisementStatus.active || this == AdvertisementStatus.paused;
}
