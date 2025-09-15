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
        createdAt,
        updatedAt,
      ];
}