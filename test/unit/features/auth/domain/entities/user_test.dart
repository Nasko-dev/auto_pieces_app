import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/features/auth/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late User testUser;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1);
      testUpdatedAt = DateTime(2024, 1, 2);

      testUser = User(
        id: 'test-user-123',
        email: 'john.doe@example.com',
        userType: 'particulier',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );
    });

    group('Constructor', () {
      test('should create User with all parameters', () {
        expect(testUser.id, 'test-user-123');
        expect(testUser.email, 'john.doe@example.com');
        expect(testUser.userType, 'particulier');
        expect(testUser.createdAt, testCreatedAt);
        expect(testUser.updatedAt, testUpdatedAt);
      });

      test('should create User with minimal required parameters', () {
        final minimalUser = User(
          id: 'minimal-user',
          userType: 'vendeur',
          createdAt: testCreatedAt,
        );

        expect(minimalUser.id, 'minimal-user');
        expect(minimalUser.userType, 'vendeur');
        expect(minimalUser.createdAt, testCreatedAt);
        expect(minimalUser.email, null);
        expect(minimalUser.updatedAt, null);
      });

      test('should handle different user types', () {
        final particulierUser = User(
          id: 'user-1',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final vendeurUser = User(
          id: 'user-2',
          userType: 'vendeur',
          createdAt: testCreatedAt,
        );

        expect(particulierUser.userType, 'particulier');
        expect(vendeurUser.userType, 'vendeur');
      });
    });

    group('Equatable implementation', () {
      test('should be equal when all properties are the same', () {
        final user1 = User(
          id: 'same-id',
          email: 'same@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final user2 = User(
          id: 'same-id',
          email: 'same@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when id is different', () {
        final user1 = User(
          id: 'id-1',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final user2 = User(
          id: 'id-2',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(user1, isNot(equals(user2)));
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });

      test('should not be equal when email is different', () {
        final user1 = User(
          id: 'same-id',
          email: 'user1@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final user2 = User(
          id: 'same-id',
          email: 'user2@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when userType is different', () {
        final user1 = User(
          id: 'same-id',
          email: 'same@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final user2 = User(
          id: 'same-id',
          email: 'same@example.com',
          userType: 'vendeur',
          createdAt: testCreatedAt,
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when createdAt is different', () {
        final user1 = User(
          id: 'same-id',
          userType: 'particulier',
          createdAt: DateTime(2024, 1, 1),
        );

        final user2 = User(
          id: 'same-id',
          userType: 'particulier',
          createdAt: DateTime(2024, 1, 2),
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when updatedAt is different', () {
        final user1 = User(
          id: 'same-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
          updatedAt: DateTime(2024, 1, 1),
        );

        final user2 = User(
          id: 'same-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should handle null values in equality comparison', () {
        final user1 = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
          email: null,
          updatedAt: null,
        );

        final user2 = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
          email: null,
          updatedAt: null,
        );

        expect(user1, equals(user2));
      });

      test('should not be equal when one has null email and other has value', () {
        final user1 = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
          email: null,
        );

        final user2 = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
          email: 'test@example.com',
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when one has null updatedAt and other has value', () {
        final user1 = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
          updatedAt: null,
        );

        final user2 = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user1, isNot(equals(user2)));
      });
    });

    group('props getter', () {
      test('should return correct list of properties', () {
        final props = testUser.props;

        expect(props.length, 5);
        expect(props[0], 'test-user-123'); // id
        expect(props[1], 'john.doe@example.com'); // email
        expect(props[2], 'particulier'); // userType
        expect(props[3], testCreatedAt); // createdAt
        expect(props[4], testUpdatedAt); // updatedAt
      });

      test('should handle null values in props', () {
        final userWithNulls = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
          email: null,
          updatedAt: null,
        );

        final props = userWithNulls.props;

        expect(props.length, 5);
        expect(props[0], 'test-id');
        expect(props[1], null); // email
        expect(props[2], 'particulier');
        expect(props[3], testCreatedAt);
        expect(props[4], null); // updatedAt
      });
    });

    group('Edge cases', () {
      test('should handle empty strings correctly', () {
        final user = User(
          id: '',
          email: '',
          userType: '',
          createdAt: testCreatedAt,
        );

        expect(user.id, '');
        expect(user.email, '');
        expect(user.userType, '');
      });

      test('should handle special characters in email', () {
        final user = User(
          id: 'test-id',
          email: 'user+test@example-domain.co.uk',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(user.email, 'user+test@example-domain.co.uk');
      });

      test('should handle special characters in id', () {
        final user = User(
          id: 'user-123_test@domain',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(user.id, 'user-123_test@domain');
      });

      test('should handle unicode characters', () {
        final user = User(
          id: 'utilisateur-éà',
          email: 'tést@èxàmplè.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(user.id, 'utilisateur-éà');
        expect(user.email, 'tést@èxàmplè.com');
      });

      test('should handle very long strings', () {
        final longId = 'a' * 1000;
        final longEmail = '${'b' * 100}@${'c' * 100}.com';
        final longUserType = 'd' * 500;

        final user = User(
          id: longId,
          email: longEmail,
          userType: longUserType,
          createdAt: testCreatedAt,
        );

        expect(user.id, longId);
        expect(user.email, longEmail);
        expect(user.userType, longUserType);
      });

      test('should handle dates at edge values', () {
        final veryOldDate = DateTime(1900, 1, 1);
        final veryFutureDate = DateTime(2100, 12, 31);

        final user = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: veryOldDate,
          updatedAt: veryFutureDate,
        );

        expect(user.createdAt, veryOldDate);
        expect(user.updatedAt, veryFutureDate);
      });

      test('should handle same createdAt and updatedAt', () {
        final sameDate = DateTime(2024, 6, 15, 10, 30);

        final user = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: sameDate,
          updatedAt: sameDate,
        );

        expect(user.createdAt, sameDate);
        expect(user.updatedAt, sameDate);
        expect(user.createdAt, equals(user.updatedAt));
      });

      test('should handle invalid email format gracefully', () {
        final user = User(
          id: 'test-id',
          email: 'not-an-email',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        // User class doesn't validate email format, so it should accept any string
        expect(user.email, 'not-an-email');
      });

      test('should handle unknown user types', () {
        final user = User(
          id: 'test-id',
          userType: 'unknown_type',
          createdAt: testCreatedAt,
        );

        expect(user.userType, 'unknown_type');
      });
    });

    group('Object behavior', () {
      test('should have consistent toString behavior', () {
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final toString1 = user.toString();
        final toString2 = user.toString();

        expect(toString1, equals(toString2));
        expect(toString1, isA<String>());
        expect(toString1.isNotEmpty, true);
      });

      test('should maintain hashCode consistency', () {
        final user = User(
          id: 'test-id',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final hashCode1 = user.hashCode;
        final hashCode2 = user.hashCode;

        expect(hashCode1, equals(hashCode2));
      });

      test('should have different hashCodes for different objects', () {
        final user1 = User(
          id: 'test-id-1',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        final user2 = User(
          id: 'test-id-2',
          userType: 'particulier',
          createdAt: testCreatedAt,
        );

        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });
    });
  });
}