import 'package:cente_pice/src/features/parts/domain/entities/part_request.dart';

/// Fixtures pour les tests de part requests
class PartRequestFixtures {
  static final tPartRequest = PartRequest(
    id: 'test-request-id-1',
    userId: 'test-user-id',
    vehiclePlate: 'AB-123-CD',
    vehicleBrand: 'Renault',
    vehicleModel: 'Clio',
    vehicleYear: 2015,
    vehicleEngine: '1.5 dCi',
    partType: 'body',
    partNames: ['Capot', 'Pare-choc avant'],
    additionalInfo: 'Pièces en bon état',
    status: 'active',
    isAnonymous: false,
    isSellerRequest: false,
    responseCount: 0,
    pendingResponseCount: 0,
    createdAt: DateTime(2024, 1, 1, 10, 0),
    updatedAt: DateTime(2024, 1, 1, 10, 0),
    expiresAt: DateTime(2024, 1, 8, 10, 0),
  );

  static final tPartRequestEngine = PartRequest(
    id: 'test-request-id-2',
    userId: 'test-user-id',
    vehicleEngine: '2.0 TDI',
    partType: 'engine',
    partNames: ['Turbo', 'Injecteurs'],
    status: 'active',
    isAnonymous: false,
    isSellerRequest: false,
    responseCount: 0,
    pendingResponseCount: 0,
    createdAt: DateTime(2024, 1, 2, 10, 0),
    updatedAt: DateTime(2024, 1, 2, 10, 0),
    expiresAt: DateTime(2024, 1, 9, 10, 0),
  );

  static final tPartRequestAnonymous = PartRequest(
    id: 'test-request-id-3',
    userId: 'test-user-id',
    partType: 'body',
    partNames: ['Rétroviseur gauche'],
    status: 'active',
    isAnonymous: true,
    isSellerRequest: false,
    responseCount: 0,
    pendingResponseCount: 0,
    createdAt: DateTime(2024, 1, 3, 10, 0),
    updatedAt: DateTime(2024, 1, 3, 10, 0),
    expiresAt: DateTime(2024, 1, 10, 10, 0),
  );

  static final tPartRequestClosed = PartRequest(
    id: 'test-request-id-4',
    userId: 'test-user-id',
    vehiclePlate: 'CD-456-EF',
    vehicleBrand: 'Peugeot',
    vehicleModel: '308',
    vehicleYear: 2018,
    partType: 'body',
    partNames: ['Phare avant droit'],
    status: 'closed',
    isAnonymous: false,
    isSellerRequest: false,
    responseCount: 3,
    pendingResponseCount: 0,
    createdAt: DateTime(2024, 1, 4, 10, 0),
    updatedAt: DateTime(2024, 1, 5, 15, 30),
  );

  static final tPartRequestSellerRequest = PartRequest(
    id: 'test-request-id-5',
    userId: 'test-seller-id',
    vehiclePlate: 'EF-789-GH',
    vehicleBrand: 'Volkswagen',
    vehicleModel: 'Golf',
    vehicleYear: 2020,
    partType: 'body',
    partNames: ['Aile avant gauche'],
    status: 'active',
    isAnonymous: false,
    isSellerRequest: true,
    responseCount: 0,
    pendingResponseCount: 0,
    createdAt: DateTime(2024, 1, 5, 10, 0),
    updatedAt: DateTime(2024, 1, 5, 10, 0),
    expiresAt: DateTime(2024, 1, 12, 10, 0),
  );

  static final tCreatePartRequestParams = CreatePartRequestParams(
    vehiclePlate: 'AB-123-CD',
    vehicleBrand: 'Renault',
    vehicleModel: 'Clio',
    vehicleYear: 2015,
    partType: 'body',
    partNames: ['Capot', 'Pare-choc avant'],
    additionalInfo: 'Pièces en bon état',
    isAnonymous: false,
  );

  static final tCreatePartRequestParamsEngine = CreatePartRequestParams(
    vehicleEngine: '2.0 TDI',
    partType: 'engine',
    partNames: ['Turbo', 'Injecteurs'],
    isAnonymous: false,
  );

  static final tCreatePartRequestParamsAnonymous = CreatePartRequestParams(
    partType: 'body',
    partNames: ['Rétroviseur gauche'],
    isAnonymous: true,
  );

  static List<PartRequest> get tPartRequestList => [
        tPartRequest,
        tPartRequestEngine,
        tPartRequestAnonymous,
        tPartRequestClosed,
      ];
}
