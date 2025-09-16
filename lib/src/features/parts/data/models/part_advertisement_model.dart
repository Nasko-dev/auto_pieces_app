import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/part_advertisement.dart';

part 'part_advertisement_model.freezed.dart';
part 'part_advertisement_model.g.dart';

@freezed
class PartAdvertisementModel with _$PartAdvertisementModel {
  const factory PartAdvertisementModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'part_type') required String partType,
    @JsonKey(name: 'part_name') required String partName,
    @JsonKey(name: 'vehicle_plate') String? vehiclePlate,
    @JsonKey(name: 'vehicle_brand') String? vehicleBrand,
    @JsonKey(name: 'vehicle_model') String? vehicleModel,
    @JsonKey(name: 'vehicle_year') int? vehicleYear,
    @JsonKey(name: 'vehicle_engine') String? vehicleEngine,
    String? description,
    double? price,
    String? condition,
    @Default([]) List<String> images,
    @Default('active') String status,
    @JsonKey(name: 'is_negotiable') @Default(true) bool isNegotiable,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'contact_email') String? contactEmail,
    String? city,
    @JsonKey(name: 'zip_code') String? zipCode,
    String? department,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'contact_count') @Default(0) int contactCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _PartAdvertisementModel;

  const PartAdvertisementModel._();

  factory PartAdvertisementModel.fromJson(Map<String, dynamic> json) => _$PartAdvertisementModelFromJson(json);

  // Conversion vers l'entité domain
  PartAdvertisement toEntity() {
    return PartAdvertisement(
      id: id,
      userId: userId,
      partType: partType,
      partName: partName,
      vehiclePlate: vehiclePlate,
      vehicleBrand: vehicleBrand,
      vehicleModel: vehicleModel,
      vehicleYear: vehicleYear,
      vehicleEngine: vehicleEngine,
      description: description,
      price: price,
      condition: condition,
      images: images,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Factory depuis l'entité domain
  factory PartAdvertisementModel.fromEntity(PartAdvertisement entity) {
    return PartAdvertisementModel(
      id: entity.id,
      userId: entity.userId,
      partType: entity.partType,
      partName: entity.partName,
      vehiclePlate: entity.vehiclePlate,
      vehicleBrand: entity.vehicleBrand,
      vehicleModel: entity.vehicleModel,
      vehicleYear: entity.vehicleYear,
      vehicleEngine: entity.vehicleEngine,
      description: entity.description,
      price: entity.price,
      condition: entity.condition,
      images: entity.images,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt ?? entity.createdAt,
    );
  }

  // Factory depuis les données Supabase
  factory PartAdvertisementModel.fromSupabase(Map<String, dynamic> data) {
    return PartAdvertisementModel(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      partType: data['part_type'] as String,
      partName: data['part_name'] as String,
      vehiclePlate: data['vehicle_plate'] as String?,
      vehicleBrand: data['vehicle_brand'] as String?,
      vehicleModel: data['vehicle_model'] as String?,
      vehicleYear: data['vehicle_year'] as int?,
      vehicleEngine: data['vehicle_engine'] as String?,
      description: data['description'] as String?,
      price: (data['price'] as num?)?.toDouble(),
      condition: data['condition'] as String?,
      images: (data['images'] as List<dynamic>?)?.cast<String>() ?? [],
      status: data['status'] as String? ?? 'active',
      isNegotiable: data['is_negotiable'] as bool? ?? true,
      contactPhone: data['contact_phone'] as String?,
      contactEmail: data['contact_email'] as String?,
      city: data['city'] as String?,
      zipCode: data['zip_code'] as String?,
      department: data['department'] as String?,
      viewCount: data['view_count'] as int? ?? 0,
      contactCount: data['contact_count'] as int? ?? 0,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      expiresAt: data['expires_at'] != null ? DateTime.parse(data['expires_at'] as String) : null,
    );
  }

  // Conversion vers les données Supabase pour insertion
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'part_type': partType,
      'part_name': partName,
      'vehicle_plate': vehiclePlate,
      'vehicle_brand': vehicleBrand,
      'vehicle_model': vehicleModel,
      'vehicle_year': vehicleYear,
      'vehicle_engine': vehicleEngine,
      'description': description,
      'price': price,
      'condition': condition,
      'images': images,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'city': city,
      'zip_code': zipCode,
      'department': department,
    };
  }
}

// Paramètres pour créer une annonce (compatibles avec le front-end existant)
@freezed
class CreatePartAdvertisementParams with _$CreatePartAdvertisementParams {
  const factory CreatePartAdvertisementParams({
    required String partType, // 'engine' ou 'body' depuis le front
    required String partName,
    String? vehiclePlate,
    String? vehicleBrand,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleEngine,
    String? description,
    double? price,
    String? condition,
    @Default([]) List<String> images,
    String? contactPhone,
    String? contactEmail,
  }) = _CreatePartAdvertisementParams;

  factory CreatePartAdvertisementParams.fromJson(Map<String, dynamic> json) => 
      _$CreatePartAdvertisementParamsFromJson(json);
}

// Paramètres de recherche
@freezed
class SearchPartAdvertisementsParams with _$SearchPartAdvertisementsParams {
  const factory SearchPartAdvertisementsParams({
    String? query,
    String? partType,
    String? city,
    double? minPrice,
    double? maxPrice,
    @Default(20) int limit,
    @Default(0) int offset,
  }) = _SearchPartAdvertisementsParams;

  factory SearchPartAdvertisementsParams.fromJson(Map<String, dynamic> json) => 
      _$SearchPartAdvertisementsParamsFromJson(json);
}