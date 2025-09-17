import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_response.freezed.dart';

@freezed
class SellerResponse with _$SellerResponse {
  const factory SellerResponse({
    required String id,
    required String requestId,
    required String sellerId,
    
    // Informations du vendeur (dénormalisées pour performance)
    String? sellerName,
    String? sellerCompany,
    String? sellerEmail,
    String? sellerPhone,
    
    // Détails de la réponse
    required String message,
    double? price,
    String? availability, // 'available', 'order_needed', 'unavailable'
    int? estimatedDeliveryDays,
    
    // Pièces jointes
    @Default([]) List<String> attachments,
    
    // Status de la réponse
    @Default('pending') String status, // 'pending', 'accepted', 'rejected'
    
    // Timestamps
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SellerResponse;

  const SellerResponse._();

  // Getters utiles
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get hasPrice => price != null && price! > 0;
  bool get isAvailable => availability == 'available';
  
  String get availabilityText {
    switch (availability) {
      case 'available':
        return 'Disponible';
      case 'order_needed':
        return 'Sur commande';
      case 'unavailable':
        return 'Indisponible';
      default:
        return 'Non précisé';
    }
  }
  
  String get deliveryText {
    if (estimatedDeliveryDays == null) return 'Non précisé';
    if (estimatedDeliveryDays! <= 1) return 'Livraison immédiate';
    return '$estimatedDeliveryDays jours';
  }
}