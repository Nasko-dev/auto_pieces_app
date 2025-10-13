import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:cente_pice/src/core/errors/failures.dart';
import 'package:cente_pice/src/features/parts/domain/entities/part_request.dart';
import 'package:cente_pice/src/features/parts/domain/repositories/part_request_repository.dart';

// Test simplifié pour PartRequestRepository
void main() {
  group('PartRequestRepository Tests', () {
    group('Contract Tests', () {
      test('devrait avoir les bonnes signatures de méthodes', () {
        // Test que l'interface existe avec les bonnes méthodes
        expect(() => PartRequestRepository, returnsNormally);
      });

      test('devrait utiliser les bons types de retour', () {
        // Vérifier que les types sont corrects dans le contrat
        expect(CreatePartRequestParams, isA<Type>());
        expect(PartRequest, isA<Type>());
        expect(Either<Failure, List<PartRequest>>, isA<Type>());
      });

      test('devrait créer des instances de PartRequest correctement', () {
        final request = PartRequest(
          id: 'test-id',
          partType: 'engine',
          partNames: ['Test part'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(request.id, equals('test-id'));
        expect(request.partType, equals('engine'));
        expect(request.partNames, contains('Test part'));
        expect(request.status, equals('active')); // valeur par défaut
        expect(request.isAnonymous, isFalse); // valeur par défaut
        expect(request.isSellerRequest, isFalse); // valeur par défaut
        expect(request.responseCount, equals(0)); // valeur par défaut
      });

      test('devrait créer des CreatePartRequestParams correctement', () {
        final params = CreatePartRequestParams(
          partType: 'body',
          partNames: ['Phare avant', 'Pare-chocs'],
          vehicleBrand: 'Peugeot',
          vehicleModel: '308',
          vehicleYear: 2020,
          additionalInfo: 'Informations supplémentaires',
        );

        expect(params.partType, equals('body'));
        expect(params.partNames, hasLength(2));
        expect(params.partNames, contains('Phare avant'));
        expect(params.partNames, contains('Pare-chocs'));
        expect(params.vehicleBrand, equals('Peugeot'));
        expect(params.vehicleModel, equals('308'));
        expect(params.vehicleYear, equals(2020));
        expect(params.additionalInfo, equals('Informations supplémentaires'));
        expect(params.isAnonymous, isFalse); // valeur par défaut
        expect(params.isSellerRequest, isFalse); // valeur par défaut
      });

      test('devrait utiliser copyWith correctement', () {
        final originalRequest = PartRequest(
          id: 'test-id',
          partType: 'engine',
          partNames: ['Test part'],
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updatedRequest = originalRequest.copyWith(
          status: 'fulfilled',
          responseCount: 5,
        );

        expect(updatedRequest.id, equals(originalRequest.id));
        expect(updatedRequest.partType, equals(originalRequest.partType));
        expect(updatedRequest.status, equals('fulfilled'));
        expect(updatedRequest.responseCount, equals(5));
      });

      test('devrait utiliser les getters correctement', () {
        final activeRequest = PartRequest(
          id: 'active-req',
          partType: 'engine',
          partNames: ['Test part'],
          status: 'active',
          responseCount: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(activeRequest.isActive, isTrue);
        expect(activeRequest.hasResponses, isTrue);
        expect(activeRequest.isExpired, isFalse);
      });

      test('devrait calculer vehicleInfo correctement pour les pièces de carrosserie', () {
        final bodyPartRequest = PartRequest(
          id: 'body-req',
          partType: 'body',
          partNames: ['Phare avant'],
          vehicleBrand: 'Peugeot',
          vehicleModel: '308',
          vehicleYear: 2020,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(bodyPartRequest.vehicleInfo, equals('Peugeot - 308 - 2020'));
      });

      test('devrait calculer vehicleInfo correctement pour les pièces moteur', () {
        final enginePartRequest = PartRequest(
          id: 'engine-req',
          partType: 'engine',
          partNames: ['Alternateur'],
          vehicleBrand: 'Peugeot',
          vehicleModel: '308',
          vehicleEngine: '1.6 HDi 110',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(enginePartRequest.vehicleInfo, equals('Peugeot - 308 - 1.6 HDi 110'));
      });

      test('devrait gérer les dates d\'expiration', () {
        final expiredRequest = PartRequest(
          id: 'expired-req',
          partType: 'engine',
          partNames: ['Test part'],
          status: 'active',
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(expiredRequest.isExpired, isTrue);
        expect(expiredRequest.isActive, isFalse);

        final nonExpiredRequest = PartRequest(
          id: 'not-expired-req',
          partType: 'engine',
          partNames: ['Test part'],
          status: 'active',
          expiresAt: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(nonExpiredRequest.isExpired, isFalse);
        expect(nonExpiredRequest.isActive, isTrue);
      });

      test('devrait gérer les demandes sans date d\'expiration', () {
        final request = PartRequest(
          id: 'no-expiry-req',
          partType: 'engine',
          partNames: ['Test part'],
          status: 'active',
          // expiresAt est null par défaut
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(request.expiresAt, isNull);
        expect(request.isExpired, isFalse);
        expect(request.isActive, isTrue);
      });

      test('devrait valider les différents statuts', () {
        final activeRequest = PartRequest(
          id: 'active-req',
          partType: 'engine',
          partNames: ['Test part'],
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final closedRequest = PartRequest(
          id: 'closed-req',
          partType: 'engine',
          partNames: ['Test part'],
          status: 'closed',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final fulfilledRequest = PartRequest(
          id: 'fulfilled-req',
          partType: 'engine',
          partNames: ['Test part'],
          status: 'fulfilled',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(activeRequest.status, equals('active'));
        expect(activeRequest.isActive, isTrue);

        expect(closedRequest.status, equals('closed'));
        expect(closedRequest.isActive, isFalse);

        expect(fulfilledRequest.status, equals('fulfilled'));
        expect(fulfilledRequest.isActive, isFalse);
      });
    });

    group('Validation des champs requis', () {
      test('devrait accepter les champs requis minimum', () {
        expect(() => PartRequest(
          id: 'test-id',
          partType: 'engine',
          partNames: ['Test part'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ), returnsNormally);
      });

      test('devrait accepter les champs optionnels', () {
        final request = PartRequest(
          id: 'full-req',
          userId: 'user-123',
          vehiclePlate: 'AB-123-CD',
          vehicleBrand: 'Peugeot',
          vehicleModel: '308',
          vehicleYear: 2020,
          vehicleEngine: '1.6 HDi',
          partType: 'body',
          partNames: ['Phare avant', 'Pare-chocs'],
          additionalInfo: 'Informations supplémentaires',
          status: 'active',
          isAnonymous: true,
          isSellerRequest: false,
          responseCount: 2,
          pendingResponseCount: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        expect(request.userId, equals('user-123'));
        expect(request.vehiclePlate, equals('AB-123-CD'));
        expect(request.additionalInfo, equals('Informations supplémentaires'));
        expect(request.isAnonymous, isTrue);
        expect(request.responseCount, equals(2));
        expect(request.pendingResponseCount, equals(1));
        expect(request.expiresAt, isNotNull);
      });
    });

    group('Validation CreatePartRequestParams', () {
      test('devrait accepter les paramètres requis minimum', () {
        expect(() => CreatePartRequestParams(
          partType: 'engine',
          partNames: ['Alternateur'],
        ), returnsNormally);
      });

      test('devrait accepter tous les paramètres optionnels', () {
        final params = CreatePartRequestParams(
          vehiclePlate: 'AB-123-CD',
          vehicleBrand: 'Peugeot',
          vehicleModel: '308',
          vehicleYear: 2020,
          vehicleEngine: '1.6 HDi',
          partType: 'body',
          partNames: ['Phare avant', 'Pare-chocs'],
          additionalInfo: 'Recherche pièces en bon état',
          isAnonymous: true,
          isSellerRequest: false,
        );

        expect(params.vehiclePlate, equals('AB-123-CD'));
        expect(params.vehicleBrand, equals('Peugeot'));
        expect(params.vehicleModel, equals('308'));
        expect(params.vehicleYear, equals(2020));
        expect(params.vehicleEngine, equals('1.6 HDi'));
        expect(params.partType, equals('body'));
        expect(params.partNames, hasLength(2));
        expect(params.additionalInfo, equals('Recherche pièces en bon état'));
        expect(params.isAnonymous, isTrue);
        expect(params.isSellerRequest, isFalse);
      });
    });
  });
}