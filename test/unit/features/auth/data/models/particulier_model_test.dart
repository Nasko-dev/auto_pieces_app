import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/features/auth/data/models/particulier_model.dart';
import 'package:cente_pice/src/features/auth/domain/entities/particulier.dart';

void main() {
  group('ParticulierModel', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late DateTime testEmailVerifiedAt;
    late ParticulierModel testParticulierModel;
    late Map<String, dynamic> testJson;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1, 10, 0);
      testUpdatedAt = DateTime(2024, 1, 2, 15, 30);
      testEmailVerifiedAt = DateTime(2024, 1, 3, 12, 0);

      testParticulierModel = ParticulierModel(
        id: 'test-id-123',
        deviceId: 'device-456',
        email: 'john.doe@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '+33123456789',
        address: '123 Rue de la Paix',
        city: 'Paris',
        zipCode: '75001',
        avatarUrl: 'https://example.com/avatar.jpg',
        isVerified: true,
        isActive: true,
        isAnonymous: false,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        emailVerifiedAt: testEmailVerifiedAt,
      );

      testJson = {
        'id': 'test-id-123',
        'device_id': 'device-456',
        'email': 'john.doe@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'phone': '+33123456789',
        'address': '123 Rue de la Paix',
        'city': 'Paris',
        'zip_code': '75001',
        'avatar_url': 'https://example.com/avatar.jpg',
        'is_verified': true,
        'is_active': true,
        'is_anonymous': false,
        'created_at': testCreatedAt.toIso8601String(),
        'updated_at': testUpdatedAt.toIso8601String(),
        'email_verified_at': testEmailVerifiedAt.toIso8601String(),
      };
    });

    group('Constructor', () {
      test('should create ParticulierModel with all parameters', () {
        expect(testParticulierModel.id, 'test-id-123');
        expect(testParticulierModel.deviceId, 'device-456');
        expect(testParticulierModel.email, 'john.doe@example.com');
        expect(testParticulierModel.firstName, 'John');
        expect(testParticulierModel.lastName, 'Doe');
        expect(testParticulierModel.phone, '+33123456789');
        expect(testParticulierModel.address, '123 Rue de la Paix');
        expect(testParticulierModel.city, 'Paris');
        expect(testParticulierModel.zipCode, '75001');
        expect(testParticulierModel.avatarUrl, 'https://example.com/avatar.jpg');
        expect(testParticulierModel.isVerified, true);
        expect(testParticulierModel.isActive, true);
        expect(testParticulierModel.isAnonymous, false);
        expect(testParticulierModel.createdAt, testCreatedAt);
        expect(testParticulierModel.updatedAt, testUpdatedAt);
        expect(testParticulierModel.emailVerifiedAt, testEmailVerifiedAt);
      });

      test('should create ParticulierModel with minimal required parameters', () {
        final minimalModel = ParticulierModel(
          id: 'minimal-id',
          createdAt: testCreatedAt,
        );

        expect(minimalModel.id, 'minimal-id');
        expect(minimalModel.createdAt, testCreatedAt);
        expect(minimalModel.deviceId, null);
        expect(minimalModel.email, null);
        expect(minimalModel.firstName, null);
        expect(minimalModel.lastName, null);
        expect(minimalModel.isVerified, false);
        expect(minimalModel.isActive, true);
        expect(minimalModel.isAnonymous, true);
        expect(minimalModel.updatedAt, null);
        expect(minimalModel.emailVerifiedAt, null);
      });

      test('should use default values correctly', () {
        final defaultModel = ParticulierModel(
          id: 'default-id',
          createdAt: testCreatedAt,
        );

        expect(defaultModel.isVerified, false);
        expect(defaultModel.isActive, true);
        expect(defaultModel.isAnonymous, true);
      });

      test('should extend Particulier entity', () {
        expect(testParticulierModel, isA<Particulier>());
      });
    });

    group('fromJson factory', () {
      test('should create ParticulierModel from complete JSON', () {
        final model = ParticulierModel.fromJson(testJson);

        expect(model.id, 'test-id-123');
        expect(model.deviceId, 'device-456');
        expect(model.email, 'john.doe@example.com');
        expect(model.firstName, 'John');
        expect(model.lastName, 'Doe');
        expect(model.phone, '+33123456789');
        expect(model.address, '123 Rue de la Paix');
        expect(model.city, 'Paris');
        expect(model.zipCode, '75001');
        expect(model.avatarUrl, 'https://example.com/avatar.jpg');
        expect(model.isVerified, true);
        expect(model.isActive, true);
        expect(model.isAnonymous, false);
        expect(model.createdAt, testCreatedAt);
        expect(model.updatedAt, testUpdatedAt);
        expect(model.emailVerifiedAt, testEmailVerifiedAt);
      });

      test('should create ParticulierModel from minimal JSON', () {
        final minimalJson = {
          'id': 'minimal-id',
          'created_at': testCreatedAt.toIso8601String(),
        };

        final model = ParticulierModel.fromJson(minimalJson);

        expect(model.id, 'minimal-id');
        expect(model.createdAt, testCreatedAt);
        expect(model.deviceId, null);
        expect(model.email, null);
        expect(model.firstName, null);
        expect(model.lastName, null);
        expect(model.isVerified, false);
        expect(model.isActive, true);
        expect(model.isAnonymous, true);
      });

      test('should handle null values in JSON correctly', () {
        final jsonWithNulls = {
          'id': 'test-id',
          'device_id': null,
          'email': null,
          'first_name': null,
          'last_name': null,
          'phone': null,
          'address': null,
          'city': null,
          'zip_code': null,
          'avatar_url': null,
          'is_verified': false,
          'is_active': true,
          'is_anonymous': true,
          'created_at': testCreatedAt.toIso8601String(),
          'updated_at': null,
          'email_verified_at': null,
        };

        final model = ParticulierModel.fromJson(jsonWithNulls);

        expect(model.id, 'test-id');
        expect(model.deviceId, null);
        expect(model.email, null);
        expect(model.firstName, null);
        expect(model.lastName, null);
        expect(model.phone, null);
        expect(model.address, null);
        expect(model.city, null);
        expect(model.zipCode, null);
        expect(model.avatarUrl, null);
        expect(model.updatedAt, null);
        expect(model.emailVerifiedAt, null);
      });

      test('should handle snake_case field names correctly', () {
        expect(testJson['device_id'], isNotNull);
        expect(testJson['first_name'], isNotNull);
        expect(testJson['last_name'], isNotNull);
        expect(testJson['zip_code'], isNotNull);
        expect(testJson['avatar_url'], isNotNull);
        expect(testJson['is_verified'], isNotNull);
        expect(testJson['is_active'], isNotNull);
        expect(testJson['is_anonymous'], isNotNull);
        expect(testJson['created_at'], isNotNull);
        expect(testJson['updated_at'], isNotNull);
        expect(testJson['email_verified_at'], isNotNull);
      });
    });

    group('toJson method', () {
      test('should convert ParticulierModel to JSON correctly', () {
        final json = testParticulierModel.toJson();

        expect(json['id'], 'test-id-123');
        expect(json['device_id'], 'device-456');
        expect(json['email'], 'john.doe@example.com');
        expect(json['first_name'], 'John');
        expect(json['last_name'], 'Doe');
        expect(json['phone'], '+33123456789');
        expect(json['address'], '123 Rue de la Paix');
        expect(json['city'], 'Paris');
        expect(json['zip_code'], '75001');
        expect(json['avatar_url'], 'https://example.com/avatar.jpg');
        expect(json['is_verified'], true);
        expect(json['is_active'], true);
        expect(json['is_anonymous'], false);
        expect(json['created_at'], testCreatedAt.toIso8601String());
        expect(json['updated_at'], testUpdatedAt.toIso8601String());
        expect(json['email_verified_at'], testEmailVerifiedAt.toIso8601String());
      });

      test('should handle null values in toJson', () {
        final minimalModel = ParticulierModel(
          id: 'minimal-id',
          createdAt: testCreatedAt,
        );

        final json = minimalModel.toJson();

        expect(json['id'], 'minimal-id');
        expect(json['created_at'], testCreatedAt.toIso8601String());
        expect(json.containsKey('device_id'), true);
        expect(json['device_id'], null);
        expect(json.containsKey('email'), true);
        expect(json['email'], null);
        expect(json['is_verified'], false);
        expect(json['is_active'], true);
        expect(json['is_anonymous'], true);
      });
    });

    group('fromEntity factory', () {
      test('should create ParticulierModel from Particulier entity', () {
        final entity = Particulier(
          id: 'entity-id',
          deviceId: 'entity-device',
          email: 'entity@example.com',
          firstName: 'EntityFirst',
          lastName: 'EntityLast',
          phone: '+33987654321',
          address: '456 Entity Street',
          city: 'EntityCity',
          zipCode: '12345',
          avatarUrl: 'https://example.com/entity-avatar.jpg',
          isVerified: true,
          isActive: false,
          isAnonymous: false,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          emailVerifiedAt: testEmailVerifiedAt,
        );

        final model = ParticulierModel.fromEntity(entity);

        expect(model.id, 'entity-id');
        expect(model.deviceId, 'entity-device');
        expect(model.email, 'entity@example.com');
        expect(model.firstName, 'EntityFirst');
        expect(model.lastName, 'EntityLast');
        expect(model.phone, '+33987654321');
        expect(model.address, '456 Entity Street');
        expect(model.city, 'EntityCity');
        expect(model.zipCode, '12345');
        expect(model.avatarUrl, 'https://example.com/entity-avatar.jpg');
        expect(model.isVerified, true);
        expect(model.isActive, false);
        expect(model.isAnonymous, false);
        expect(model.createdAt, testCreatedAt);
        expect(model.updatedAt, testUpdatedAt);
        expect(model.emailVerifiedAt, testEmailVerifiedAt);
      });

      test('should handle minimal Particulier entity', () {
        final minimalEntity = Particulier(
          id: 'minimal-entity',
          createdAt: testCreatedAt,
        );

        final model = ParticulierModel.fromEntity(minimalEntity);

        expect(model.id, 'minimal-entity');
        expect(model.createdAt, testCreatedAt);
        expect(model.deviceId, null);
        expect(model.email, null);
        expect(model.isVerified, false);
        expect(model.isActive, true);
        expect(model.isAnonymous, true);
      });
    });

    group('fromAnonymousAuth factory', () {
      test('should create anonymous ParticulierModel correctly', () {
        final model = ParticulierModel.fromAnonymousAuth(
          id: 'anonymous-id',
          deviceId: 'anonymous-device',
          createdAt: testCreatedAt,
        );

        expect(model.id, 'anonymous-id');
        expect(model.deviceId, 'anonymous-device');
        expect(model.createdAt, testCreatedAt);
        expect(model.isAnonymous, true);
        expect(model.isVerified, false);
        expect(model.email, null);
        expect(model.firstName, null);
        expect(model.lastName, null);
        expect(model.updatedAt, null);
        expect(model.emailVerifiedAt, null);
      });

      test('should set correct default values for anonymous user', () {
        final model = ParticulierModel.fromAnonymousAuth(
          id: 'anonymous-id',
          deviceId: 'anonymous-device',
          createdAt: testCreatedAt,
        );

        expect(model.isAnonymous, true);
        expect(model.isVerified, false);
        expect(model.isActive, true);
      });
    });

    group('fromSupabaseAuth factory', () {
      test('should create verified ParticulierModel from Supabase auth', () {
        final model = ParticulierModel.fromSupabaseAuth(
          id: 'supabase-id',
          email: 'supabase@example.com',
          createdAt: testCreatedAt,
          emailConfirmedAt: testEmailVerifiedAt,
        );

        expect(model.id, 'supabase-id');
        expect(model.email, 'supabase@example.com');
        expect(model.createdAt, testCreatedAt);
        expect(model.emailVerifiedAt, testEmailVerifiedAt);
        expect(model.isVerified, true);
        expect(model.isAnonymous, false);
      });

      test('should create unverified ParticulierModel when no emailConfirmedAt', () {
        final model = ParticulierModel.fromSupabaseAuth(
          id: 'supabase-id',
          email: 'supabase@example.com',
          createdAt: testCreatedAt,
        );

        expect(model.id, 'supabase-id');
        expect(model.email, 'supabase@example.com');
        expect(model.createdAt, testCreatedAt);
        expect(model.emailVerifiedAt, null);
        expect(model.isVerified, false);
        expect(model.isAnonymous, false);
      });

      test('should set correct default values for Supabase user', () {
        final model = ParticulierModel.fromSupabaseAuth(
          id: 'supabase-id',
          email: 'supabase@example.com',
          createdAt: testCreatedAt,
        );

        expect(model.isAnonymous, false);
        expect(model.isActive, true);
        expect(model.deviceId, null);
        expect(model.firstName, null);
        expect(model.lastName, null);
      });
    });

    group('toInsert method', () {
      test('should convert to insert format with snake_case keys', () {
        final insertData = testParticulierModel.toInsert();

        expect(insertData['id'], 'test-id-123');
        expect(insertData['device_id'], 'device-456');
        expect(insertData['email'], 'john.doe@example.com');
        expect(insertData['first_name'], 'John');
        expect(insertData['last_name'], 'Doe');
        expect(insertData['phone'], '+33123456789');
        expect(insertData['address'], '123 Rue de la Paix');
        expect(insertData['city'], 'Paris');
        expect(insertData['zip_code'], '75001');
        expect(insertData['avatar_url'], 'https://example.com/avatar.jpg');
        expect(insertData['is_verified'], true);
        expect(insertData['is_active'], true);
        expect(insertData['is_anonymous'], false);
        expect(insertData['created_at'], testCreatedAt.toIso8601String());
        expect(insertData['updated_at'], testUpdatedAt.toIso8601String());
        expect(insertData['email_verified_at'], testEmailVerifiedAt.toIso8601String());
      });

      test('should handle null values in toInsert', () {
        final minimalModel = ParticulierModel(
          id: 'minimal-id',
          createdAt: testCreatedAt,
        );

        final insertData = minimalModel.toInsert();

        expect(insertData['id'], 'minimal-id');
        expect(insertData['device_id'], null);
        expect(insertData['email'], null);
        expect(insertData['first_name'], null);
        expect(insertData['last_name'], null);
        expect(insertData['phone'], null);
        expect(insertData['address'], null);
        expect(insertData['city'], null);
        expect(insertData['zip_code'], null);
        expect(insertData['avatar_url'], null);
        expect(insertData['is_verified'], false);
        expect(insertData['is_active'], true);
        expect(insertData['is_anonymous'], true);
        expect(insertData['created_at'], testCreatedAt.toIso8601String());
        expect(insertData['updated_at'], null);
        expect(insertData['email_verified_at'], null);
      });
    });

    group('copyWith method', () {
      test('should create new instance with updated values', () {
        final newCreatedAt = DateTime(2024, 3, 1);
        final updatedModel = testParticulierModel.copyWith(
          id: 'new-id',
          email: 'new.email@example.com',
          firstName: 'Jane',
          isVerified: false,
          createdAt: newCreatedAt,
        );

        expect(updatedModel.id, 'new-id');
        expect(updatedModel.email, 'new.email@example.com');
        expect(updatedModel.firstName, 'Jane');
        expect(updatedModel.isVerified, false);
        expect(updatedModel.createdAt, newCreatedAt);

        // Unchanged values should remain the same
        expect(updatedModel.lastName, 'Doe');
        expect(updatedModel.phone, '+33123456789');
        expect(updatedModel.isActive, true);
        expect(updatedModel.updatedAt, testUpdatedAt);
        expect(updatedModel, isA<ParticulierModel>());
      });

      test('should keep original values when no parameters provided', () {
        final copiedModel = testParticulierModel.copyWith();

        expect(copiedModel.id, testParticulierModel.id);
        expect(copiedModel.email, testParticulierModel.email);
        expect(copiedModel.firstName, testParticulierModel.firstName);
        expect(copiedModel.lastName, testParticulierModel.lastName);
        expect(copiedModel.isVerified, testParticulierModel.isVerified);
        expect(copiedModel.createdAt, testParticulierModel.createdAt);
        expect(copiedModel, isA<ParticulierModel>());
      });

      test('should preserve existing values when not explicitly changed', () {
        final updatedModel = testParticulierModel.copyWith(
          firstName: 'Alice',
          isVerified: false,
        );

        // Changed values
        expect(updatedModel.firstName, 'Alice');
        expect(updatedModel.isVerified, false);
        // Preserved values
        expect(updatedModel.deviceId, 'device-456');
        expect(updatedModel.email, 'john.doe@example.com');
        expect(updatedModel.lastName, 'Doe');
        expect(updatedModel.phone, '+33123456789');
        expect(updatedModel.updatedAt, testUpdatedAt);
        expect(updatedModel.emailVerifiedAt, testEmailVerifiedAt);
        expect(updatedModel, isA<ParticulierModel>());
      });
    });

    group('JSON serialization roundtrip', () {
      test('should maintain data integrity through JSON roundtrip', () {
        final json = testParticulierModel.toJson();
        final roundtripModel = ParticulierModel.fromJson(json);

        expect(roundtripModel.id, testParticulierModel.id);
        expect(roundtripModel.deviceId, testParticulierModel.deviceId);
        expect(roundtripModel.email, testParticulierModel.email);
        expect(roundtripModel.firstName, testParticulierModel.firstName);
        expect(roundtripModel.lastName, testParticulierModel.lastName);
        expect(roundtripModel.phone, testParticulierModel.phone);
        expect(roundtripModel.address, testParticulierModel.address);
        expect(roundtripModel.city, testParticulierModel.city);
        expect(roundtripModel.zipCode, testParticulierModel.zipCode);
        expect(roundtripModel.avatarUrl, testParticulierModel.avatarUrl);
        expect(roundtripModel.isVerified, testParticulierModel.isVerified);
        expect(roundtripModel.isActive, testParticulierModel.isActive);
        expect(roundtripModel.isAnonymous, testParticulierModel.isAnonymous);
        expect(roundtripModel.createdAt, testParticulierModel.createdAt);
        expect(roundtripModel.updatedAt, testParticulierModel.updatedAt);
        expect(roundtripModel.emailVerifiedAt, testParticulierModel.emailVerifiedAt);
      });

      test('should handle minimal data through JSON roundtrip', () {
        final minimalModel = ParticulierModel(
          id: 'minimal-id',
          createdAt: testCreatedAt,
        );

        final json = minimalModel.toJson();
        final roundtripModel = ParticulierModel.fromJson(json);

        expect(roundtripModel.id, 'minimal-id');
        expect(roundtripModel.createdAt, testCreatedAt);
        expect(roundtripModel.deviceId, null);
        expect(roundtripModel.email, null);
        expect(roundtripModel.isVerified, false);
        expect(roundtripModel.isActive, true);
        expect(roundtripModel.isAnonymous, true);
      });
    });

    group('Inheritance behavior', () {
      test('should inherit all Particulier methods', () {
        expect(testParticulierModel.displayName, 'John Doe');
        expect(testParticulierModel.hasPersonalInfo, true);
        expect(testParticulierModel.isCompleteProfile, true);
      });

      test('should work with Particulier type checks', () {
        final Particulier particulier = testParticulierModel;

        expect(particulier, isA<Particulier>());
        expect(particulier, isA<ParticulierModel>());
        expect(particulier.displayName, 'John Doe');
      });

      test('should maintain Equatable behavior from parent', () {
        final model1 = ParticulierModel(
          id: 'same-id',
          email: 'same@example.com',
          firstName: 'Same',
          lastName: 'Name',
          createdAt: testCreatedAt,
        );

        final model2 = ParticulierModel(
          id: 'same-id',
          email: 'same@example.com',
          firstName: 'Same',
          lastName: 'Name',
          createdAt: testCreatedAt,
        );

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });
    });

    group('Edge cases', () {
      test('should handle empty strings correctly', () {
        final model = ParticulierModel(
          id: '',
          deviceId: '',
          email: '',
          firstName: '',
          lastName: '',
          createdAt: testCreatedAt,
        );

        expect(model.id, '');
        expect(model.deviceId, '');
        expect(model.email, '');
        expect(model.firstName, '');
        expect(model.lastName, '');
        expect(model.displayName, ' '); // firstName + ' ' + lastName
      });

      test('should handle special characters in fields', () {
        final model = ParticulierModel(
          id: 'test-id',
          email: 'test+tag@example-domain.co.uk',
          firstName: 'Jean-François',
          lastName: 'Müller',
          address: '123 Rue de l\'Église & Mairie',
          createdAt: testCreatedAt,
        );

        expect(model.email, 'test+tag@example-domain.co.uk');
        expect(model.firstName, 'Jean-François');
        expect(model.lastName, 'Müller');
        expect(model.address, '123 Rue de l\'Église & Mairie');
      });

      test('should handle very long URL correctly', () {
        final longUrl = 'https://example.com/${'a' * 1000}.jpg';
        final model = ParticulierModel(
          id: 'test-id',
          avatarUrl: longUrl,
          createdAt: testCreatedAt,
        );

        expect(model.avatarUrl, longUrl);
        expect(model.avatarUrl!.length, greaterThan(1000));
      });

      test('should handle dates at edge values', () {
        final veryOldDate = DateTime(1900, 1, 1);
        final veryFutureDate = DateTime(2100, 12, 31);

        final model = ParticulierModel(
          id: 'test-id',
          createdAt: veryOldDate,
          updatedAt: veryFutureDate,
          emailVerifiedAt: veryFutureDate,
        );

        expect(model.createdAt, veryOldDate);
        expect(model.updatedAt, veryFutureDate);
        expect(model.emailVerifiedAt, veryFutureDate);

        final json = model.toJson();
        expect(json['created_at'], veryOldDate.toIso8601String());
        expect(json['updated_at'], veryFutureDate.toIso8601String());
        expect(json['email_verified_at'], veryFutureDate.toIso8601String());
      });
    });
  });
}