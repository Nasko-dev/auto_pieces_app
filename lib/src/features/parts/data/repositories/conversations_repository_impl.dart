import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/conversations_repository.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation_enums.dart';
import '../datasources/conversations_remote_datasource.dart';

class ConversationsRepositoryImpl implements ConversationsRepository {
  final ConversationsRemoteDataSource remoteDataSource;

  ConversationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Conversation>>> getConversations({required String userId}) async {
    try {
      final conversations = await remoteDataSource.getConversations(userId: userId);
      return Right(conversations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure( 'Erreur lors de la récupération des conversations'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getConversationMessages({
    required String conversationId
  }) async {
    try {
      final messages = await remoteDataSource.getConversationMessages(
        conversationId: conversationId
      );
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure( 'Erreur lors de la récupération des messages'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType messageType = MessageType.text,
    List<String> attachments = const [],
    Map<String, dynamic> metadata = const {},
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        messageType: messageType,
        attachments: attachments,
        metadata: metadata,
        offerPrice: offerPrice,
        offerAvailability: offerAvailability,
        offerDeliveryDays: offerDeliveryDays,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure( 'Erreur lors de l\'envoi du message'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.markMessagesAsRead(
        conversationId: conversationId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure( 'Erreur lors du marquage des messages'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCount({
    required String conversationId,
  }) async {
    try {
      await remoteDataSource.incrementUnreadCount(
        conversationId: conversationId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure( 'Erreur lors de l\'incrémentation du compteur'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCountForUser({
    required String conversationId,
  }) async {
    try {
      await remoteDataSource.incrementUnreadCountForUser(
        conversationId: conversationId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur lors de l\'incrémentation du compteur particulier'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCountForSeller({
    required String conversationId,
  }) async {
    try {
      await remoteDataSource.incrementUnreadCountForSeller(
        conversationId: conversationId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur lors de l\'incrémentation du compteur vendeur'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCountForRecipient({
    required String conversationId,
    required String recipientId,
  }) async {
    try {
      await remoteDataSource.incrementUnreadCountForRecipient(
        conversationId: conversationId,
        recipientId: recipientId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erreur lors de l\'incrémentation intelligente du compteur'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation({
    required String conversationId
  }) async {
    try {
      await remoteDataSource.deleteConversation(conversationId: conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure( 'Erreur lors de la suppression de la conversation'));
    }
  }

  @override
  Future<Either<Failure, void>> blockConversation({
    required String conversationId
  }) async {
    try {
      await remoteDataSource.blockConversation(conversationId: conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure( 'Erreur lors du blocage de la conversation'));
    }
  }

  @override
  Future<Either<Failure, void>> closeConversation({
    required String conversationId
  }) async {
    try {
      await remoteDataSource.updateConversationStatus(
        conversationId: conversationId,
        status: ConversationStatus.closed,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure( 'Erreur lors de la fermeture de la conversation'));
    }
  }

  @override
  Stream<Either<Failure, Message>> subscribeToNewMessages({
    required String conversationId
  }) {
    try {
      return remoteDataSource
          .subscribeToNewMessages(conversationId: conversationId)
          .map((message) => Right<Failure, Message>(message))
          .handleError((error) {
            return Left<Failure, Message>(
              ServerFailure( 'Erreur de connexion realtime')
            );
          });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure( 'Erreur lors de la création du stream'))
      );
    }
  }

  @override
  Stream<Either<Failure, List<Conversation>>> subscribeToConversationUpdates({
    required String userId
  }) {
    try {
      return remoteDataSource
          .subscribeToConversationUpdates(userId: userId)
          .asyncMap((conversation) async {
            // Récupérer la liste complète des conversations
            final result = await getConversations(userId: userId);
            return result;
          })
          .handleError((error) {
            return Left<Failure, List<Conversation>>(
              ServerFailure( 'Erreur de connexion realtime')
            );
          });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure( 'Erreur lors de la création du stream'))
      );
    }
  }
}