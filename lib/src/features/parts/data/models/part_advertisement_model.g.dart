// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_advertisement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartAdvertisementModelImpl _$$PartAdvertisementModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PartAdvertisementModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      partType: json['part_type'] as String,
      partName: json['part_name'] as String,
      vehiclePlate: json['vehicle_plate'] as String?,
      vehicleBrand: json['vehicle_brand'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehicleYear: (json['vehicle_year'] as num?)?.toInt(),
      vehicleEngine: json['vehicle_engine'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      condition: json['condition'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'active',
      isNegotiable: json['is_negotiable'] as bool? ?? true,
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
      city: json['city'] as String?,
      zipCode: json['zip_code'] as String?,
      department: json['department'] as String?,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      contactCount: (json['contact_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$$PartAdvertisementModelImplToJson(
        _$PartAdvertisementModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'part_type': instance.partType,
      'part_name': instance.partName,
      'vehicle_plate': instance.vehiclePlate,
      'vehicle_brand': instance.vehicleBrand,
      'vehicle_model': instance.vehicleModel,
      'vehicle_year': instance.vehicleYear,
      'vehicle_engine': instance.vehicleEngine,
      'description': instance.description,
      'price': instance.price,
      'condition': instance.condition,
      'images': instance.images,
      'status': instance.status,
      'is_negotiable': instance.isNegotiable,
      'contact_phone': instance.contactPhone,
      'contact_email': instance.contactEmail,
      'city': instance.city,
      'zip_code': instance.zipCode,
      'department': instance.department,
      'view_count': instance.viewCount,
      'contact_count': instance.contactCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
    };

_$CreatePartAdvertisementParamsImpl
    _$$CreatePartAdvertisementParamsImplFromJson(Map<String, dynamic> json) =>
        _$CreatePartAdvertisementParamsImpl(
          partType: json['partType'] as String,
          partName: json['partName'] as String,
          vehiclePlate: json['vehiclePlate'] as String?,
          vehicleBrand: json['vehicleBrand'] as String?,
          vehicleModel: json['vehicleModel'] as String?,
          vehicleYear: (json['vehicleYear'] as num?)?.toInt(),
          vehicleEngine: json['vehicleEngine'] as String?,
          description: json['description'] as String?,
          price: (json['price'] as num?)?.toDouble(),
          condition: json['condition'] as String?,
          images: (json['images'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
          contactPhone: json['contactPhone'] as String?,
          contactEmail: json['contactEmail'] as String?,
        );

Map<String, dynamic> _$$CreatePartAdvertisementParamsImplToJson(
        _$CreatePartAdvertisementParamsImpl instance) =>
    <String, dynamic>{
      'partType': instance.partType,
      'partName': instance.partName,
      'vehiclePlate': instance.vehiclePlate,
      'vehicleBrand': instance.vehicleBrand,
      'vehicleModel': instance.vehicleModel,
      'vehicleYear': instance.vehicleYear,
      'vehicleEngine': instance.vehicleEngine,
      'description': instance.description,
      'price': instance.price,
      'condition': instance.condition,
      'images': instance.images,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
    };

_$SearchPartAdvertisementsParamsImpl
    _$$SearchPartAdvertisementsParamsImplFromJson(Map<String, dynamic> json) =>
        _$SearchPartAdvertisementsParamsImpl(
          query: json['query'] as String?,
          partType: json['partType'] as String?,
          city: json['city'] as String?,
          minPrice: (json['minPrice'] as num?)?.toDouble(),
          maxPrice: (json['maxPrice'] as num?)?.toDouble(),
          limit: (json['limit'] as num?)?.toInt() ?? 20,
          offset: (json['offset'] as num?)?.toInt() ?? 0,
        );

Map<String, dynamic> _$$SearchPartAdvertisementsParamsImplToJson(
        _$SearchPartAdvertisementsParamsImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'partType': instance.partType,
      'city': instance.city,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'limit': instance.limit,
      'offset': instance.offset,
    };
