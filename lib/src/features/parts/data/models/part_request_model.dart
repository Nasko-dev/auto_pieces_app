import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/part_request.dart';

part 'part_request_model.freezed.dart';
part 'part_request_model.g.dart';

@freezed
class PartRequestModel with _$PartRequestModel {
  const factory PartRequestModel({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    
    // Informations du véhicule
    @JsonKey(name: 'vehicle_plate') String? vehiclePlate,
    @JsonKey(name: 'vehicle_brand') String? vehicleBrand,
    @JsonKey(name: 'vehicle_model') String? vehicleModel,
    @JsonKey(name: 'vehicle_year') int? vehicleYear,
    @JsonKey(name: 'vehicle_engine') String? vehicleEngine,
    
    // Type de pièce recherchée
    @JsonKey(name: 'part_type') required String partType,
    @JsonKey(name: 'part_names') required List<String> partNames,
    @JsonKey(name: 'additional_info') String? additionalInfo,
    
    // Métadonnées
    @Default('active') String status,
    @JsonKey(name: 'is_anonymous') @Default(false) bool isAnonymous,
    @JsonKey(name: 'response_count') @Default(0) int responseCount,
    @JsonKey(name: 'pending_response_count') @Default(0) int pendingResponseCount,
    
    // Timestamps
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
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