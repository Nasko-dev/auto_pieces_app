import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/seller_rejection.dart';

part 'seller_rejection_model.g.dart';

@JsonSerializable()
class SellerRejectionModel {
  final String id;
  @JsonKey(name: 'seller_id')
  final String sellerId;
  @JsonKey(name: 'part_request_id')
  final String partRequestId;
  @JsonKey(name: 'rejected_at')
  final String rejectedAt;
  final String? reason;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const SellerRejectionModel({
    required this.id,
    required this.sellerId,
    required this.partRequestId,
    required this.rejectedAt,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SellerRejectionModel.fromJson(Map<String, dynamic> json) =>
      _$SellerRejectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SellerRejectionModelToJson(this);

  SellerRejection toEntity() {
    return SellerRejection(
      id: id,
      sellerId: sellerId,
      partRequestId: partRequestId,
      rejectedAt: DateTime.parse(rejectedAt),
      reason: reason,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  factory SellerRejectionModel.fromEntity(SellerRejection entity) {
    return SellerRejectionModel(
      id: entity.id,
      sellerId: entity.sellerId,
      partRequestId: entity.partRequestId,
      rejectedAt: entity.rejectedAt.toIso8601String(),
      reason: entity.reason,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  // Pour les insertions (sans id généré)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id'); // L'ID sera généré par la DB
    return json;
  }
}
