import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/part_request.dart';
import '../entities/seller_response.dart';
import '../entities/seller_rejection.dart';
import '../entities/particulier_conversation.dart';
import '../usecases/create_seller_response.dart';

abstract class PartRequestRepository {
  // Demandes de pièces
  Future<Either<Failure, List<PartRequest>>> getUserPartRequests();
  Future<Either<Failure, PartRequest>> createPartRequest(
      CreatePartRequestParams params);
  Future<Either<Failure, PartRequest>> getPartRequestById(String id);
  Future<Either<Failure, PartRequest>> updatePartRequestStatus(
      String id, String status);
  Future<Either<Failure, void>> deletePartRequest(String id);

  // Vérification demande active
  Future<Either<Failure, bool>> hasActivePartRequest();

  // Réponses des vendeurs
  Future<Either<Failure, List<SellerResponse>>> getPartRequestResponses(
      String requestId);
  Future<Either<Failure, SellerResponse>> createSellerResponse(
      CreateSellerResponseParams params);
  Future<Either<Failure, SellerResponse>> acceptSellerResponse(
      String responseId);
  Future<Either<Failure, SellerResponse>> rejectSellerResponse(
      String responseId);

  // Recherche et filtrage
  Future<Either<Failure, List<PartRequest>>> searchPartRequests({
    String? partType,
    String? vehicleBrand,
    String? status,
    int limit = 20,
    int offset = 0,
  });

  // Statistiques
  Future<Either<Failure, Map<String, int>>> getPartRequestStats();

  // Vendeur - Demandes actives pour notifications
  Future<Either<Failure, List<PartRequest>>> getActivePartRequestsForSeller();
  Future<Either<Failure, List<PartRequest>>>
      getActivePartRequestsForSellerWithRejections();

  // Vendeur - Refus de demandes
  Future<Either<Failure, SellerRejection>> rejectPartRequest(
      SellerRejection rejection);
  Future<Either<Failure, List<SellerRejection>>> getSellerRejections(
      String sellerId);

  // Particulier - Conversations et messages
  Future<Either<Failure, Map<String, int>>> getConversationsCounts();
  Future<Either<Failure, List<ParticulierConversation>>>
      getParticulierConversations({
    String? filterType, // 'demandes', 'annonces', ou null pour tout
  });
  Future<Either<Failure, ParticulierConversation>>
      getParticulierConversationById(String conversationId);
  Future<Either<Failure, void>> sendParticulierMessage({
    required String conversationId,
    required String content,
  });
  Future<Either<Failure, void>> markParticulierConversationAsRead(
      String conversationId);
  Future<Either<Failure, void>> incrementUnreadCountForUser(
      {required String conversationId});
  Future<Either<Failure, void>> incrementUnreadCountForSeller(
      {required String conversationId});
  Future<Either<Failure, void>> incrementUnreadCountForRecipient({
    required String conversationId,
    required String recipientId,
  });
  Future<Either<Failure, void>> markParticulierMessagesAsRead(
      {required String conversationId});
}
