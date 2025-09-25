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
    @Default(false) bool isSellerRequest, // Indique si la demande vient d'un vendeur
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
    // Pour les pièces de carrosserie : afficher marque + modèle + année
    if (partType == 'body') {
      final parts = <String>[];
      if (vehicleBrand != null) parts.add(vehicleBrand!);
      if (vehicleModel != null) parts.add(vehicleModel!);
      if (vehicleYear != null) parts.add(vehicleYear.toString());
      return parts.join(' ');
    }
    
    // Pour les pièces de moteur : afficher seulement la motorisation
    if (partType == 'engine') {
      if (vehicleEngine != null) {
        return vehicleEngine!;
      }
    }
    
    // Fallback : afficher ce qui est disponible
    final parts = <String>[];
    if (vehicleBrand != null) parts.add(vehicleBrand!);
    if (vehicleModel != null) parts.add(vehicleModel!);
    if (vehicleYear != null) parts.add(vehicleYear.toString());
    
    if (parts.isEmpty && vehicleEngine != null) {
      return vehicleEngine!;
    }
    
    return parts.join(' ');
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
    @Default(false) bool isSellerRequest, // Indique si la demande vient d'un vendeur
  }) = _CreatePartRequestParams;
}