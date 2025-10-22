import 'package:freezed_annotation/freezed_annotation.dart';

part 'part_request.freezed.dart';

@freezed
class PartRequest with _$PartRequest {
  const factory PartRequest({
    required String id,
    String? userId,

    // Informations du véhicule
    String? vehiclePlate,
    String? vehicleBrand,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleEngine,

    // Type de pièce recherchée
    required String partType, // 'engine' ou 'body'
    required List<String> partNames,
    String? additionalInfo,

    // Métadonnées
    @Default('active') String status, // 'active', 'closed', 'fulfilled'
    @Default(false) bool isAnonymous,
    @Default(false)
    bool isSellerRequest, // Indique si la demande vient d'un vendeur
    @Default(0) int responseCount,
    @Default(0) int pendingResponseCount,

    // Timestamps
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? expiresAt,
  }) = _PartRequest;

  const PartRequest._();

  // Getters utiles
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isActive => status == 'active' && !isExpired;
  bool get hasResponses => responseCount > 0;
  String get vehicleInfo {
    // Afficher TOUJOURS marque + modèle + année + motorisation (si disponibles)
    final parts = <String>[];

    if (vehicleBrand != null) parts.add(vehicleBrand!);
    if (vehicleModel != null) parts.add(vehicleModel!);
    if (vehicleYear != null) parts.add(vehicleYear.toString());
    if (vehicleEngine != null) parts.add(vehicleEngine!);

    return parts.isNotEmpty ? parts.join(' - ') : 'Véhicule non spécifié';
  }
}

@freezed
class CreatePartRequestParams with _$CreatePartRequestParams {
  const factory CreatePartRequestParams({
    // Informations du véhicule
    String? vehiclePlate,
    String? vehicleBrand,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleEngine,

    // Type de pièce recherchée
    required String partType,
    required List<String> partNames,
    String? additionalInfo,

    // Métadonnées
    @Default(false) bool isAnonymous,
    @Default(false)
    bool isSellerRequest, // Indique si la demande vient d'un vendeur
  }) = _CreatePartRequestParams;
}
