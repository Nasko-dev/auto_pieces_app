import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/part_request.dart';

part 'part_request_model.freezed.dart';

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
    @Default(false) bool isSellerRequest,
    @Default(0) int responseCount,
    @Default(0) int pendingResponseCount,

    // Timestamps
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? expiresAt,
  }) = _PartRequestModel;

  const PartRequestModel._();

  factory PartRequestModel.fromJson(Map<String, dynamic> json) {
    return PartRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      vehicleBrand: json['vehicle_brand'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehicleYear: json['vehicle_year'] as int?,
      vehicleEngine: json['vehicle_engine'] as String?,
      partType: json['part_type'] as String,
      partNames: (json['part_names'] as List).cast<String>(),
      additionalInfo: json['additional_info'] as String?,
      status: json['status'] as String? ?? 'active',
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      isSellerRequest: json['is_seller_request'] as bool? ?? false,
      responseCount: json['response_count'] as int? ?? 0,
      pendingResponseCount: json['pending_response_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_plate': vehiclePlate,
      'vehicle_brand': vehicleBrand,
      'vehicle_model': vehicleModel,
      'vehicle_year': vehicleYear,
      'vehicle_engine': vehicleEngine,
      'part_type': partType,
      'part_names': partNames,
      'additional_info': additionalInfo,
      'status': status,
      'is_anonymous': isAnonymous,
      'is_seller_request': isSellerRequest,
      'response_count': responseCount,
      'pending_response_count': pendingResponseCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

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
      isSellerRequest: isSellerRequest,
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
      // 'is_seller_request': params.isSellerRequest, // Temporairement commenté pour test
      'status': 'active',
    };
  }
}