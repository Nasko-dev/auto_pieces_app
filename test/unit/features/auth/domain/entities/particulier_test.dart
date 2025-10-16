import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/features/auth/domain/entities/particulier.dart';

void main() {
  group('Particulier Entity', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late DateTime testEmailVerifiedAt;
    late Particulier testParticulier;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1);
      testUpdatedAt = DateTime(2024, 1, 2);
      testEmailVerifiedAt = DateTime(2024, 1, 3);

      testParticulier = Particulier(
        id: 'test-id-123',
        deviceId: 'device-123',
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
    });

    group('Constructor', () {
      test('should create Particulier with all parameters', () {
        expect(testParticulier.id, 'test-id-123');
        expect(testParticulier.deviceId, 'device-123');
        expect(testParticulier.email, 'john.doe@example.com');
        expect(testParticulier.firstName, 'John');
        expect(testParticulier.lastName, 'Doe');
        expect(testParticulier.phone, '+33123456789');
        expect(testParticulier.address, '123 Rue de la Paix');
        expect(testParticulier.city, 'Paris');
        expect(testParticulier.zipCode, '75001');
        expect(testParticulier.avatarUrl, 'https://example.com/avatar.jpg');
        expect(testParticulier.isVerified, true);
        expect(testParticulier.isActive, true);
        expect(testParticulier.isAnonymous, false);
        expect(testParticulier.createdAt, testCreatedAt);
        expect(testParticulier.updatedAt, testUpdatedAt);
        expect(testParticulier.emailVerifiedAt, testEmailVerifiedAt);
      });

      test('should create Particulier with minimal required parameters', () {
        final minimalParticulier = Particulier(
          id: 'minimal-id',
          createdAt: testCreatedAt,
        );

        expect(minimalParticulier.id, 'minimal-id');
        expect(minimalParticulier.createdAt, testCreatedAt);
        expect(minimalParticulier.isVerified, false);
        expect(minimalParticulier.isActive, true);
        expect(minimalParticulier.isAnonymous, true);
        expect(minimalParticulier.deviceId, null);
        expect(minimalParticulier.email, null);
        expect(minimalParticulier.firstName, null);
        expect(minimalParticulier.lastName, null);
        expect(minimalParticulier.updatedAt, null);
        expect(minimalParticulier.emailVerifiedAt, null);
      });

      test('should use default values correctly', () {
        final defaultParticulier = Particulier(
          id: 'default-id',
          createdAt: testCreatedAt,
        );

        expect(defaultParticulier.isVerified, false);
        expect(defaultParticulier.isActive, true);
        expect(defaultParticulier.isAnonymous, true);
      });
    });

    group('displayName getter', () {
      test(
          'should return full name when both firstName and lastName are provided',
          () {
        expect(testParticulier.displayName, 'John Doe');
      });

      test('should return firstName when only firstName is provided', () {
        final particulier = Particulier(
          id: 'test-id',
          firstName: 'John',
          lastName: null,
          email: 'john@example.com',
          createdAt: testCreatedAt,
        );
        expect(particulier.displayName, 'John');
      });

      test('should return email username when no names but email is provided',
          () {
        final particulier = Particulier(
          id: 'test-id',
          firstName: null,
          lastName: null,
          email: 'john.doe@example.com',
          createdAt: testCreatedAt,
        );
        expect(particulier.displayName, 'john.doe');
      });

      test('should return "Utilisateur Anonyme" when no names or email', () {
        final particulier = Particulier(
          id: 'test-id',
          firstName: null,
          lastName: null,
          email: null,
          createdAt: testCreatedAt,
        );
        expect(particulier.displayName, 'Utilisateur Anonyme');
      });
    });

    group('hasPersonalInfo getter', () {
      test('should return true when both firstName and lastName are provided',
          () {
        expect(testParticulier.hasPersonalInfo, true);
      });

      test('should return false when firstName is missing', () {
        final particulier = Particulier(
          id: 'test-id',
          firstName: null,
          lastName: 'Doe',
          createdAt: testCreatedAt,
        );
        expect(particulier.hasPersonalInfo, false);
      });

      test('should return false when lastName is missing', () {
        final particulier = Particulier(
          id: 'test-id',
          firstName: 'John',
          lastName: null,
          createdAt: testCreatedAt,
        );
        expect(particulier.hasPersonalInfo, false);
      });

      test('should return false when both names are missing', () {
        final particulier = Particulier(
          id: 'test-id',
          firstName: null,
          lastName: null,
          createdAt: testCreatedAt,
        );
        expect(particulier.hasPersonalInfo, false);
      });
    });

    group('isCompleteProfile getter', () {
      test('should return true when has personal info and phone', () {
        expect(testParticulier.isCompleteProfile, true);
      });

      test('should return false when phone is missing', () {
        final particulier = Particulier(
          id: 'test-id',
          firstName: 'John',
          lastName: 'Doe',
          phone: null,
          createdAt: testCreatedAt,
        );
        expect(particulier.isCompleteProfile, false);
      });

      test('should return false when personal info is missing', () {
        final particulier = Particulier(
          id: 'test-id',
          firstName: null,
          lastName: 'Doe',
          phone: '+33123456789',
          createdAt: testCreatedAt,
        );
        expect(particulier.isCompleteProfile, false);
      });

      test('should return false when both phone and personal info are missing',
          () {
        final particulier = Particulier(
          id: 'test-id',
          firstName: null,
          lastName: 'Doe',
          phone: null,
          createdAt: testCreatedAt,
        );
        expect(particulier.isCompleteProfile, false);
      });
    });

    group('copyWith method', () {
      test('should create new instance with updated values', () {
        final newCreatedAt = DateTime(2024, 2, 1);
        final updatedParticulier = testParticulier.copyWith(
          id: 'new-id',
          email: 'new.email@example.com',
          firstName: 'Jane',
          isVerified: false,
          createdAt: newCreatedAt,
        );

        expect(updatedParticulier.id, 'new-id');
        expect(updatedParticulier.email, 'new.email@example.com');
        expect(updatedParticulier.firstName, 'Jane');
        expect(updatedParticulier.isVerified, false);
        expect(updatedParticulier.createdAt, newCreatedAt);

        // Unchanged values should remain the same
        expect(updatedParticulier.lastName, 'Doe');
        expect(updatedParticulier.phone, '+33123456789');
        expect(updatedParticulier.isActive, true);
        expect(updatedParticulier.updatedAt, testUpdatedAt);
      });

      test('should keep original values when no parameters provided', () {
        final copiedParticulier = testParticulier.copyWith();

        expect(copiedParticulier.id, testParticulier.id);
        expect(copiedParticulier.email, testParticulier.email);
        expect(copiedParticulier.firstName, testParticulier.firstName);
        expect(copiedParticulier.lastName, testParticulier.lastName);
        expect(copiedParticulier.isVerified, testParticulier.isVerified);
        expect(copiedParticulier.createdAt, testParticulier.createdAt);
      });

      test('should preserve existing values when not explicitly changed', () {
        final updatedParticulier = testParticulier.copyWith(
          firstName: 'Jane',
        );

        // Changed value
        expect(updatedParticulier.firstName, 'Jane');
        // Preserved values
        expect(updatedParticulier.deviceId, 'device-123');
        expect(updatedParticulier.email, 'john.doe@example.com');
        expect(updatedParticulier.avatarUrl, 'https://example.com/avatar.jpg');
        expect(updatedParticulier.updatedAt, testUpdatedAt);
      });
    });

    group('Equatable implementation', () {
      test('should be equal when all properties are the same', () {
        final particulier1 = Particulier(
          id: 'same-id',
          email: 'same@example.com',
          firstName: 'John',
          lastName: 'Doe',
          createdAt: testCreatedAt,
        );

        final particulier2 = Particulier(
          id: 'same-id',
          email: 'same@example.com',
          firstName: 'John',
          lastName: 'Doe',
          createdAt: testCreatedAt,
        );

        expect(particulier1, equals(particulier2));
        expect(particulier1.hashCode, equals(particulier2.hashCode));
      });

      test('should not be equal when id is different', () {
        final particulier1 = Particulier(
          id: 'id-1',
          createdAt: testCreatedAt,
        );

        final particulier2 = Particulier(
          id: 'id-2',
          createdAt: testCreatedAt,
        );

        expect(particulier1, isNot(equals(particulier2)));
        expect(particulier1.hashCode, isNot(equals(particulier2.hashCode)));
      });

      test('should not be equal when any property is different', () {
        final particulier1 = testParticulier;
        final particulier2 =
            testParticulier.copyWith(email: 'different@example.com');

        expect(particulier1, isNot(equals(particulier2)));
      });

      test('should handle null values in equality comparison', () {
        final particulier1 = Particulier(
          id: 'test-id',
          createdAt: testCreatedAt,
          email: null,
          firstName: null,
        );

        final particulier2 = Particulier(
          id: 'test-id',
          createdAt: testCreatedAt,
          email: null,
          firstName: null,
        );

        expect(particulier1, equals(particulier2));
      });
    });

    group('Edge cases', () {
      test('should handle empty strings correctly', () {
        final particulier = Particulier(
          id: 'test-id',
          email: '',
          firstName: '',
          lastName: '',
          createdAt: testCreatedAt,
        );

        expect(particulier.email, '');
        expect(particulier.firstName, '');
        expect(particulier.lastName, '');
        expect(
            particulier.displayName, ' '); // firstName + ' ' + lastName = ' '
        expect(particulier.hasPersonalInfo, true); // both are non-null
      });

      test('should handle special characters in email for displayName', () {
        final particulier = Particulier(
          id: 'test-id',
          email: 'user+test@example.co.uk',
          createdAt: testCreatedAt,
        );

        expect(particulier.displayName, 'user+test');
      });

      test('should handle email without @ symbol gracefully', () {
        final particulier = Particulier(
          id: 'test-id',
          email: 'invalid-email',
          createdAt: testCreatedAt,
        );

        expect(particulier.displayName,
            'invalid-email'); // split('@').first on string without @ returns original string
      });
    });
  });
}
