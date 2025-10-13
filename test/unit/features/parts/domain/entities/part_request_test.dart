import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/features/parts/domain/entities/part_request.dart';

void main() {
  group('PartRequest Entity', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late DateTime testExpiresAt;
    late PartRequest testPartRequest;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1, 10, 0);
      testUpdatedAt = DateTime(2024, 1, 2, 15, 30);
      testExpiresAt = DateTime(2024, 2, 1, 12, 0);

      testPartRequest = PartRequest(
        id: 'test-request-123',
        userId: 'user-456',
        vehiclePlate: 'AB-123-CD',
        vehicleBrand: 'Renault',
        vehicleModel: 'Clio',
        vehicleYear: 2020,
        vehicleEngine: '1.2 TCE',
        partType: 'engine',
        partNames: ['Turbocompresseur', 'Injecteur'],
        additionalInfo: 'Pièce d\'occasion acceptée',
        status: 'active',
        isAnonymous: false,
        isSellerRequest: false,
        responseCount: 3,
        pendingResponseCount: 1,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        expiresAt: testExpiresAt,
      );
    });

    group('Constructor', () {
      test('should create PartRequest with all parameters', () {
        expect(testPartRequest.id, 'test-request-123');
        expect(testPartRequest.userId, 'user-456');
        expect(testPartRequest.vehiclePlate, 'AB-123-CD');
        expect(testPartRequest.vehicleBrand, 'Renault');
        expect(testPartRequest.vehicleModel, 'Clio');
        expect(testPartRequest.vehicleYear, 2020);
        expect(testPartRequest.vehicleEngine, '1.2 TCE');
        expect(testPartRequest.partType, 'engine');
        expect(testPartRequest.partNames, ['Turbocompresseur', 'Injecteur']);
        expect(testPartRequest.additionalInfo, 'Pièce d\'occasion acceptée');
        expect(testPartRequest.status, 'active');
        expect(testPartRequest.isAnonymous, false);
        expect(testPartRequest.isSellerRequest, false);
        expect(testPartRequest.responseCount, 3);
        expect(testPartRequest.pendingResponseCount, 1);
        expect(testPartRequest.createdAt, testCreatedAt);
        expect(testPartRequest.updatedAt, testUpdatedAt);
        expect(testPartRequest.expiresAt, testExpiresAt);
      });

      test('should create PartRequest with minimal required parameters', () {
        final minimalPartRequest = PartRequest(
          id: 'minimal-request',
          partType: 'body',
          partNames: ['Portière'],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(minimalPartRequest.id, 'minimal-request');
        expect(minimalPartRequest.partType, 'body');
        expect(minimalPartRequest.partNames, ['Portière']);
        expect(minimalPartRequest.createdAt, testCreatedAt);
        expect(minimalPartRequest.updatedAt, testUpdatedAt);
        expect(minimalPartRequest.userId, null);
        expect(minimalPartRequest.vehiclePlate, null);
        expect(minimalPartRequest.status, 'active');
        expect(minimalPartRequest.isAnonymous, false);
        expect(minimalPartRequest.isSellerRequest, false);
        expect(minimalPartRequest.responseCount, 0);
        expect(minimalPartRequest.pendingResponseCount, 0);
        expect(minimalPartRequest.expiresAt, null);
      });

      test('should use default values correctly', () {
        final defaultPartRequest = PartRequest(
          id: 'default-request',
          partType: 'engine',
          partNames: ['Moteur'],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(defaultPartRequest.status, 'active');
        expect(defaultPartRequest.isAnonymous, false);
        expect(defaultPartRequest.isSellerRequest, false);
        expect(defaultPartRequest.responseCount, 0);
        expect(defaultPartRequest.pendingResponseCount, 0);
      });
    });

    group('isExpired getter', () {
      test('should return false when expiresAt is null', () {
        final partRequest = testPartRequest.copyWith(expiresAt: null);
        expect(partRequest.isExpired, false);
      });

      test('should return false when expiresAt is in the future', () {
        final futureDate = DateTime.now().add(const Duration(days: 7));
        final partRequest = testPartRequest.copyWith(expiresAt: futureDate);
        expect(partRequest.isExpired, false);
      });

      test('should return true when expiresAt is in the past', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 7));
        final partRequest = testPartRequest.copyWith(expiresAt: pastDate);
        expect(partRequest.isExpired, true);
      });

      test('should return true when expiresAt is exactly now', () {
        final now = DateTime.now();
        final partRequest = testPartRequest.copyWith(
          expiresAt: now.subtract(const Duration(milliseconds: 1)),
        );
        expect(partRequest.isExpired, true);
      });
    });

    group('isActive getter', () {
      test('should return true when status is active and not expired', () {
        final futureDate = DateTime.now().add(const Duration(days: 7));
        final partRequest = testPartRequest.copyWith(
          status: 'active',
          expiresAt: futureDate,
        );
        expect(partRequest.isActive, true);
      });

      test('should return false when status is not active', () {
        final futureDate = DateTime.now().add(const Duration(days: 7));
        final partRequest = testPartRequest.copyWith(
          status: 'closed',
          expiresAt: futureDate,
        );
        expect(partRequest.isActive, false);
      });

      test('should return false when expired even if status is active', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 7));
        final partRequest = testPartRequest.copyWith(
          status: 'active',
          expiresAt: pastDate,
        );
        expect(partRequest.isActive, false);
      });

      test('should return true when status is active and no expiration date', () {
        final partRequest = testPartRequest.copyWith(
          status: 'active',
          expiresAt: null,
        );
        expect(partRequest.isActive, true);
      });

      test('should return false for fulfilled status', () {
        final partRequest = testPartRequest.copyWith(status: 'fulfilled');
        expect(partRequest.isActive, false);
      });
    });

    group('hasResponses getter', () {
      test('should return true when responseCount is greater than 0', () {
        final partRequest = testPartRequest.copyWith(responseCount: 5);
        expect(partRequest.hasResponses, true);
      });

      test('should return false when responseCount is 0', () {
        final partRequest = testPartRequest.copyWith(responseCount: 0);
        expect(partRequest.hasResponses, false);
      });

      test('should return true when responseCount is 1', () {
        final partRequest = testPartRequest.copyWith(responseCount: 1);
        expect(partRequest.hasResponses, true);
      });
    });

    group('vehicleInfo getter', () {
      group('when partType is body', () {
        test('should return brand + model + year + engine when all are present', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'body',
            vehicleBrand: 'Peugeot',
            vehicleModel: '208',
            vehicleYear: 2019,
            vehicleEngine: '1.2L',
          );

          expect(partRequest.vehicleInfo, 'Peugeot - 208 - 2019 - 1.2L');
        });

        test('should return only available info for body parts', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'body',
            vehicleBrand: 'Citroën',
            vehicleModel: null,
            vehicleYear: 2021,
            vehicleEngine: '1.5L',
          );

          expect(partRequest.vehicleInfo, 'Citroën - 2021 - 1.5L');
        });

        test('should return only brand and engine when available', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'body',
            vehicleBrand: 'Ford',
            vehicleModel: null,
            vehicleYear: null,
            vehicleEngine: '2.0L',
          );

          expect(partRequest.vehicleInfo, 'Ford - 2.0L');
        });
      });

      group('when partType is engine', () {
        test('should return all info when available', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'engine',
            vehicleBrand: 'BMW',
            vehicleModel: 'X3',
            vehicleYear: 2020,
            vehicleEngine: '2.0 TDI',
          );

          expect(partRequest.vehicleInfo, 'BMW - X3 - 2020 - 2.0 TDI');
        });

        test('should return brand + model + year when engine is null', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'engine',
            vehicleBrand: 'Audi',
            vehicleModel: 'A4',
            vehicleYear: 2018,
            vehicleEngine: null,
          );

          expect(partRequest.vehicleInfo, 'Audi - A4 - 2018');
        });

        test('should return engine when only engine is available', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'engine',
            vehicleBrand: null,
            vehicleModel: null,
            vehicleYear: null,
            vehicleEngine: '1.6 HDI',
          );

          expect(partRequest.vehicleInfo, '1.6 HDI');
        });
      });

      group('fallback behavior', () {
        test('should return all available info for unknown part types', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'unknown',
            vehicleBrand: 'Mercedes',
            vehicleModel: 'C-Class',
            vehicleYear: 2022,
            vehicleEngine: '2.2L',
          );

          expect(partRequest.vehicleInfo, 'Mercedes - C-Class - 2022 - 2.2L');
        });

        test('should return engine as fallback when no brand/model/year', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'unknown',
            vehicleBrand: null,
            vehicleModel: null,
            vehicleYear: null,
            vehicleEngine: '3.0 V6',
          );

          expect(partRequest.vehicleInfo, '3.0 V6');
        });

        test('should return default message when no vehicle info available', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'unknown',
            vehicleBrand: null,
            vehicleModel: null,
            vehicleYear: null,
            vehicleEngine: null,
          );

          expect(partRequest.vehicleInfo, 'Véhicule non spécifié');
        });

        test('should handle partial info correctly', () {
          final partRequest = testPartRequest.copyWith(
            partType: 'transmission',
            vehicleBrand: 'Volkswagen',
            vehicleModel: null,
            vehicleYear: 2017,
            vehicleEngine: null,
          );

          expect(partRequest.vehicleInfo, 'Volkswagen - 2017');
        });
      });
    });

    group('copyWith method', () {
      test('should create new instance with updated values', () {
        final newCreatedAt = DateTime(2024, 3, 1);
        final updatedPartRequest = testPartRequest.copyWith(
          id: 'new-request-id',
          partType: 'body',
          partNames: ['Pare-chocs', 'Phare'],
          status: 'closed',
          responseCount: 10,
          createdAt: newCreatedAt,
        );

        expect(updatedPartRequest.id, 'new-request-id');
        expect(updatedPartRequest.partType, 'body');
        expect(updatedPartRequest.partNames, ['Pare-chocs', 'Phare']);
        expect(updatedPartRequest.status, 'closed');
        expect(updatedPartRequest.responseCount, 10);
        expect(updatedPartRequest.createdAt, newCreatedAt);

        // Unchanged values should remain the same
        expect(updatedPartRequest.userId, 'user-456');
        expect(updatedPartRequest.vehicleBrand, 'Renault');
        expect(updatedPartRequest.updatedAt, testUpdatedAt);
        expect(updatedPartRequest.isAnonymous, false);
      });

      test('should keep original values when no parameters provided', () {
        final copiedPartRequest = testPartRequest.copyWith();

        expect(copiedPartRequest.id, testPartRequest.id);
        expect(copiedPartRequest.partType, testPartRequest.partType);
        expect(copiedPartRequest.partNames, testPartRequest.partNames);
        expect(copiedPartRequest.status, testPartRequest.status);
        expect(copiedPartRequest.createdAt, testPartRequest.createdAt);
        expect(copiedPartRequest.responseCount, testPartRequest.responseCount);
      });

      test('should handle nullable values correctly', () {
        final updatedPartRequest = testPartRequest.copyWith(
          userId: null,
          vehiclePlate: null,
          additionalInfo: null,
          expiresAt: null,
        );

        expect(updatedPartRequest.userId, null);
        expect(updatedPartRequest.vehiclePlate, null);
        expect(updatedPartRequest.additionalInfo, null);
        expect(updatedPartRequest.expiresAt, null);
      });
    });

    group('Equality and hashCode', () {
      test('should be equal when all properties are the same', () {
        final partRequest1 = PartRequest(
          id: 'same-id',
          partType: 'engine',
          partNames: ['Moteur'],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final partRequest2 = PartRequest(
          id: 'same-id',
          partType: 'engine',
          partNames: ['Moteur'],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(partRequest1, equals(partRequest2));
        expect(partRequest1.hashCode, equals(partRequest2.hashCode));
      });

      test('should not be equal when id is different', () {
        final partRequest1 = PartRequest(
          id: 'id-1',
          partType: 'engine',
          partNames: ['Moteur'],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final partRequest2 = PartRequest(
          id: 'id-2',
          partType: 'engine',
          partNames: ['Moteur'],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(partRequest1, isNot(equals(partRequest2)));
        expect(partRequest1.hashCode, isNot(equals(partRequest2.hashCode)));
      });

      test('should not be equal when any property is different', () {
        final partRequest1 = testPartRequest;
        final partRequest2 = testPartRequest.copyWith(status: 'closed');

        expect(partRequest1, isNot(equals(partRequest2)));
      });

      test('should handle null values in equality comparison', () {
        final partRequest1 = PartRequest(
          id: 'test-id',
          partType: 'body',
          partNames: ['Portière'],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          userId: null,
          vehiclePlate: null,
        );

        final partRequest2 = PartRequest(
          id: 'test-id',
          partType: 'body',
          partNames: ['Portière'],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          userId: null,
          vehiclePlate: null,
        );

        expect(partRequest1, equals(partRequest2));
      });
    });

    group('Edge cases', () {
      test('should handle empty part names list', () {
        final partRequest = PartRequest(
          id: 'test-id',
          partType: 'engine',
          partNames: [],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(partRequest.partNames, isEmpty);
        expect(partRequest.partNames.length, 0);
      });

      test('should handle very long part names list', () {
        final longPartNames = List.generate(100, (index) => 'Pièce $index');
        final partRequest = PartRequest(
          id: 'test-id',
          partType: 'body',
          partNames: longPartNames,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(partRequest.partNames.length, 100);
        expect(partRequest.partNames.first, 'Pièce 0');
        expect(partRequest.partNames.last, 'Pièce 99');
      });

      test('should handle special characters in vehicle info', () {
        final partRequest = testPartRequest.copyWith(
          vehicleBrand: 'Mércédés-Bénz',
          vehicleModel: 'Clässé',
          vehicleEngine: '2.0 CDI Blüé EFFICÏENCY',
        );

        expect(partRequest.vehicleBrand, 'Mércédés-Bénz');
        expect(partRequest.vehicleModel, 'Clässé');
        expect(partRequest.vehicleEngine, '2.0 CDI Blüé EFFICÏENCY');
      });

      test('should handle negative response counts gracefully', () {
        final partRequest = testPartRequest.copyWith(
          responseCount: -1,
          pendingResponseCount: -5,
        );

        expect(partRequest.responseCount, -1);
        expect(partRequest.pendingResponseCount, -5);
        expect(partRequest.hasResponses, false); // -1 is not > 0
      });

      test('should handle invalid status values', () {
        final partRequest = testPartRequest.copyWith(status: 'invalid_status');

        expect(partRequest.status, 'invalid_status');
        expect(partRequest.isActive, false); // not 'active'
      });

      test('should handle year edge cases', () {
        final partRequest = testPartRequest.copyWith(
          vehicleYear: 1900, // Very old car
        );

        expect(partRequest.vehicleYear, 1900);
        expect(partRequest.vehicleInfo, 'Renault - Clio - 1900 - 1.2 TCE'); // All available fields
      });

      test('should handle future years', () {
        final futureYear = DateTime.now().year + 10;
        final partRequest = testPartRequest.copyWith(
          partType: 'body',
          vehicleYear: futureYear,
        );

        expect(partRequest.vehicleYear, futureYear);
        expect(partRequest.vehicleInfo, contains(futureYear.toString()));
      });
    });
  });

  group('CreatePartRequestParams', () {
    test('should create CreatePartRequestParams with all parameters', () {
      final params = CreatePartRequestParams(
        vehiclePlate: 'EF-456-GH',
        vehicleBrand: 'Toyota',
        vehicleModel: 'Corolla',
        vehicleYear: 2021,
        vehicleEngine: '1.8 Hybrid',
        partType: 'engine',
        partNames: ['Batterie hybride', 'Moteur électrique'],
        additionalInfo: 'État neuf souhaité',
        isAnonymous: true,
        isSellerRequest: false,
      );

      expect(params.vehiclePlate, 'EF-456-GH');
      expect(params.vehicleBrand, 'Toyota');
      expect(params.vehicleModel, 'Corolla');
      expect(params.vehicleYear, 2021);
      expect(params.vehicleEngine, '1.8 Hybrid');
      expect(params.partType, 'engine');
      expect(params.partNames, ['Batterie hybride', 'Moteur électrique']);
      expect(params.additionalInfo, 'État neuf souhaité');
      expect(params.isAnonymous, true);
      expect(params.isSellerRequest, false);
    });

    test('should create CreatePartRequestParams with minimal required parameters', () {
      final params = CreatePartRequestParams(
        partType: 'body',
        partNames: ['Rétroviseur'],
      );

      expect(params.partType, 'body');
      expect(params.partNames, ['Rétroviseur']);
      expect(params.vehiclePlate, null);
      expect(params.vehicleBrand, null);
      expect(params.vehicleModel, null);
      expect(params.vehicleYear, null);
      expect(params.vehicleEngine, null);
      expect(params.additionalInfo, null);
      expect(params.isAnonymous, false);
      expect(params.isSellerRequest, false);
    });

    test('should use default values correctly', () {
      final params = CreatePartRequestParams(
        partType: 'transmission',
        partNames: ['Boîte de vitesses'],
      );

      expect(params.isAnonymous, false);
      expect(params.isSellerRequest, false);
    });

    test('should handle copyWith method', () {
      final originalParams = CreatePartRequestParams(
        partType: 'engine',
        partNames: ['Turbo'],
        vehicleBrand: 'Renault',
        isAnonymous: false,
      );

      final updatedParams = originalParams.copyWith(
        vehicleBrand: 'Peugeot',
        vehicleModel: '308',
        isAnonymous: true,
      );

      expect(updatedParams.vehicleBrand, 'Peugeot');
      expect(updatedParams.vehicleModel, '308');
      expect(updatedParams.isAnonymous, true);
      expect(updatedParams.partType, 'engine'); // unchanged
      expect(updatedParams.partNames, ['Turbo']); // unchanged
    });

    test('should be equal when all properties are the same', () {
      final params1 = CreatePartRequestParams(
        partType: 'body',
        partNames: ['Capot'],
        vehicleBrand: 'BMW',
      );

      final params2 = CreatePartRequestParams(
        partType: 'body',
        partNames: ['Capot'],
        vehicleBrand: 'BMW',
      );

      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));
    });

    test('should not be equal when properties are different', () {
      final params1 = CreatePartRequestParams(
        partType: 'body',
        partNames: ['Capot'],
      );

      final params2 = CreatePartRequestParams(
        partType: 'engine',
        partNames: ['Capot'],
      );

      expect(params1, isNot(equals(params2)));
    });
  });
}