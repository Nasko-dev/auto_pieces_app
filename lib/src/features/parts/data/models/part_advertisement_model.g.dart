// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_advertisement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartAdvertisementModelImpl _$$PartAdvertisementModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PartAdvertisementModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
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
      status: json['status'] as String? ?? 'active',
      isNegotiable: json['isNegotiable'] as bool? ?? true,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      city: json['city'] as String?,
      zipCode: json['zipCode'] as String?,
      department: json['department'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      contactCount: (json['contactCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$PartAdvertisementModelImplToJson(
        _$PartAdvertisementModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
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
      'status': instance.status,
      'isNegotiable': instance.isNegotiable,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'city': instance.city,
      'zipCode': instance.zipCode,
      'department': instance.department,
      'viewCount': instance.viewCount,
      'contactCount': instance.contactCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
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
