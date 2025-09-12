// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_rejection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerRejectionModel _$SellerRejectionModelFromJson(
        Map<String, dynamic> json) =>
    SellerRejectionModel(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      partRequestId: json['part_request_id'] as String,
      rejectedAt: json['rejected_at'] as String,
      reason: json['reason'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$SellerRejectionModelToJson(
        SellerRejectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seller_id': instance.sellerId,
      'part_request_id': instance.partRequestId,
      'rejected_at': instance.rejectedAt,
      'reason': instance.reason,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
