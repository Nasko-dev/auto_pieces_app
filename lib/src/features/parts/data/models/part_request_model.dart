import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/part_request.dart';

part 'part_request_model.freezed.dart';
part 'part_request_model.g.dart';

@freezed
class PartRequestModel with _$PartRequestModel {
  const factory PartRequestModel({
    required String id,
    String? userId,
    
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
    @Default('active') String status,
    @Default(false) bool isAnonymous,
    @Default(0) int responseCount,
    @Default(0) int pendingResponseCount,
    
    // Timestamps
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? expiresAt,
  }) = _PartRequestModel;

  const PartRequestModel._();

  factory PartRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PartRequestModelFromJson(json);

  // Conversion vers l'entité domain
  PartRequest toEntity() {
    return PartRequest(
      id: id,
      userId: userId,
      vehiclePlate: vehiclePlate,
      vehicleBrand: vehicleBrand,
      vehicleModel: vehicleModel,
      vehicleYear: vehicleYear,
      vehicleEngine: vehicleEngine,
      partType: partType,
      partNames: partNames,
      additionalInfo: additionalInfo,
      status: status,
      isAnonymous: isAnonymous,
      responseCount: responseCount,
      pendingResponseCount: pendingResponseCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiresAt: expiresAt,
    );
  }

  // Conversion depuis les paramètres de création
  static Map<String, dynamic> fromCreateParams(CreatePartRequestParams params) {
    return {
      'vehicle_plate': params.vehiclePlate,
      'vehicle_brand': params.vehicleBrand,
      'vehicle_model': params.vehicleModel,
      'vehicle_year': params.vehicleYear,
      'vehicle_engine': params.vehicleEngine,
      'part_type': params.partType,
      'part_names': params.partNames,
      'additional_info': params.additionalInfo,
      'is_anonymous': params.isAnonymous,
      'status': 'active',
    };
  }
}