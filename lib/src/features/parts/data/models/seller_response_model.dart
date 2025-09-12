import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/seller_response.dart';

part 'seller_response_model.g.dart';

@JsonSerializable()
class SellerResponseModel {
  final String id;
  @JsonKey(name: 'request_id')
  final String requestId;
  @JsonKey(name: 'seller_id')
  final String sellerId;
  final String message;
  final double? price;
  final String? availability;
  @JsonKey(name: 'estimated_delivery_days')
  final int? estimatedDeliveryDays;
  final List<String> attachments;
  final String status;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const SellerResponseModel({
    required this.id,
    required this.requestId,
    required this.sellerId,
    required this.message,
    this.price,
    this.availability,
    this.estimatedDeliveryDays,
    required this.attachments,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SellerResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SellerResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SellerResponseModelToJson(this);

  SellerResponse toEntity() {
    return SellerResponse(
      id: id,
      requestId: requestId,
      sellerId: sellerId,
      sellerName: null, // Sera rempli par jointure
      sellerCompany: null, // Sera rempli par jointure
      sellerEmail: null, // Sera rempli par jointure
      sellerPhone: null, // Sera rempli par jointure
      message: message,
      price: price,
      availability: availability,
      estimatedDeliveryDays: estimatedDeliveryDays,
      attachments: attachments,
      status: status,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static Map<String, dynamic> toCreateJson({
    required String requestId,
    required String sellerId,
    required String message,
    double? price,
    String? availability,
    int? estimatedDeliveryDays,
    List<String>? attachments,
  }) {
    return {
      'request_id': requestId,
      'seller_id': sellerId,
      'message': message,
      if (price != null) 'price': price,
      if (availability != null) 'availability': availability,
      if (estimatedDeliveryDays != null) 'estimated_delivery_days': estimatedDeliveryDays,
      if (attachments != null) 'attachments': attachments,
      'status': 'pending',
    };
  }
}