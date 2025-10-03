import 'package:cente_pice/src/features/parts/domain/entities/seller_response.dart';

/// Fixtures pour les tests de seller responses
class SellerResponseFixtures {
  static final tSellerResponse = SellerResponse(
    id: 'test-response-id-1',
    requestId: 'test-request-id-1',
    sellerId: 'test-seller-id',
    sellerName: 'Jean Dupont',
    sellerCompany: 'Pièces Auto Pro',
    sellerEmail: 'jean@piecesauto.fr',
    sellerPhone: '0612345678',
    message: 'Bonjour, j\'ai les pièces demandées en stock',
    price: 150.0,
    availability: 'available',
    estimatedDeliveryDays: 2,
    attachments: ['https://example.com/piece1.jpg'],
    status: 'pending',
    createdAt: DateTime(2024, 1, 5, 10, 0),
    updatedAt: DateTime(2024, 1, 5, 10, 0),
  );

  static final tSellerResponseAccepted = SellerResponse(
    id: 'test-response-id-2',
    requestId: 'test-request-id-1',
    sellerId: 'test-seller-id-2',
    sellerName: 'Pierre Durand',
    sellerCompany: 'Auto Pièces +',
    message: 'Pièces disponibles sur commande',
    price: 120.0,
    availability: 'order_needed',
    estimatedDeliveryDays: 5,
    status: 'accepted',
    createdAt: DateTime(2024, 1, 4, 14, 0),
    updatedAt: DateTime(2024, 1, 5, 9, 0),
  );

  static final tSellerResponseRejected = SellerResponse(
    id: 'test-response-id-3',
    requestId: 'test-request-id-1',
    sellerId: 'test-seller-id-3',
    sellerName: 'Sophie Bernard',
    message: 'Désolé, je n\'ai pas cette pièce',
    availability: 'unavailable',
    status: 'rejected',
    createdAt: DateTime(2024, 1, 3, 16, 0),
    updatedAt: DateTime(2024, 1, 4, 10, 0),
  );

  static final tSellerResponseNoPrice = SellerResponse(
    id: 'test-response-id-4',
    requestId: 'test-request-id-2',
    sellerId: 'test-seller-id',
    sellerName: 'Jean Dupont',
    message: 'Contactez-moi pour plus d\'informations',
    status: 'pending',
    createdAt: DateTime(2024, 1, 6, 10, 0),
    updatedAt: DateTime(2024, 1, 6, 10, 0),
  );

  static List<SellerResponse> get tSellerResponseList => [
        tSellerResponse,
        tSellerResponseAccepted,
        tSellerResponseRejected,
      ];

  static List<SellerResponse> get tPendingResponses => [
        tSellerResponse,
      ];

  static List<SellerResponse> get tAcceptedResponses => [
        tSellerResponseAccepted,
      ];
}
