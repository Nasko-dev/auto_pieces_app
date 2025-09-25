import 'package:flutter_test/flutter_test.dart';
import 'package:cente_pice/src/features/parts/domain/entities/vehicle_info.dart';

void main() {
  group('VehicleInfo Entity', () {
    late VehicleInfo testVehicleInfo;
    late Map<String, dynamic> testJson;

    setUp(() {
      testVehicleInfo = const VehicleInfo(
        registrationNumber: 'AA-123-BB',
        make: 'Renault',
        model: 'Clio',
        fuelType: 'Essence',
        bodyStyle: 'Berline',
        engineSize: '1.2L',
        year: 2020,
        color: 'Bleu',
        vin: '1234567890ABCDEFG',
        engineNumber: 'ENG123456',
        engineCode: 'K4M',
        co2Emissions: 120,
        transmission: 'Manuelle',
        numberOfDoors: 5,
        euroStatus: 'Euro 6',
        cylinderCapacity: '1200',
        power: 75,
        powerUnit: 'kW',
        description: 'Véhicule en bon état',
        rawData: {'api_source': 'tecalliance', 'version': '1.0'},
      );

      testJson = {
        'registrationNumber': 'AA-123-BB',
        'make': 'Renault',
        'model': 'Clio',
        'fuelType': 'Essence',
        'bodyStyle': 'Berline',
        'engineSize': '1.2L',
        'year': 2020,
        'color': 'Bleu',
        'vin': '1234567890ABCDEFG',
        'engineNumber': 'ENG123456',
        'engineCode': 'K4M',
        'co2Emissions': 120,
        'transmission': 'Manuelle',
        'numberOfDoors': 5,
        'euroStatus': 'Euro 6',
        'cylinderCapacity': '1200',
        'power': 75,
        'powerUnit': 'kW',
        'description': 'Véhicule en bon état',
        'rawData': {'api_source': 'tecalliance', 'version': '1.0'},
      };
    });

    group('Constructor', () {
      test('should create VehicleInfo with all parameters', () {
        expect(testVehicleInfo.registrationNumber, 'AA-123-BB');
        expect(testVehicleInfo.make, 'Renault');
        expect(testVehicleInfo.model, 'Clio');
        expect(testVehicleInfo.fuelType, 'Essence');
        expect(testVehicleInfo.bodyStyle, 'Berline');
        expect(testVehicleInfo.engineSize, '1.2L');
        expect(testVehicleInfo.year, 2020);
        expect(testVehicleInfo.color, 'Bleu');
        expect(testVehicleInfo.vin, '1234567890ABCDEFG');
        expect(testVehicleInfo.engineNumber, 'ENG123456');
        expect(testVehicleInfo.engineCode, 'K4M');
        expect(testVehicleInfo.co2Emissions, 120);
        expect(testVehicleInfo.transmission, 'Manuelle');
        expect(testVehicleInfo.numberOfDoors, 5);
        expect(testVehicleInfo.euroStatus, 'Euro 6');
        expect(testVehicleInfo.cylinderCapacity, '1200');
        expect(testVehicleInfo.power, 75);
        expect(testVehicleInfo.powerUnit, 'kW');
        expect(testVehicleInfo.description, 'Véhicule en bon état');
        expect(testVehicleInfo.rawData, {'api_source': 'tecalliance', 'version': '1.0'});
      });

      test('should create VehicleInfo with minimal required parameters', () {
        const minimalVehicleInfo = VehicleInfo(
          registrationNumber: 'BB-456-CC',
        );

        expect(minimalVehicleInfo.registrationNumber, 'BB-456-CC');
        expect(minimalVehicleInfo.make, null);
        expect(minimalVehicleInfo.model, null);
        expect(minimalVehicleInfo.fuelType, null);
        expect(minimalVehicleInfo.year, null);
        expect(minimalVehicleInfo.color, null);
        expect(minimalVehicleInfo.rawData, null);
      });
    });

    group('fromJson factory', () {
      test('should create VehicleInfo from complete JSON', () {
        final vehicleInfo = VehicleInfo.fromJson(testJson);

        expect(vehicleInfo.registrationNumber, 'AA-123-BB');
        expect(vehicleInfo.make, 'Renault');
        expect(vehicleInfo.model, 'Clio');
        expect(vehicleInfo.fuelType, 'Essence');
        expect(vehicleInfo.bodyStyle, 'Berline');
        expect(vehicleInfo.engineSize, '1.2L');
        expect(vehicleInfo.year, 2020);
        expect(vehicleInfo.color, 'Bleu');
        expect(vehicleInfo.vin, '1234567890ABCDEFG');
        expect(vehicleInfo.engineNumber, 'ENG123456');
        expect(vehicleInfo.engineCode, 'K4M');
        expect(vehicleInfo.co2Emissions, 120);
        expect(vehicleInfo.transmission, 'Manuelle');
        expect(vehicleInfo.numberOfDoors, 5);
        expect(vehicleInfo.euroStatus, 'Euro 6');
        expect(vehicleInfo.cylinderCapacity, '1200');
        expect(vehicleInfo.power, 75);
        expect(vehicleInfo.powerUnit, 'kW');
        expect(vehicleInfo.description, 'Véhicule en bon état');
        expect(vehicleInfo.rawData, {'api_source': 'tecalliance', 'version': '1.0'});
      });

      test('should create VehicleInfo from minimal JSON', () {
        final minimalJson = {
          'registrationNumber': 'CC-789-DD',
        };

        final vehicleInfo = VehicleInfo.fromJson(minimalJson);

        expect(vehicleInfo.registrationNumber, 'CC-789-DD');
        expect(vehicleInfo.make, null);
        expect(vehicleInfo.model, null);
        expect(vehicleInfo.year, null);
      });

      test('should handle null values in JSON correctly', () {
        final jsonWithNulls = {
          'registrationNumber': 'DD-000-EE',
          'make': null,
          'model': null,
          'year': null,
          'rawData': null,
        };

        final vehicleInfo = VehicleInfo.fromJson(jsonWithNulls);

        expect(vehicleInfo.registrationNumber, 'DD-000-EE');
        expect(vehicleInfo.make, null);
        expect(vehicleInfo.model, null);
        expect(vehicleInfo.year, null);
        expect(vehicleInfo.rawData, null);
      });

      test('should handle complex rawData in JSON', () {
        final complexJson = {
          'registrationNumber': 'EE-111-FF',
          'make': 'Peugeot',
          'rawData': {
            'api_source': 'tecalliance',
            'response_time': '250ms',
            'confidence': 0.95,
            'additional_info': {
              'warranty': 'active',
              'recalls': []
            }
          },
        };

        final vehicleInfo = VehicleInfo.fromJson(complexJson);

        expect(vehicleInfo.registrationNumber, 'EE-111-FF');
        expect(vehicleInfo.make, 'Peugeot');
        expect(vehicleInfo.rawData, isA<Map<String, dynamic>>());
        expect(vehicleInfo.rawData!['api_source'], 'tecalliance');
        expect(vehicleInfo.rawData!['additional_info'], isA<Map<String, dynamic>>());
      });
    });

    group('toJson method', () {
      test('should convert VehicleInfo to JSON correctly', () {
        final json = testVehicleInfo.toJson();

        expect(json['registrationNumber'], 'AA-123-BB');
        expect(json['make'], 'Renault');
        expect(json['model'], 'Clio');
        expect(json['fuelType'], 'Essence');
        expect(json['year'], 2020);
        expect(json['rawData'], {'api_source': 'tecalliance', 'version': '1.0'});
      });

      test('should handle null values in toJson', () {
        const minimalVehicleInfo = VehicleInfo(
          registrationNumber: 'FF-222-GG',
          make: 'Toyota',
        );

        final json = minimalVehicleInfo.toJson();

        expect(json['registrationNumber'], 'FF-222-GG');
        expect(json['make'], 'Toyota');
        expect(json.containsKey('model'), true);
        expect(json['model'], null);
        expect(json.containsKey('year'), true);
        expect(json['year'], null);
      });
    });

    group('copyWith method', () {
      test('should create new instance with updated values', () {
        final updatedVehicleInfo = testVehicleInfo.copyWith(
          make: 'Citroën',
          model: 'C3',
          year: 2021,
          color: 'Rouge',
        );

        expect(updatedVehicleInfo.registrationNumber, 'AA-123-BB'); // unchanged
        expect(updatedVehicleInfo.make, 'Citroën'); // updated
        expect(updatedVehicleInfo.model, 'C3'); // updated
        expect(updatedVehicleInfo.year, 2021); // updated
        expect(updatedVehicleInfo.color, 'Rouge'); // updated
        expect(updatedVehicleInfo.fuelType, 'Essence'); // unchanged
        expect(updatedVehicleInfo.engineSize, '1.2L'); // unchanged
      });

      test('should keep original values when no parameters provided', () {
        final copiedVehicleInfo = testVehicleInfo.copyWith();

        expect(copiedVehicleInfo.registrationNumber, testVehicleInfo.registrationNumber);
        expect(copiedVehicleInfo.make, testVehicleInfo.make);
        expect(copiedVehicleInfo.model, testVehicleInfo.model);
        expect(copiedVehicleInfo.year, testVehicleInfo.year);
        expect(copiedVehicleInfo.rawData, testVehicleInfo.rawData);
      });

      test('should set values to null when explicitly provided', () {
        final updatedVehicleInfo = testVehicleInfo.copyWith(
          make: null,
          year: null,
          rawData: null,
        );

        expect(updatedVehicleInfo.registrationNumber, 'AA-123-BB'); // unchanged
        expect(updatedVehicleInfo.make, null); // set to null
        expect(updatedVehicleInfo.year, null); // set to null
        expect(updatedVehicleInfo.rawData, null); // set to null
        expect(updatedVehicleInfo.model, 'Clio'); // unchanged
      });
    });

    group('Equality and hashCode', () {
      test('should be equal when all properties are the same', () {
        const vehicleInfo1 = VehicleInfo(
          registrationNumber: 'GG-333-HH',
          make: 'Ford',
          model: 'Focus',
          year: 2019,
        );

        const vehicleInfo2 = VehicleInfo(
          registrationNumber: 'GG-333-HH',
          make: 'Ford',
          model: 'Focus',
          year: 2019,
        );

        expect(vehicleInfo1, equals(vehicleInfo2));
        expect(vehicleInfo1.hashCode, equals(vehicleInfo2.hashCode));
      });

      test('should not be equal when registration numbers are different', () {
        const vehicleInfo1 = VehicleInfo(
          registrationNumber: 'HH-444-II',
          make: 'Volkswagen',
        );

        const vehicleInfo2 = VehicleInfo(
          registrationNumber: 'II-555-JJ',
          make: 'Volkswagen',
        );

        expect(vehicleInfo1, isNot(equals(vehicleInfo2)));
        expect(vehicleInfo1.hashCode, isNot(equals(vehicleInfo2.hashCode)));
      });

      test('should not be equal when any property is different', () {
        const vehicleInfo1 = VehicleInfo(
          registrationNumber: 'JJ-666-KK',
          make: 'BMW',
          year: 2020,
        );

        const vehicleInfo2 = VehicleInfo(
          registrationNumber: 'JJ-666-KK',
          make: 'BMW',
          year: 2021, // different year
        );

        expect(vehicleInfo1, isNot(equals(vehicleInfo2)));
      });

      test('should handle null values in equality comparison', () {
        const vehicleInfo1 = VehicleInfo(
          registrationNumber: 'KK-777-LL',
          make: null,
          year: null,
        );

        const vehicleInfo2 = VehicleInfo(
          registrationNumber: 'KK-777-LL',
          make: null,
          year: null,
        );

        expect(vehicleInfo1, equals(vehicleInfo2));
      });
    });

    group('Edge cases', () {
      test('should handle empty strings correctly', () {
        const vehicleInfo = VehicleInfo(
          registrationNumber: '',
          make: '',
          model: '',
        );

        expect(vehicleInfo.registrationNumber, '');
        expect(vehicleInfo.make, '');
        expect(vehicleInfo.model, '');
      });

      test('should handle special characters in registration number', () {
        const vehicleInfo = VehicleInfo(
          registrationNumber: 'ÀÉ-123-ÇÜ',
          make: 'Mércédés',
        );

        expect(vehicleInfo.registrationNumber, 'ÀÉ-123-ÇÜ');
        expect(vehicleInfo.make, 'Mércédés');
      });

      test('should handle negative values for numeric fields', () {
        const vehicleInfo = VehicleInfo(
          registrationNumber: 'LL-888-MM',
          year: -1,
          co2Emissions: -50,
          power: -10,
        );

        expect(vehicleInfo.year, -1);
        expect(vehicleInfo.co2Emissions, -50);
        expect(vehicleInfo.power, -10);
      });

      test('should handle very large values for numeric fields', () {
        const vehicleInfo = VehicleInfo(
          registrationNumber: 'MM-999-NN',
          year: 9999,
          co2Emissions: 999999,
          power: 999999,
        );

        expect(vehicleInfo.year, 9999);
        expect(vehicleInfo.co2Emissions, 999999);
        expect(vehicleInfo.power, 999999);
      });

      test('should handle empty rawData map', () {
        const vehicleInfo = VehicleInfo(
          registrationNumber: 'NN-000-OO',
          rawData: <String, dynamic>{},
        );

        expect(vehicleInfo.rawData, <String, dynamic>{});
        expect(vehicleInfo.rawData!.isEmpty, true);
      });
    });

    group('JSON serialization roundtrip', () {
      test('should maintain data integrity through JSON roundtrip', () {
        // Convert to JSON and back
        final json = testVehicleInfo.toJson();
        final roundtripVehicleInfo = VehicleInfo.fromJson(json);

        expect(roundtripVehicleInfo, equals(testVehicleInfo));
        expect(roundtripVehicleInfo.registrationNumber, testVehicleInfo.registrationNumber);
        expect(roundtripVehicleInfo.make, testVehicleInfo.make);
        expect(roundtripVehicleInfo.model, testVehicleInfo.model);
        expect(roundtripVehicleInfo.year, testVehicleInfo.year);
        expect(roundtripVehicleInfo.rawData, testVehicleInfo.rawData);
      });

      test('should handle minimal data through JSON roundtrip', () {
        const minimalVehicleInfo = VehicleInfo(
          registrationNumber: 'OO-111-PP',
        );

        final json = minimalVehicleInfo.toJson();
        final roundtripVehicleInfo = VehicleInfo.fromJson(json);

        expect(roundtripVehicleInfo, equals(minimalVehicleInfo));
        expect(roundtripVehicleInfo.registrationNumber, 'OO-111-PP');
        expect(roundtripVehicleInfo.make, null);
      });
    });
  });
}