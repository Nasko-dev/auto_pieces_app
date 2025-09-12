// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerResponseModel _$SellerResponseModelFromJson(Map<String, dynamic> json) =>
    SellerResponseModel(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      sellerId: json['seller_id'] as String,
      message: json['message'] as String,
      price: (json['price'] as num?)?.toDouble(),
      availability: json['availability'] as String?,
      estimatedDeliveryDays: (json['estimated_delivery_days'] as num?)?.toInt(),
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$SellerResponseModelToJson(
        SellerResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'request_id': instance.requestId,
      'seller_id': instance.sellerId,
      'message': instance.message,
      'price': instance.price,
      'availability': instance.availability,
      'estimated_delivery_days': instance.estimatedDeliveryDays,
      'attachments': instance.attachments,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
