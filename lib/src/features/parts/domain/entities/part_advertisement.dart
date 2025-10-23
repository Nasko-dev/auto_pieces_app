import 'package:equatable/equatable.dart';

class PartAdvertisement extends Equatable {
  final String id;
  final String userId;
  final String partType; // 'moteur', 'carrosserie', 'lesdeux'
  final String partName;
  final String? title; // Titre personnalisé (optionnel)
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

  // Gestion de stock
  final String stockType; // 'single', 'multiple', 'unlimited'
  final int? quantity; // NULL si unlimited
  final int? initialQuantity;
  final int soldQuantity;
  final int reservedQuantity;
  final int lowStockThreshold;
  final bool autoDisableWhenEmpty;
  final bool stockAlertEnabled;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const PartAdvertisement({
    required this.id,
    required this.userId,
    required this.partType,
    required this.partName,
    this.title,
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
    this.stockType = 'single',
    this.quantity,
    this.initialQuantity,
    this.soldQuantity = 0,
    this.reservedQuantity = 0,
    this.lowStockThreshold = 1,
    this.autoDisableWhenEmpty = true,
    this.stockAlertEnabled = true,
    required this.createdAt,
    this.updatedAt,
  });

  PartAdvertisement copyWith({
    String? id,
    String? userId,
    String? partType,
    String? partName,
    String? title,
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
    String? stockType,
    int? quantity,
    int? initialQuantity,
    int? soldQuantity,
    int? reservedQuantity,
    int? lowStockThreshold,
    bool? autoDisableWhenEmpty,
    bool? stockAlertEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartAdvertisement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partType: partType ?? this.partType,
      partName: partName ?? this.partName,
      title: title ?? this.title,
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
      stockType: stockType ?? this.stockType,
      quantity: quantity ?? this.quantity,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      autoDisableWhenEmpty: autoDisableWhenEmpty ?? this.autoDisableWhenEmpty,
      stockAlertEnabled: stockAlertEnabled ?? this.stockAlertEnabled,
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
        title,
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
        stockType,
        quantity,
        initialQuantity,
        soldQuantity,
        reservedQuantity,
        lowStockThreshold,
        autoDisableWhenEmpty,
        stockAlertEnabled,
        createdAt,
        updatedAt,
      ];

  // Getters utiles pour la gestion de stock
  int get availableQuantity {
    if (stockType == 'unlimited') return 999999; // Stock infini
    return (quantity ?? 0) - reservedQuantity;
  }

  bool get isLowStock {
    if (stockType == 'unlimited') return false;
    return availableQuantity <= lowStockThreshold;
  }

  bool get isOutOfStock {
    if (stockType == 'unlimited') return false;
    return availableQuantity == 0;
  }

  bool get isInStock {
    if (stockType == 'unlimited') return true;
    return availableQuantity > 0;
  }
}
