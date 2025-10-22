import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/entities/part_request.dart';
import '../../domain/entities/seller_response.dart';
import '../../domain/entities/seller_rejection.dart';
import '../../domain/entities/particulier_conversation.dart';
import '../../domain/repositories/part_request_repository.dart';
import '../../domain/usecases/create_seller_response.dart';
import '../datasources/part_request_remote_datasource.dart';
import '../datasources/conversations_remote_datasource.dart';

final supabaseClient = Supabase.instance.client;

class PartRequestRepositoryImpl implements PartRequestRepository {
  final PartRequestRemoteDataSource _remoteDataSource;
  final ConversationsRemoteDataSource _conversationsRemoteDataSource;
  final NetworkInfo _networkInfo;

  PartRequestRepositoryImpl({
    required PartRequestRemoteDataSource remoteDataSource,
    required ConversationsRemoteDataSource conversationsRemoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _conversationsRemoteDataSource = conversationsRemoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<PartRequest>>> getUserPartRequests() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getUserPartRequests();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PartRequest>> createPartRequest(
      CreatePartRequestParams params) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final model = await _remoteDataSource.createPartRequest(params);
      return Right(model.toEntity());
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PartRequest>> getPartRequestById(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final model = await _remoteDataSource.getPartRequestById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PartRequest>> updatePartRequestStatus(
      String id, String status) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final model = await _remoteDataSource.updatePartRequestStatus(id, status);
      return Right(model.toEntity());
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePartRequest(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.deletePartRequest(id);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SellerResponse>>> getPartRequestResponses(
      String requestId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final responseData =
          await _remoteDataSource.getPartRequestResponses(requestId);
      final responses = responseData.map((data) {
        final sellerData = data['sellers'] as Map<String, dynamic>?;

        return SellerResponse(
          id: data['id'],
          requestId: data['request_id'],
          sellerId: data['seller_id'],
          sellerName: sellerData != null
              ? '${sellerData['first_name'] ?? ''} ${sellerData['last_name'] ?? ''}'
                  .trim()
              : null,
          sellerCompany: sellerData?['company_name'],
          sellerEmail: sellerData?['email'],
          sellerPhone: sellerData?['phone'],
          message: data['message'],
          price: data['price']?.toDouble(),
          availability: data['availability'],
          estimatedDeliveryDays: data['estimated_delivery_days'],
          attachments: List<String>.from(data['attachments'] ?? []),
          status: data['status'] ?? 'pending',
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
        );
      }).toList();

      return Right(responses);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PartRequest>>> searchPartRequests({
    String? partType,
    String? vehicleBrand,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.searchPartRequests(
        partType: partType,
        vehicleBrand: vehicleBrand,
        status: status,
        limit: limit,
        offset: offset,
      );
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getPartRequestStats() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final stats = await _remoteDataSource.getPartRequestStats();
      return Right(stats);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PartRequest>>>
      getActivePartRequestsForSeller() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getActivePartRequestsForSeller();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SellerResponse>> createSellerResponse(
      CreateSellerResponseParams params) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final responseData = await _remoteDataSource.createSellerResponse(
        requestId: params.requestId,
        sellerId: supabaseClient.auth.currentUser!.id,
        message: params.message,
        price: params.price,
        availability: params.availability,
        estimatedDeliveryDays: params.estimatedDeliveryDays,
        attachments: params.attachments,
      );
      final sellerResponse = SellerResponse(
        id: responseData['id'],
        requestId: responseData['request_id'],
        sellerId: responseData['seller_id'],
        sellerName: null,
        sellerCompany: null,
        sellerEmail: null,
        sellerPhone: null,
        message: responseData['message'],
        price: responseData['price']?.toDouble(),
        availability: responseData['availability'],
        estimatedDeliveryDays: responseData['estimated_delivery_days'],
        attachments: List<String>.from(responseData['attachments'] ?? []),
        status: responseData['status'] ?? 'pending',
        createdAt: DateTime.parse(responseData['created_at']),
        updatedAt: DateTime.parse(responseData['updated_at']),
      );
      return Right(sellerResponse);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SellerResponse>> acceptSellerResponse(
      String responseId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final responseData =
          await _remoteDataSource.acceptSellerResponse(responseId);
      // Créer une réponse SellerResponse simplifiée
      final sellerResponse = SellerResponse(
        id: responseData['id'],
        requestId: responseData['request_id'],
        sellerId: responseData['seller_id'],
        sellerName: null,
        sellerCompany: null,
        sellerEmail: null,
        sellerPhone: null,
        message: responseData['message'],
        price: responseData['price']?.toDouble(),
        availability: responseData['availability'],
        estimatedDeliveryDays: responseData['estimated_delivery_days'],
        attachments: List<String>.from(responseData['attachments'] ?? []),
        status: responseData['status'] ?? 'accepted',
        createdAt: DateTime.parse(responseData['created_at']),
        updatedAt: DateTime.parse(responseData['updated_at']),
      );
      return Right(sellerResponse);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SellerResponse>> rejectSellerResponse(
      String responseId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final responseData =
          await _remoteDataSource.rejectSellerResponse(responseId);
      // Créer une réponse SellerResponse simplifiée
      final sellerResponse = SellerResponse(
        id: responseData['id'],
        requestId: responseData['request_id'],
        sellerId: responseData['seller_id'],
        sellerName: null,
        sellerCompany: null,
        sellerEmail: null,
        sellerPhone: null,
        message: responseData['message'],
        price: responseData['price']?.toDouble(),
        availability: responseData['availability'],
        estimatedDeliveryDays: responseData['estimated_delivery_days'],
        attachments: List<String>.from(responseData['attachments'] ?? []),
        status: responseData['status'] ?? 'rejected',
        createdAt: DateTime.parse(responseData['created_at']),
        updatedAt: DateTime.parse(responseData['updated_at']),
      );
      return Right(sellerResponse);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PartRequest>>>
      getActivePartRequestsForSellerWithRejections() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource
          .getActivePartRequestsForSellerWithRejections();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SellerRejection>> rejectPartRequest(
      SellerRejection rejection) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      final savedRejection =
          await _remoteDataSource.rejectPartRequest(rejection);
      return Right(savedRejection);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SellerRejection>>> getSellerRejections(
      String sellerId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final rejections = await _remoteDataSource.getSellerRejections(sellerId);
      return Right(rejections);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Particulier - Conversations et messages
  @override
  Future<Either<Failure, List<ParticulierConversation>>>
      getParticulierConversations({String? filterType}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      // ✅ OPTIMISATION: Passer le filtre pour charger seulement ce qui est nécessaire
      final conversations =
          await _remoteDataSource.getParticulierConversations(
        filterType: filterType,
      );
      return Right(conversations);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParticulierConversation>>
      getParticulierConversationById(String conversationId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final conversation = await _remoteDataSource
          .getParticulierConversationById(conversationId);
      return Right(conversation);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendParticulierMessage({
    required String conversationId,
    required String content,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.sendParticulierMessage(
        conversationId: conversationId,
        content: content,
      );
      return const Right(null);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markParticulierConversationAsRead(
      String conversationId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.markParticulierConversationAsRead(conversationId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(AuthFailure('User not authenticated'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasActivePartRequest() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final hasActive = await _remoteDataSource.hasActivePartRequest();
      return Right(hasActive);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCountForUser(
      {required String conversationId}) async {
    return ErrorHandler.handleVoidAsync(
      () => _remoteDataSource.incrementUnreadCountForUser(
          conversationId: conversationId),
      checkNetwork: true,
      networkCheck: () => _networkInfo.isConnected,
      context: 'incrementUnreadCountForUser',
    );
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCountForRecipient({
    required String conversationId,
    required String recipientId,
  }) async {
    return ErrorHandler.handleVoidAsync(
      () => _conversationsRemoteDataSource.incrementUnreadCountForRecipient(
        conversationId: conversationId,
        recipientId: recipientId,
      ),
      checkNetwork: true,
      networkCheck: () => _networkInfo.isConnected,
      context: 'incrementUnreadCountForRecipient',
    );
  }

  @override
  Future<Either<Failure, void>> markParticulierMessagesAsRead(
      {required String conversationId}) async {
    return ErrorHandler.handleVoidAsync(
      () => _remoteDataSource.markParticulierMessagesAsRead(
          conversationId: conversationId),
      checkNetwork: true,
      networkCheck: () => _networkInfo.isConnected,
      context: 'markParticulierMessagesAsRead',
    );
  }
}
