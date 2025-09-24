import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/features/auth/data/models/user_model.dart';
import 'package:cente_pice/src/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late UserModel testUserModel;
    late Map<String, dynamic> testJson;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1, 10, 0);
      testUpdatedAt = DateTime(2024, 1, 2, 15, 30);

      testUserModel = UserModel(
        id: 'test-user-123',
        email: 'user@example.com',
        userType: 'particulier',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

      testJson = {
        'id': 'test-user-123',
        'email': 'user@example.com',
        'userType': 'particulier',
        'createdAt': testCreatedAt.toIso8601String(),
        'updatedAt': testUpdatedAt.toIso8601String(),
      };
    });

    group('Constructor', () {
      test('should create UserModel with all parameters', () {
        expect(testUserModel.id, 'test-user-123');
        expect(testUserModel.email, 'user@example.com');
        expect(testUserModel.userType, 'particulier');
        expect(testUserModel.createdAt, testCreatedAt);
        expect(testUserModel.updatedAt, testUpdatedAt);
      });

      test('should create UserModel with minimal required parameters', () {
        final minimalModel = UserModel(
          id: 'minimal-user',
          userType: 'vendeur',
          createdAt: testCreatedAt,
        );

        expect(minimalModel.id, 'minimal-user');
        expect(minimalModel.userType, 'vendeur');
        expect(minimalModel.createdAt, testCreatedAt);
        expect(minimalModel.email, null);
        expect(minimalModel.updatedAt, null);
      });

      test('should handle different user types', () {
        final particulierModel = UserModel(
          id: 'user-1',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final vendeurModel = UserModel(
          id: 'user-2',
          userType: 'vendeur',
          createdAt: testCreatedAt,
        );

        expect(particulierModel.userType, 'particulier');
        expect(vendeurModel.userType, 'vendeur');
      });

      test('should extend User entity', () {
        expect(testUserModel, isA<User>());
      });
    });

    group('fromJson factory', () {
      test('should create UserModel from complete JSON', () {
        final model = UserModel.fromJson(testJson);

        expect(model.id, 'test-user-123');
        expect(model.email, 'user@example.com');
        expect(model.userType, 'particulier');
        expect(model.createdAt, testCreatedAt);
        expect(model.updatedAt, testUpdatedAt);
      });

      test('should create UserModel from minimal JSON', () {
        final minimalJson = {
          'id': 'minimal-user',
          'userType': 'vendeur',
          'createdAt': testCreatedAt.toIso8601String(),
        };

        final model = UserModel.fromJson(minimalJson);

        expect(model.id, 'minimal-user');
        expect(model.userType, 'vendeur');
        expect(model.createdAt, testCreatedAt);
        expect(model.email, null);
        expect(model.updatedAt, null);
      });

      test('should handle null values in JSON correctly', () {
        final jsonWithNulls = {
          'id': 'test-user',
          'email': null,
          'userType': 'particulier',
          'createdAt': testCreatedAt.toIso8601String(),
          'updatedAt': null,
        };

        final model = UserModel.fromJson(jsonWithNulls);

        expect(model.id, 'test-user');
        expect(model.email, null);
        expect(model.userType, 'particulier');
        expect(model.createdAt, testCreatedAt);
        expect(model.updatedAt, null);
      });

      test('should parse DateTime fields correctly', () {
        final model = UserModel.fromJson(testJson);

        expect(model.createdAt, equals(testCreatedAt));
        expect(model.updatedAt, equals(testUpdatedAt));
        expect(model.createdAt.toIso8601String(), testCreatedAt.toIso8601String());
        expect(model.updatedAt!.toIso8601String(), testUpdatedAt.toIso8601String());
      });
    });

    group('toJson method', () {
      test('should convert UserModel to JSON correctly', () {
        final json = testUserModel.toJson();

        expect(json['id'], 'test-user-123');
        expect(json['email'], 'user@example.com');
        expect(json['userType'], 'particulier');
        expect(json['createdAt'], testCreatedAt.toIso8601String());
        expect(json['updatedAt'], testUpdatedAt.toIso8601String());
      });

      test('should handle null values in toJson', () {
        final minimalModel = UserModel(
          id: 'minimal-user',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final json = minimalModel.toJson();

        expect(json['id'], 'minimal-user');
        expect(json['userType'], 'particulier');
        expect(json['createdAt'], testCreatedAt.toIso8601String());
        expect(json.containsKey('email'), true);
        expect(json['email'], null);
        expect(json.containsKey('updatedAt'), true);
        expect(json['updatedAt'], null);
      });

      test('should serialize DateTime fields correctly', () {
        final json = testUserModel.toJson();

        expect(json['createdAt'], isA<String>());
        expect(json['updatedAt'], isA<String>());
        expect(json['createdAt'], testCreatedAt.toIso8601String());
        expect(json['updatedAt'], testUpdatedAt.toIso8601String());
      });
    });

    group('fromEntity factory', () {
      test('should create UserModel from User entity', () {
        final entity = User(
          id: 'entity-id',
          email: 'entity@example.com',
          userType: 'vendeur',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final model = UserModel.fromEntity(entity);

        expect(model.id, 'entity-id');
        expect(model.email, 'entity@example.com');
        expect(model.userType, 'vendeur');
        expect(model.createdAt, testCreatedAt);
        expect(model.updatedAt, testUpdatedAt);
        expect(model, isA<UserModel>());
        expect(model, isA<User>());
      });

      test('should handle minimal User entity', () {
        final minimalEntity = User(
          id: 'minimal-entity',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final model = UserModel.fromEntity(minimalEntity);

        expect(model.id, 'minimal-entity');
        expect(model.userType, 'particulier');
        expect(model.createdAt, testCreatedAt);
        expect(model.email, null);
        expect(model.updatedAt, null);
      });

      test('should preserve all properties from entity', () {
        final entity = User(
          id: 'full-entity',
          email: 'full@example.com',
          userType: 'vendeur',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final model = UserModel.fromEntity(entity);

        // Verify all properties are copied
        expect(model.id, entity.id);
        expect(model.email, entity.email);
        expect(model.userType, entity.userType);
        expect(model.createdAt, entity.createdAt);
        expect(model.updatedAt, entity.updatedAt);

        // Verify they are separate instances
        expect(model, isNot(same(entity)));
      });
    });

    group('JSON serialization roundtrip', () {
      test('should maintain data integrity through JSON roundtrip', () {
        final json = testUserModel.toJson();
        final roundtripModel = UserModel.fromJson(json);

        expect(roundtripModel.id, testUserModel.id);
        expect(roundtripModel.email, testUserModel.email);
        expect(roundtripModel.userType, testUserModel.userType);
        expect(roundtripModel.createdAt, testUserModel.createdAt);
        expect(roundtripModel.updatedAt, testUserModel.updatedAt);
      });

      test('should handle minimal data through JSON roundtrip', () {
        final minimalModel = UserModel(
          id: 'minimal-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final json = minimalModel.toJson();
        final roundtripModel = UserModel.fromJson(json);

        expect(roundtripModel.id, 'minimal-id');
        expect(roundtripModel.userType, 'particulier');
        expect(roundtripModel.createdAt, testCreatedAt);
        expect(roundtripModel.email, null);
        expect(roundtripModel.updatedAt, null);
      });

      test('should handle complex data through JSON roundtrip', () {
        final complexModel = UserModel(
          id: 'complex-id-with-special-chars_123',
          email: 'complex+test@example-domain.co.uk',
          userType: 'vendeur',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final json = complexModel.toJson();
        final roundtripModel = UserModel.fromJson(json);

        expect(roundtripModel.id, complexModel.id);
        expect(roundtripModel.email, complexModel.email);
        expect(roundtripModel.userType, complexModel.userType);
        expect(roundtripModel.createdAt, complexModel.createdAt);
        expect(roundtripModel.updatedAt, complexModel.updatedAt);
      });
    });

    group('Inheritance behavior', () {
      test('should inherit all User methods and properties', () {
        expect(testUserModel.id, 'test-user-123');
        expect(testUserModel.email, 'user@example.com');
        expect(testUserModel.userType, 'particulier');
        expect(testUserModel.createdAt, testCreatedAt);
        expect(testUserModel.updatedAt, testUpdatedAt);
      });

      test('should work with User type checks', () {
        final User user = testUserModel;

        expect(user, isA<User>());
        expect(user, isA<UserModel>());
        expect(user.id, testUserModel.id);
        expect(user.email, testUserModel.email);
      });

      test('should maintain Equatable behavior from parent', () {
        final model1 = UserModel(
          id: 'same-id',
          email: 'same@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final model2 = UserModel(
          id: 'same-id',
          email: 'same@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final model1 = testUserModel;
        final model2 = UserModel(
          id: testUserModel.id,
          email: 'different@example.com',
          userType: testUserModel.userType,
          createdAt: testUserModel.createdAt,
          updatedAt: testUserModel.updatedAt,
        );

        expect(model1, isNot(equals(model2)));
        expect(model1.hashCode, isNot(equals(model2.hashCode)));
      });

      test('should have consistent props behavior', () {
        final props = testUserModel.props;

        expect(props, contains(testUserModel.id));
        expect(props, contains(testUserModel.email));
        expect(props, contains(testUserModel.userType));
        expect(props, contains(testUserModel.createdAt));
        expect(props, contains(testUserModel.updatedAt));
        expect(props.length, 5);
      });
    });

    group('Edge cases', () {
      test('should handle empty strings correctly', () {
        final model = UserModel(
          id: '',
          email: '',
          userType: '',
          createdAt: testCreatedAt,
        );

        expect(model.id, '');
        expect(model.email, '');
        expect(model.userType, '');
        expect(model.createdAt, testCreatedAt);

        final json = model.toJson();
        expect(json['id'], '');
        expect(json['email'], '');
        expect(json['userType'], '');
      });

      test('should handle special characters in fields', () {
        final model = UserModel(
          id: 'user-123_test@domain',
          email: 'user+test@example-domain.co.uk',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(model.id, 'user-123_test@domain');
        expect(model.email, 'user+test@example-domain.co.uk');
        expect(model.userType, 'particulier');

        final json = model.toJson();
        final roundtripModel = UserModel.fromJson(json);
        expect(roundtripModel.id, model.id);
        expect(roundtripModel.email, model.email);
      });

      test('should handle unicode characters', () {
        final model = UserModel(
          id: 'utilisateur-éà',
          email: 'tést@èxàmplè.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(model.id, 'utilisateur-éà');
        expect(model.email, 'tést@èxàmplè.com');

        final json = model.toJson();
        final roundtripModel = UserModel.fromJson(json);
        expect(roundtripModel.id, model.id);
        expect(roundtripModel.email, model.email);
      });

      test('should handle very long strings', () {
        final longId = 'a' * 1000;
        final longEmail = '${'b' * 100}@${'c' * 100}.com';
        final longUserType = 'd' * 500;

        final model = UserModel(
          id: longId,
          email: longEmail,
          userType: longUserType,
          createdAt: testCreatedAt,
        );

        expect(model.id, longId);
        expect(model.email, longEmail);
        expect(model.userType, longUserType);
        expect(model.id.length, 1000);
        expect(model.email!.length, greaterThan(200));
      });

      test('should handle dates at edge values', () {
        final veryOldDate = DateTime(1900, 1, 1);
        final veryFutureDate = DateTime(2100, 12, 31);

        final model = UserModel(
          id: 'test-id',
          userType: 'particulier',
          createdAt: veryOldDate,
          updatedAt: veryFutureDate,
        );

        expect(model.createdAt, veryOldDate);
        expect(model.updatedAt, veryFutureDate);

        final json = model.toJson();
        expect(json['createdAt'], veryOldDate.toIso8601String());
        expect(json['updatedAt'], veryFutureDate.toIso8601String());

        final roundtripModel = UserModel.fromJson(json);
        expect(roundtripModel.createdAt, veryOldDate);
        expect(roundtripModel.updatedAt, veryFutureDate);
      });

      test('should handle same createdAt and updatedAt', () {
        final sameDate = DateTime(2024, 6, 15, 10, 30);

        final model = UserModel(
          id: 'test-id',
          userType: 'particulier',
          createdAt: sameDate,
          updatedAt: sameDate,
        );

        expect(model.createdAt, sameDate);
        expect(model.updatedAt, sameDate);
        expect(model.createdAt, equals(model.updatedAt));
      });

      test('should handle invalid email format gracefully', () {
        final model = UserModel(
          id: 'test-id',
          email: 'not-an-email',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(model.email, 'not-an-email');

        final json = model.toJson();
        final roundtripModel = UserModel.fromJson(json);
        expect(roundtripModel.email, 'not-an-email');
      });

      test('should handle unknown user types', () {
        final model = UserModel(
          id: 'test-id',
          userType: 'unknown_type',
          createdAt: testCreatedAt,
        );

        expect(model.userType, 'unknown_type');

        final json = model.toJson();
        final roundtripModel = UserModel.fromJson(json);
        expect(roundtripModel.userType, 'unknown_type');
      });
    });

    group('Object behavior', () {
      test('should have consistent toString behavior', () {
        final model = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final toString1 = model.toString();
        final toString2 = model.toString();

        expect(toString1, equals(toString2));
        expect(toString1, isA<String>());
        expect(toString1.isNotEmpty, true);
      });

      test('should maintain hashCode consistency', () {
        final model = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final hashCode1 = model.hashCode;
        final hashCode2 = model.hashCode;

        expect(hashCode1, equals(hashCode2));
      });

      test('should have different hashCodes for different objects', () {
        final model1 = UserModel(
          id: 'test-id-1',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final model2 = UserModel(
          id: 'test-id-2',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(model1.hashCode, isNot(equals(model2.hashCode)));
      });
    });
  });
}