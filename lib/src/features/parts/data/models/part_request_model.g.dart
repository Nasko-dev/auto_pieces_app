// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartRequestModelImpl _$$PartRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PartRequestModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      vehicleBrand: json['vehicle_brand'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehicleYear: (json['vehicle_year'] as num?)?.toInt(),
      vehicleEngine: json['vehicle_engine'] as String?,
      partType: json['part_type'] as String,
      partNames: (json['part_names'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      additionalInfo: json['additional_info'] as String?,
      status: json['status'] as String? ?? 'active',
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      responseCount: (json['response_count'] as num?)?.toInt() ?? 0,
      pendingResponseCount:
          (json['pending_response_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$$PartRequestModelImplToJson(
        _$PartRequestModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'vehicle_plate': instance.vehiclePlate,
      'vehicle_brand': instance.vehicleBrand,
      'vehicle_model': instance.vehicleModel,
      'vehicle_year': instance.vehicleYear,
      'vehicle_engine': instance.vehicleEngine,
      'part_type': instance.partType,
      'part_names': instance.partNames,
      'additional_info': instance.additionalInfo,
      'status': instance.status,
      'is_anonymous': instance.isAnonymous,
      'response_count': instance.responseCount,
      'pending_response_count': instance.pendingResponseCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
    };
