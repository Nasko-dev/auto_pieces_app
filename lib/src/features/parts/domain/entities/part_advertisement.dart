import 'package:equatable/equatable.dart';

class PartAdvertisement extends Equatable {
  final String id;
  final String userId;
  final String partType; // 'moteur', 'carrosserie', 'lesdeux'
  final String partName;
  final String? vehiclePlate;
  final String? vehicleBrand;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? vehicleEngine;
  final String? description;
  final double? price;
  final String? condition; // 'neuf', 'bon', 'moyen', 'pour-pieces'
  final List<String> images;
  final String status; // 'active', 'sold', 'inactive'
  final int quantityTotal;
  final int quantityAvailable;
  final int quantitySold;
  final int? lowStockThreshold;
  final bool autoMarkSoldWhenEmpty;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PartAdvertisement({
    required this.id,
    required this.userId,
    required this.partType,
    required this.partName,
    this.vehiclePlate,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleEngine,
    this.description,
    this.price,
    this.condition,
    this.images = const [],
    this.status = 'active',
    this.quantityTotal = 1,
    this.quantityAvailable = 1,
    this.quantitySold = 0,
    this.lowStockThreshold,
    this.autoMarkSoldWhenEmpty = true,
    required this.createdAt,
    this.updatedAt,
  });

  PartAdvertisement copyWith({
    String? id,
    String? userId,
    String? partType,
    String? partName,
    String? vehiclePlate,
    String? vehicleBrand,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleEngine,
    String? description,
    double? price,
    String? condition,
    List<String>? images,
    String? status,
    int? quantityTotal,
    int? quantityAvailable,
    int? quantitySold,
    int? lowStockThreshold,
    bool? autoMarkSoldWhenEmpty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartAdvertisement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partType: partType ?? this.partType,
      partName: partName ?? this.partName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleEngine: vehicleEngine ?? this.vehicleEngine,
      description: description ?? this.description,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      images: images ?? this.images,
      status: status ?? this.status,
      quantityTotal: quantityTotal ?? this.quantityTotal,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      quantitySold: quantitySold ?? this.quantitySold,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      autoMarkSoldWhenEmpty:
          autoMarkSoldWhenEmpty ?? this.autoMarkSoldWhenEmpty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        partType,
        partName,
        vehiclePlate,
        vehicleBrand,
        vehicleModel,
        vehicleYear,
        vehicleEngine,
        description,
        price,
        condition,
        images,
        status,
        quantityTotal,
        quantityAvailable,
        quantitySold,
        lowStockThreshold,
        autoMarkSoldWhenEmpty,
        createdAt,
        updatedAt,
      ];
}
