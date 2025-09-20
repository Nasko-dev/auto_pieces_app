import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/conversations_repository.dart';
import 'package:cente_pice/src/features/parts/domain/usecases/manage_conversation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'manage_conversation_test.mocks.dart';

@GenerateMocks([ConversationsRepository])
void main() {
  late MockConversationsRepository mockRepository;

  setUp(() {
    mockRepository = MockConversationsRepository();
  });

  const tConversationId = 'conversation123';
  const tUserId = 'user456';

  final tMarkParams = MarkMessagesAsReadParams(
    conversationId: tConversationId,
    userId: tUserId,
  );

  final tConversationParams = ConversationParams(conversationId: tConversationId);

  group('MarkMessagesAsRead', () {
    late MarkMessagesAsRead usecase;

    setUp(() {
      usecase = MarkMessagesAsRead(mockRepository);
    });

    test('doit marquer les messages comme lus avec succès', () async {
      // arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: anyNamed('conversationId'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tMarkParams);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé', () async {
      // arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: anyNamed('conversationId'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => const Left(AuthFailure('Accès non autorisé')));

      // act
      final result = await usecase(tMarkParams);

      // assert
      expect(result, const Left(AuthFailure('Accès non autorisé')));
      verify(mockRepository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      ));
    });

    test('doit retourner ValidationFailure quand la conversation n\'existe pas', () async {
      // arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: anyNamed('conversationId'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => const Left(ValidationFailure('Conversation non trouvée')));

      // act
      final result = await usecase(tMarkParams);

      // assert
      expect(result, const Left(ValidationFailure('Conversation non trouvée')));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: anyNamed('conversationId'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tMarkParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });

    test('doit appeler le repository avec les bons paramètres', () async {
      // arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: anyNamed('conversationId'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => const Right(null));

      // act
      await usecase(tMarkParams);

      // assert
      verify(mockRepository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      ));
    });

    test('doit gérer les exceptions du repository', () async {
      // arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: anyNamed('conversationId'),
        userId: anyNamed('userId'),
      )).thenThrow(Exception('Erreur inattendue'));

      // act & assert
      expect(
        () => usecase(tMarkParams),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DeleteConversation', () {
    late DeleteConversation usecase;

    setUp(() {
      usecase = DeleteConversation(mockRepository);
    });

    test('doit supprimer la conversation avec succès', () async {
      // arrange
      when(mockRepository.deleteConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.deleteConversation(conversationId: tConversationId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé', () async {
      // arrange
      when(mockRepository.deleteConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(AuthFailure('Accès non autorisé')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(AuthFailure('Accès non autorisé')));
    });

    test('doit retourner ValidationFailure quand la conversation n\'existe pas', () async {
      // arrange
      when(mockRepository.deleteConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(ValidationFailure('Conversation non trouvée')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(ValidationFailure('Conversation non trouvée')));
    });

    test('doit retourner ValidationFailure pour une conversation déjà supprimée', () async {
      // arrange
      when(mockRepository.deleteConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(ValidationFailure('Conversation déjà supprimée')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(ValidationFailure('Conversation déjà supprimée')));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.deleteConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });

    test('doit appeler le repository avec le bon conversationId', () async {
      // arrange
      when(mockRepository.deleteConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(tConversationParams);

      // assert
      final captured = verify(mockRepository.deleteConversation(conversationId: captureAnyNamed('conversationId'))).captured;
      expect(captured.first, tConversationId);
    });
  });

  group('BlockConversation', () {
    late BlockConversation usecase;

    setUp(() {
      usecase = BlockConversation(mockRepository);
    });

    test('doit bloquer la conversation avec succès', () async {
      // arrange
      when(mockRepository.blockConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.blockConversation(conversationId: tConversationId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé', () async {
      // arrange
      when(mockRepository.blockConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(AuthFailure('Accès non autorisé')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(AuthFailure('Accès non autorisé')));
    });

    test('doit retourner ValidationFailure quand la conversation n\'existe pas', () async {
      // arrange
      when(mockRepository.blockConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(ValidationFailure('Conversation non trouvée')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(ValidationFailure('Conversation non trouvée')));
    });

    test('doit retourner ValidationFailure pour une conversation déjà bloquée', () async {
      // arrange
      when(mockRepository.blockConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(ValidationFailure('Conversation déjà bloquée')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(ValidationFailure('Conversation déjà bloquée')));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.blockConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });

    test('doit appeler le repository avec le bon conversationId', () async {
      // arrange
      when(mockRepository.blockConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(tConversationParams);

      // assert
      final captured = verify(mockRepository.blockConversation(conversationId: captureAnyNamed('conversationId'))).captured;
      expect(captured.first, tConversationId);
    });
  });

  group('CloseConversation', () {
    late CloseConversation usecase;

    setUp(() {
      usecase = CloseConversation(mockRepository);
    });

    test('doit fermer la conversation avec succès', () async {
      // arrange
      when(mockRepository.closeConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.closeConversation(conversationId: tConversationId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('doit retourner AuthFailure quand l\'utilisateur n\'est pas autorisé', () async {
      // arrange
      when(mockRepository.closeConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(AuthFailure('Accès non autorisé')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(AuthFailure('Accès non autorisé')));
    });

    test('doit retourner ValidationFailure quand la conversation n\'existe pas', () async {
      // arrange
      when(mockRepository.closeConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(ValidationFailure('Conversation non trouvée')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(ValidationFailure('Conversation non trouvée')));
    });

    test('doit retourner ValidationFailure pour une conversation déjà fermée', () async {
      // arrange
      when(mockRepository.closeConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(ValidationFailure('Conversation déjà fermée')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(ValidationFailure('Conversation déjà fermée')));
    });

    test('doit retourner ServerFailure en cas d\'erreur serveur', () async {
      // arrange
      when(mockRepository.closeConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Left(ServerFailure('Erreur serveur')));

      // act
      final result = await usecase(tConversationParams);

      // assert
      expect(result, const Left(ServerFailure('Erreur serveur')));
    });

    test('doit appeler le repository avec le bon conversationId', () async {
      // arrange
      when(mockRepository.closeConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(tConversationParams);

      // assert
      final captured = verify(mockRepository.closeConversation(conversationId: captureAnyNamed('conversationId'))).captured;
      expect(captured.first, tConversationId);
    });
  });

  group('Tests intégration - Gestion complète des conversations', () {
    late MarkMessagesAsRead markUsecase;
    late DeleteConversation deleteUsecase;
    late BlockConversation blockUsecase;
    late CloseConversation closeUsecase;

    setUp(() {
      markUsecase = MarkMessagesAsRead(mockRepository);
      deleteUsecase = DeleteConversation(mockRepository);
      blockUsecase = BlockConversation(mockRepository);
      closeUsecase = CloseConversation(mockRepository);
    });

    test('doit gérer un workflow complet de gestion de conversation', () async {
      // arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: anyNamed('conversationId'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => const Right(null));

      when(mockRepository.closeConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));

      when(mockRepository.deleteConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));

      // act - marquer comme lu
      final markResult = await markUsecase(tMarkParams);

      // act - fermer la conversation
      final closeResult = await closeUsecase(tConversationParams);

      // act - supprimer la conversation
      final deleteResult = await deleteUsecase(tConversationParams);

      // assert
      expect(markResult, const Right(null));
      expect(closeResult, const Right(null));
      expect(deleteResult, const Right(null));

      verify(mockRepository.markMessagesAsRead(
        conversationId: tConversationId,
        userId: tUserId,
      ));
      verify(mockRepository.closeConversation(conversationId: tConversationId));
      verify(mockRepository.deleteConversation(conversationId: tConversationId));
    });

    test('doit gérer des IDs de conversation avec différents formats', () async {
      // arrange
      final validIds = [
        'conv123',
        'conversation-456',
        'CONV_789',
        '12345',
        'uuid-style-f47ac10b-58cc-4372-a567-0e02b2c3d479',
      ];

      for (final validId in validIds) {
        when(mockRepository.closeConversation(conversationId: validId))
            .thenAnswer((_) async => const Right(null));

        final params = ConversationParams(conversationId: validId);
        final result = await closeUsecase(params);

        expect(result, const Right(null));
        verify(mockRepository.closeConversation(conversationId: validId));
      }
    });

    test('doit propager tous les types d\'échecs du repository', () async {
      // arrange
      final failures = [
        const AuthFailure('Auth error'),
        const ValidationFailure('Validation error'),
        const ServerFailure('Server error'),
        const NetworkFailure('Network error'),
        const CacheFailure('Cache error'),
      ];

      for (final failure in failures) {
        when(mockRepository.markMessagesAsRead(
          conversationId: anyNamed('conversationId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => Left(failure));

        final result = await markUsecase(tMarkParams);
        expect(result, Left(failure));
      }
    });

    test('doit gérer les exceptions pour tous les use cases', () async {
      // arrange & act & assert
      when(mockRepository.markMessagesAsRead(
        conversationId: anyNamed('conversationId'),
        userId: anyNamed('userId'),
      )).thenThrow(Exception('Mark error'));

      when(mockRepository.deleteConversation(conversationId: anyNamed('conversationId')))
          .thenThrow(Exception('Delete error'));

      when(mockRepository.blockConversation(conversationId: anyNamed('conversationId')))
          .thenThrow(Exception('Block error'));

      when(mockRepository.closeConversation(conversationId: anyNamed('conversationId')))
          .thenThrow(Exception('Close error'));

      expect(() => markUsecase(tMarkParams), throwsA(isA<Exception>()));
      expect(() => deleteUsecase(tConversationParams), throwsA(isA<Exception>()));
      expect(() => blockUsecase(tConversationParams), throwsA(isA<Exception>()));
      expect(() => closeUsecase(tConversationParams), throwsA(isA<Exception>()));
    });

    test('doit fonctionner avec différents utilisateurs et conversations', () async {
      // arrange
      const conv1Id = 'conv1';
      const conv2Id = 'conv2';
      const user1Id = 'user1';
      const user2Id = 'user2';

      final params1 = MarkMessagesAsReadParams(conversationId: conv1Id, userId: user1Id);
      final params2 = MarkMessagesAsReadParams(conversationId: conv2Id, userId: user2Id);

      when(mockRepository.markMessagesAsRead(
        conversationId: conv1Id,
        userId: user1Id,
      )).thenAnswer((_) async => const Right(null));

      when(mockRepository.markMessagesAsRead(
        conversationId: conv2Id,
        userId: user2Id,
      )).thenAnswer((_) async => const Right(null));

      // act
      final result1 = await markUsecase(params1);
      final result2 = await markUsecase(params2);

      // assert
      expect(result1, const Right(null));
      expect(result2, const Right(null));
      verify(mockRepository.markMessagesAsRead(conversationId: conv1Id, userId: user1Id));
      verify(mockRepository.markMessagesAsRead(conversationId: conv2Id, userId: user2Id));
    });

    test('doit déléguer entièrement aux méthodes du repository', () async {
      // arrange
      when(mockRepository.markMessagesAsRead(
        conversationId: anyNamed('conversationId'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => const Right(null));
      when(mockRepository.deleteConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));
      when(mockRepository.blockConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));
      when(mockRepository.closeConversation(conversationId: anyNamed('conversationId')))
          .thenAnswer((_) async => const Right(null));

      // act
      await markUsecase(tMarkParams);
      await deleteUsecase(tConversationParams);
      await blockUsecase(tConversationParams);
      await closeUsecase(tConversationParams);

      // assert - vérifier que les use cases ne font que déléguer
      verify(mockRepository.markMessagesAsRead(conversationId: tConversationId, userId: tUserId));
      verify(mockRepository.deleteConversation(conversationId: tConversationId));
      verify(mockRepository.blockConversation(conversationId: tConversationId));
      verify(mockRepository.closeConversation(conversationId: tConversationId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}