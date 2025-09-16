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
      print('📋 [Repository] Récupération conversations pour: $userId');
      final conversations = await remoteDataSource.getConversations(userId: userId);
      print('✅ [Repository] ${conversations.length} conversations récupérées');
      return Right(conversations);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur générale: $e');
      return Left(ServerFailure( 'Erreur lors de la récupération des conversations'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getConversationMessages({
    required String conversationId
  }) async {
    try {
      print('💬 [Repository] Récupération messages pour: $conversationId');
      final messages = await remoteDataSource.getConversationMessages(
        conversationId: conversationId
      );
      print('✅ [Repository] ${messages.length} messages récupérés');
      return Right(messages);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur générale: $e');
      return Left(ServerFailure( 'Erreur lors de la récupération des messages'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType messageType = MessageType.text,
    double? offerPrice,
    String? offerAvailability,
    int? offerDeliveryDays,
  }) async {
    try {
      print('📤 [Repository] Envoi message: $content');
      final message = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        messageType: messageType,
        offerPrice: offerPrice,
        offerAvailability: offerAvailability,
        offerDeliveryDays: offerDeliveryDays,
      );
      print('✅ [Repository] Message envoyé avec succès');
      return Right(message);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur générale: $e');
      return Left(ServerFailure( 'Erreur lors de l\'envoi du message'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      print('👀 [Repository] Marquage messages comme lus: $conversationId');
      await remoteDataSource.markMessagesAsRead(
        conversationId: conversationId,
        userId: userId,
      );
      print('✅ [Repository] Messages marqués comme lus');
      return const Right(null);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur générale: $e');
      return Left(ServerFailure( 'Erreur lors du marquage des messages'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUnreadCount({
    required String conversationId,
  }) async {
    try {
      print('📈 [Repository] Incrémentation compteur: $conversationId');
      await remoteDataSource.incrementUnreadCount(
        conversationId: conversationId,
      );
      print('✅ [Repository] Compteur incrémenté');
      return const Right(null);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur générale: $e');
      return Left(ServerFailure( 'Erreur lors de l\'incrémentation du compteur'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation({
    required String conversationId
  }) async {
    try {
      print('🗑️ [Repository] Suppression conversation: $conversationId');
      await remoteDataSource.deleteConversation(conversationId: conversationId);
      print('✅ [Repository] Conversation supprimée');
      return const Right(null);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur générale: $e');
      return Left(ServerFailure( 'Erreur lors de la suppression de la conversation'));
    }
  }

  @override
  Future<Either<Failure, void>> blockConversation({
    required String conversationId
  }) async {
    try {
      print('🚫 [Repository] Blocage conversation: $conversationId');
      await remoteDataSource.blockConversation(conversationId: conversationId);
      print('✅ [Repository] Conversation bloquée');
      return const Right(null);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur générale: $e');
      return Left(ServerFailure( 'Erreur lors du blocage de la conversation'));
    }
  }

  @override
  Future<Either<Failure, void>> closeConversation({
    required String conversationId
  }) async {
    try {
      print('📪 [Repository] Fermeture conversation: $conversationId');
      await remoteDataSource.updateConversationStatus(
        conversationId: conversationId,
        status: ConversationStatus.closed,
      );
      print('✅ [Repository] Conversation fermée');
      return const Right(null);
    } on ServerException catch (e) {
      print('❌ [Repository] Erreur serveur: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ [Repository] Erreur générale: $e');
      return Left(ServerFailure( 'Erreur lors de la fermeture de la conversation'));
    }
  }

  @override
  Stream<Either<Failure, Message>> subscribeToNewMessages({
    required String conversationId
  }) {
    try {
      print('📡 [Repository] Abonnement messages realtime: $conversationId');
      return remoteDataSource
          .subscribeToNewMessages(conversationId: conversationId)
          .map((message) => Right<Failure, Message>(message))
          .handleError((error) {
            print('❌ [Repository] Erreur realtime messages: $error');
            return Left<Failure, Message>(
              ServerFailure( 'Erreur de connexion realtime')
            );
          });
    } catch (e) {
      print('❌ [Repository] Erreur création stream messages: $e');
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
      print('📡 [Repository] Abonnement conversations realtime: $userId');
      return remoteDataSource
          .subscribeToConversationUpdates(userId: userId)
          .asyncMap((conversation) async {
            // Récupérer la liste complète des conversations
            final result = await getConversations(userId: userId);
            return result;
          })
          .handleError((error) {
            print('❌ [Repository] Erreur realtime conversations: $error');
            return Left<Failure, List<Conversation>>(
              ServerFailure( 'Erreur de connexion realtime')
            );
          });
    } catch (e) {
      print('❌ [Repository] Erreur création stream conversations: $e');
      return Stream.value(
        Left(ServerFailure( 'Erreur lors de la création du stream'))
      );
    }
  }
}