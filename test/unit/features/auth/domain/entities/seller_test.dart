import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/features/auth/domain/entities/seller.dart';

void main() {
  group('Seller Entity', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late DateTime testEmailVerifiedAt;
    late Seller testSeller;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1);
      testUpdatedAt = DateTime(2024, 1, 2);
      testEmailVerifiedAt = DateTime(2024, 1, 3);

      testSeller = Seller(
        id: 'test-seller-123',
        email: 'seller@example.com',
        firstName: 'Jean',
        lastName: 'Martin',
        companyName: 'Pièces Auto SARL',
        phone: '+33123456789',
        address: '456 Rue du Commerce',
        city: 'Lyon',
        zipCode: '69001',
        siret: '12345678901234',
        isVerified: true,
        isActive: true,
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        emailVerifiedAt: testEmailVerifiedAt,
      );
    });

    group('Constructor', () {
      test('should create Seller with all parameters', () {
        expect(testSeller.id, 'test-seller-123');
        expect(testSeller.email, 'seller@example.com');
        expect(testSeller.firstName, 'Jean');
        expect(testSeller.lastName, 'Martin');
        expect(testSeller.companyName, 'Pièces Auto SARL');
        expect(testSeller.phone, '+33123456789');
        expect(testSeller.address, '456 Rue du Commerce');
        expect(testSeller.city, 'Lyon');
        expect(testSeller.zipCode, '69001');
        expect(testSeller.siret, '12345678901234');
        expect(testSeller.isVerified, true);
        expect(testSeller.isActive, true);
        expect(testSeller.createdAt, testCreatedAt);
        expect(testSeller.updatedAt, testUpdatedAt);
        expect(testSeller.emailVerifiedAt, testEmailVerifiedAt);
      });

      test('should create Seller with minimal required parameters', () {
        final minimalSeller = Seller(
          id: 'minimal-seller',
          email: 'minimal@example.com',
          createdAt: testCreatedAt,
        );

        expect(minimalSeller.id, 'minimal-seller');
        expect(minimalSeller.email, 'minimal@example.com');
        expect(minimalSeller.createdAt, testCreatedAt);
        expect(minimalSeller.firstName, null);
        expect(minimalSeller.lastName, null);
        expect(minimalSeller.companyName, null);
        expect(minimalSeller.phone, null);
        expect(minimalSeller.address, null);
        expect(minimalSeller.city, null);
        expect(minimalSeller.zipCode, null);
        expect(minimalSeller.siret, null);
        expect(minimalSeller.isVerified, false);
        expect(minimalSeller.isActive, true);
        expect(minimalSeller.updatedAt, null);
        expect(minimalSeller.emailVerifiedAt, null);
      });

      test('should use default values correctly', () {
        final defaultSeller = Seller(
          id: 'default-seller',
          email: 'default@example.com',
          createdAt: testCreatedAt,
        );

        expect(defaultSeller.isVerified, false);
        expect(defaultSeller.isActive, true);
      });
    });

    group('displayName getter', () {
      test('should return company name when available', () {
        expect(testSeller.displayName, 'Pièces Auto SARL');
      });

      test('should return full name when no company but has first and last name', () {
        final seller = testSeller.copyWith(companyName: null);
        expect(seller.displayName, 'Jean Martin');
      });

      test('should return email username when no company or names', () {
        final seller = testSeller.copyWith(
          companyName: null,
          firstName: null,
          lastName: null,
        );
        expect(seller.displayName, 'seller');
      });

      test('should return company name even when empty string', () {
        final seller = testSeller.copyWith(companyName: '');
        expect(seller.displayName, 'Jean Martin');
      });

      test('should prioritize company name over personal names', () {
        final seller = Seller(
          id: 'test-id',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          companyName: 'Test Company',
          createdAt: testCreatedAt,
        );

        expect(seller.displayName, 'Test Company');
      });

      test('should handle only firstName available', () {
        final seller = testSeller.copyWith(
          companyName: null,
          lastName: null,
        );
        expect(seller.displayName, 'seller');
      });

      test('should handle only lastName available', () {
        final seller = testSeller.copyWith(
          companyName: null,
          firstName: null,
        );
        expect(seller.displayName, 'seller');
      });

      test('should handle email with special characters', () {
        final seller = testSeller.copyWith(
          companyName: null,
          firstName: null,
          lastName: null,
          email: 'user+test@example-domain.co.uk',
        );
        expect(seller.displayName, 'user+test');
      });

      test('should handle email without @ symbol gracefully', () {
        final seller = testSeller.copyWith(
          companyName: null,
          firstName: null,
          lastName: null,
          email: 'invalid-email',
        );
        expect(seller.displayName, 'invalid-email');
      });
    });

    group('hasCompanyInfo getter', () {
      test('should return true when both companyName and siret are provided', () {
        expect(testSeller.hasCompanyInfo, true);
      });

      test('should return false when companyName is missing', () {
        final seller = testSeller.copyWith(companyName: null);
        expect(seller.hasCompanyInfo, false);
      });

      test('should return false when siret is missing', () {
        final seller = testSeller.copyWith(siret: null);
        expect(seller.hasCompanyInfo, false);
      });

      test('should return false when both companyName and siret are missing', () {
        final seller = testSeller.copyWith(
          companyName: null,
          siret: null,
        );
        expect(seller.hasCompanyInfo, false);
      });

      test('should return false when companyName is empty string', () {
        final seller = testSeller.copyWith(companyName: '');
        expect(seller.hasCompanyInfo, false);
      });

      test('should return false when siret is empty string', () {
        final seller = testSeller.copyWith(siret: '');
        expect(seller.hasCompanyInfo, false);
      });
    });

    group('hasPersonalInfo getter', () {
      test('should return true when both firstName and lastName are provided', () {
        expect(testSeller.hasPersonalInfo, true);
      });

      test('should return false when firstName is missing', () {
        final seller = testSeller.copyWith(firstName: null);
        expect(seller.hasPersonalInfo, false);
      });

      test('should return false when lastName is missing', () {
        final seller = testSeller.copyWith(lastName: null);
        expect(seller.hasPersonalInfo, false);
      });

      test('should return false when both firstName and lastName are missing', () {
        final seller = testSeller.copyWith(
          firstName: null,
          lastName: null,
        );
        expect(seller.hasPersonalInfo, false);
      });

      test('should return true when firstName and lastName are empty strings', () {
        final seller = testSeller.copyWith(
          firstName: '',
          lastName: '',
        );
        expect(seller.hasPersonalInfo, true);
      });
    });

    group('isCompleteProfile getter', () {
      test('should return true when has company info', () {
        final seller = testSeller.copyWith(
          firstName: null,
          lastName: null,
        );
        expect(seller.isCompleteProfile, true);
      });

      test('should return true when has personal info', () {
        final seller = testSeller.copyWith(
          companyName: null,
          siret: null,
        );
        expect(seller.isCompleteProfile, true);
      });

      test('should return true when has both company and personal info', () {
        expect(testSeller.isCompleteProfile, true);
      });

      test('should return false when has neither company nor personal info', () {
        final seller = testSeller.copyWith(
          companyName: null,
          siret: null,
          firstName: null,
          lastName: null,
        );
        expect(seller.isCompleteProfile, false);
      });

      test('should return false when has incomplete company info only', () {
        final seller = testSeller.copyWith(
          companyName: 'Company Name',
          siret: null,
          firstName: null,
          lastName: null,
        );
        expect(seller.isCompleteProfile, false);
      });

      test('should return false when has incomplete personal info only', () {
        final seller = testSeller.copyWith(
          companyName: null,
          siret: null,
          firstName: 'Jean',
          lastName: null,
        );
        expect(seller.isCompleteProfile, false);
      });
    });

    group('copyWith method', () {
      test('should create new instance with updated values', () {
        final newCreatedAt = DateTime(2024, 2, 1);
        final updatedSeller = testSeller.copyWith(
          id: 'new-seller-id',
          email: 'new.seller@example.com',
          firstName: 'Pierre',
          companyName: 'Nouvelle Société',
          isVerified: false,
          createdAt: newCreatedAt,
        );

        expect(updatedSeller.id, 'new-seller-id');
        expect(updatedSeller.email, 'new.seller@example.com');
        expect(updatedSeller.firstName, 'Pierre');
        expect(updatedSeller.companyName, 'Nouvelle Société');
        expect(updatedSeller.isVerified, false);
        expect(updatedSeller.createdAt, newCreatedAt);

        // Unchanged values should remain the same
        expect(updatedSeller.lastName, 'Martin');
        expect(updatedSeller.phone, '+33123456789');
        expect(updatedSeller.isActive, true);
        expect(updatedSeller.updatedAt, testUpdatedAt);
      });

      test('should keep original values when no parameters provided', () {
        final copiedSeller = testSeller.copyWith();

        expect(copiedSeller.id, testSeller.id);
        expect(copiedSeller.email, testSeller.email);
        expect(copiedSeller.firstName, testSeller.firstName);
        expect(copiedSeller.lastName, testSeller.lastName);
        expect(copiedSeller.companyName, testSeller.companyName);
        expect(copiedSeller.isVerified, testSeller.isVerified);
        expect(copiedSeller.createdAt, testSeller.createdAt);
      });

      test('should preserve existing values when not explicitly changed', () {
        final updatedSeller = testSeller.copyWith(
          firstName: 'Pierre',
          isVerified: false,
        );

        // Changed values
        expect(updatedSeller.firstName, 'Pierre');
        expect(updatedSeller.isVerified, false);
        // Preserved values
        expect(updatedSeller.lastName, 'Martin');
        expect(updatedSeller.companyName, 'Pièces Auto SARL');
        expect(updatedSeller.phone, '+33123456789');
        expect(updatedSeller.address, '456 Rue du Commerce');
        expect(updatedSeller.updatedAt, testUpdatedAt);
        expect(updatedSeller.emailVerifiedAt, testEmailVerifiedAt);
      });
    });

    group('Equatable implementation', () {
      test('should be equal when all properties are the same', () {
        final seller1 = Seller(
          id: 'same-id',
          email: 'same@example.com',
          firstName: 'Jean',
          lastName: 'Martin',
          companyName: 'Same Company',
          createdAt: testCreatedAt,
        );

        final seller2 = Seller(
          id: 'same-id',
          email: 'same@example.com',
          firstName: 'Jean',
          lastName: 'Martin',
          companyName: 'Same Company',
          createdAt: testCreatedAt,
        );

        expect(seller1, equals(seller2));
        expect(seller1.hashCode, equals(seller2.hashCode));
      });

      test('should not be equal when id is different', () {
        final seller1 = Seller(
          id: 'id-1',
          email: 'same@example.com',
          createdAt: testCreatedAt,
        );

        final seller2 = Seller(
          id: 'id-2',
          email: 'same@example.com',
          createdAt: testCreatedAt,
        );

        expect(seller1, isNot(equals(seller2)));
        expect(seller1.hashCode, isNot(equals(seller2.hashCode)));
      });

      test('should not be equal when email is different', () {
        final seller1 = testSeller;
        final seller2 = testSeller.copyWith(email: 'different@example.com');

        expect(seller1, isNot(equals(seller2)));
      });

      test('should not be equal when companyName is different', () {
        final seller1 = testSeller;
        final seller2 = testSeller.copyWith(companyName: 'Different Company');

        expect(seller1, isNot(equals(seller2)));
      });

      test('should not be equal when boolean fields are different', () {
        final seller1 = testSeller;
        final seller2 = testSeller.copyWith(isVerified: false);

        expect(seller1, isNot(equals(seller2)));
      });

      test('should handle null values in equality comparison', () {
        final seller1 = Seller(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: testCreatedAt,
          firstName: null,
          lastName: null,
          companyName: null,
        );

        final seller2 = Seller(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: testCreatedAt,
          firstName: null,
          lastName: null,
          companyName: null,
        );

        expect(seller1, equals(seller2));
      });
    });

    group('props getter', () {
      test('should return correct list of properties', () {
        final props = testSeller.props;

        expect(props.length, 15);
        expect(props[0], 'test-seller-123'); // id
        expect(props[1], 'seller@example.com'); // email
        expect(props[2], 'Jean'); // firstName
        expect(props[3], 'Martin'); // lastName
        expect(props[4], 'Pièces Auto SARL'); // companyName
        expect(props[5], '+33123456789'); // phone
        expect(props[6], '456 Rue du Commerce'); // address
        expect(props[7], 'Lyon'); // city
        expect(props[8], '69001'); // zipCode
        expect(props[9], '12345678901234'); // siret
        expect(props[10], true); // isVerified
        expect(props[11], true); // isActive
        expect(props[12], testCreatedAt); // createdAt
        expect(props[13], testUpdatedAt); // updatedAt
        expect(props[14], testEmailVerifiedAt); // emailVerifiedAt
      });

      test('should handle null values in props', () {
        final sellerWithNulls = Seller(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: testCreatedAt,
        );

        final props = sellerWithNulls.props;

        expect(props.length, 15);
        expect(props[0], 'test-id');
        expect(props[1], 'test@example.com');
        expect(props[2], null); // firstName
        expect(props[3], null); // lastName
        expect(props[4], null); // companyName
        expect(props[10], false); // isVerified (default)
        expect(props[11], true); // isActive (default)
        expect(props[13], null); // updatedAt
        expect(props[14], null); // emailVerifiedAt
      });
    });

    group('Edge cases', () {
      test('should handle empty strings correctly', () {
        final seller = Seller(
          id: '',
          email: '',
          firstName: '',
          lastName: '',
          companyName: '',
          siret: '',
          createdAt: testCreatedAt,
        );

        expect(seller.id, '');
        expect(seller.email, '');
        expect(seller.firstName, '');
        expect(seller.lastName, '');
        expect(seller.companyName, '');
        expect(seller.siret, '');
        expect(seller.displayName, ' '); // firstName + ' ' + lastName
        expect(seller.hasPersonalInfo, true); // both are non-null
        expect(seller.hasCompanyInfo, false); // empty strings are falsy
      });

      test('should handle special characters in names and company', () {
        final seller = Seller(
          id: 'test-id',
          email: 'test@example.com',
          firstName: 'Jean-François',
          lastName: 'Müller',
          companyName: 'Société & Associés',
          createdAt: testCreatedAt,
        );

        expect(seller.firstName, 'Jean-François');
        expect(seller.lastName, 'Müller');
        expect(seller.companyName, 'Société & Associés');
        expect(seller.displayName, 'Société & Associés');
      });

      test('should handle very long strings', () {
        final longString = 'a' * 1000;
        final seller = Seller(
          id: longString,
          email: '${longString}@example.com',
          firstName: longString,
          lastName: longString,
          companyName: longString,
          createdAt: testCreatedAt,
        );

        expect(seller.id.length, 1000);
        expect(seller.firstName!.length, 1000);
        expect(seller.displayName, longString); // Should be company name
      });

      test('should handle special SIRET formats', () {
        final seller = testSeller.copyWith(siret: '123 456 789 01234');

        expect(seller.siret, '123 456 789 01234');
        expect(seller.hasCompanyInfo, true);
      });

      test('should handle international phone formats', () {
        final seller = testSeller.copyWith(phone: '+1-555-123-4567');

        expect(seller.phone, '+1-555-123-4567');
      });

      test('should handle different zip code formats', () {
        final seller = testSeller.copyWith(zipCode: '75001-PARIS');

        expect(seller.zipCode, '75001-PARIS');
      });

      test('should handle dates at edge values', () {
        final veryOldDate = DateTime(1900, 1, 1);
        final veryFutureDate = DateTime(2100, 12, 31);

        final seller = Seller(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: veryOldDate,
          updatedAt: veryFutureDate,
          emailVerifiedAt: veryFutureDate,
        );

        expect(seller.createdAt, veryOldDate);
        expect(seller.updatedAt, veryFutureDate);
        expect(seller.emailVerifiedAt, veryFutureDate);
      });

      test('should handle same timestamps', () {
        final sameDate = DateTime(2024, 6, 15, 10, 30);

        final seller = Seller(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: sameDate,
          updatedAt: sameDate,
          emailVerifiedAt: sameDate,
        );

        expect(seller.createdAt, sameDate);
        expect(seller.updatedAt, sameDate);
        expect(seller.emailVerifiedAt, sameDate);
      });
    });

    group('Object behavior', () {
      test('should have consistent toString behavior', () {
        final seller = Seller(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: testCreatedAt,
        );

        final toString1 = seller.toString();
        final toString2 = seller.toString();

        expect(toString1, equals(toString2));
        expect(toString1, isA<String>());
        expect(toString1.isNotEmpty, true);
      });

      test('should maintain hashCode consistency', () {
        final seller = Seller(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: testCreatedAt,
        );

        final hashCode1 = seller.hashCode;
        final hashCode2 = seller.hashCode;

        expect(hashCode1, equals(hashCode2));
      });

      test('should have different hashCodes for different objects', () {
        final seller1 = Seller(
          id: 'test-id-1',
          email: 'test1@example.com',
          createdAt: testCreatedAt,
        );

        final seller2 = Seller(
          id: 'test-id-2',
          email: 'test2@example.com',
          createdAt: testCreatedAt,
        );

        expect(seller1.hashCode, isNot(equals(seller2.hashCode)));
      });
    });
  });
}