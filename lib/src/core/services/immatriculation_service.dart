import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../../features/parts/domain/entities/vehicle_info.dart';
import '../errors/failures.dart';

class ImmatriculationService {
  static const String _baseUrl = 'https://www.regcheck.org.uk/api/reg.asmx';
  static const int _requestTimeoutSeconds = 10;
  
  final String apiUsername;
  final http.Client httpClient;
  
  ImmatriculationService({
    required this.apiUsername,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();
  
  Future<Either<Failure, VehicleInfo>> getVehicleInfoFromPlate(String plate) async {
    try {
      print('🔍 [ImmatriculationAPI] Début recherche pour plaque: $plate');
      final cleanPlate = _cleanPlateNumber(plate);
      print('🔧 [ImmatriculationAPI] Plaque nettoyée: $cleanPlate');
      
      if (!_isValidPlateFormat(cleanPlate)) {
        print('❌ [ImmatriculationAPI] Format de plaque invalide: $cleanPlate');
        return const Left(
          ValidationFailure('Format de plaque invalide'),
        );
      }
      
      final uri = Uri.parse(
        '$_baseUrl/CheckFrance'
        '?RegistrationNumber=$cleanPlate'
        '&username=$apiUsername',
      );
      
      print('🌐 [ImmatriculationAPI] URL de requête: $uri');
      print('👤 [ImmatriculationAPI] Username utilisé: $apiUsername');
      
      final response = await httpClient
          .get(uri)
          .timeout(const Duration(seconds: _requestTimeoutSeconds));
      
      print('📡 [ImmatriculationAPI] Code de réponse: ${response.statusCode}');
      print('📄 [ImmatriculationAPI] Corps de réponse (${response.body.length} caractères): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
      
      if (response.statusCode != 200) {
        print('❌ [ImmatriculationAPI] Erreur serveur: ${response.statusCode}');
        return Left(
          ServerFailure(
            'Erreur serveur: ${response.statusCode} - ${response.body}',
          ),
        );
      }
      
      return _parseResponse(response.body, cleanPlate);
    } on Exception catch (e) {
      print('💥 [ImmatriculationAPI] Exception: ${e.toString()}');
      return Left(
        NetworkFailure('Erreur réseau: ${e.toString()}'),
      );
    }
  }
  
  Either<Failure, VehicleInfo> _parseResponse(String responseBody, String plate) {
    try {
      print('🔬 [ImmatriculationAPI] Début du parsing XML...');
      final doc = xml.XmlDocument.parse(responseBody);
      
      // Log tous les éléments trouvés
      print('📋 [ImmatriculationAPI] Éléments XML trouvés:');
      doc.findAllElements('*').forEach((element) {
        print('  - ${element.name}: ${element.text.length > 100 ? element.text.substring(0, 100) + "..." : element.text}');
      });
      
      final vehicleJsonNode = doc.findAllElements('vehicleJson').firstOrNull;
      if (vehicleJsonNode == null) {
        print('❌ [ImmatriculationAPI] Aucun noeud vehicleJson trouvé dans la réponse');
        // Cherchons d'autres noeuds possibles
        final vehicleDataNode = doc.findAllElements('vehicleData').firstOrNull;
        final errorNode = doc.findAllElements('error').firstOrNull;
        final messageNode = doc.findAllElements('message').firstOrNull;
        
        if (errorNode != null) {
          print('⚠️ [ImmatriculationAPI] Erreur API: ${errorNode.text}');
        }
        if (messageNode != null) {
          print('ℹ️ [ImmatriculationAPI] Message API: ${messageNode.text}');
        }
        
        return const Left(
          ServerFailure('Aucune information trouvée pour cette plaque'),
        );
      }
      
      final jsonStr = vehicleJsonNode.text.trim();
      print('📝 [ImmatriculationAPI] JSON extrait (${jsonStr.length} caractères)');
      
      if (jsonStr.isEmpty) {
        print('❌ [ImmatriculationAPI] JSON vide');
        return const Left(
          ServerFailure('Données vides retournées par le serveur'),
        );
      }
      
      print('🔄 [ImmatriculationAPI] Décodage JSON...');
      final Map<String, dynamic> vehicleData = json.decode(jsonStr);
      print('✅ [ImmatriculationAPI] JSON décodé avec succès');
      print('📊 [ImmatriculationAPI] Clés trouvées: ${vehicleData.keys.join(', ')}');
      
      final vehicleInfo = _extractVehicleInfo(vehicleData, plate);
      print('🚗 [ImmatriculationAPI] VehicleInfo créé: ${vehicleInfo.description}');
      
      return Right(vehicleInfo);
    } catch (e, stackTrace) {
      print('💥 [ImmatriculationAPI] Erreur de parsing: ${e.toString()}');
      print('📚 [ImmatriculationAPI] Stack trace: $stackTrace');
      return Left(
        ParsingFailure('Erreur lors du parsing: ${e.toString()}'),
      );
    }
  }
  
  VehicleInfo _extractVehicleInfo(Map<String, dynamic> data, String plate) {
    final baseData = data['vehicle'] ?? data;
    
    return VehicleInfo(
      registrationNumber: plate,
      make: _extractField(baseData, ['CarMake', 'MakeDescription', 'Make']),
      model: _extractField(baseData, ['CarModel', 'ModelDescription', 'Model']),
      fuelType: _extractField(baseData, ['FuelType', 'Fuel']),
      bodyStyle: _extractField(baseData, ['BodyStyle', 'Body']),
      engineSize: _extractField(baseData, ['EngineSize', 'EngineCapacity']),
      year: _extractIntField(baseData, ['RegistrationYear', 'Year', 'YearOfManufacture']),
      color: _extractField(baseData, ['Colour', 'Color']),
      vin: _extractField(baseData, ['VinOriginal', 'VIN', 'ChassisNumber']),
      engineNumber: _extractField(baseData, ['EngineNumber']),
      engineCode: _extractField(baseData, ['EngineCode']),
      co2Emissions: _extractIntField(baseData, ['Co2Emissions', 'CO2']),
      transmission: _extractField(baseData, ['Transmission', 'Gearbox']),
      numberOfDoors: _extractIntField(baseData, ['NumberOfDoors', 'Doors']),
      euroStatus: _extractField(baseData, ['EuroStatus', 'EuroNorm']),
      cylinderCapacity: _extractField(baseData, ['CylinderCapacity']),
      power: _extractIntField(baseData, ['Power', 'PowerBHP']),
      powerUnit: _extractField(baseData, ['PowerUnit']),
      description: _buildDescription(baseData),
      rawData: baseData,
    );
  }
  
  String? _extractField(Map<String, dynamic> data, List<String> possibleKeys) {
    for (final key in possibleKeys) {
      if (data.containsKey(key)) {
        final value = data[key];
        
        if (value is Map && value.containsKey('CurrentTextValue')) {
          final textValue = value['CurrentTextValue']?.toString();
          if (textValue != null && textValue.isNotEmpty) {
            return textValue;
          }
        }
        
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return null;
  }
  
  int? _extractIntField(Map<String, dynamic> data, List<String> possibleKeys) {
    final stringValue = _extractField(data, possibleKeys);
    if (stringValue != null) {
      return int.tryParse(stringValue);
    }
    return null;
  }
  
  String _buildDescription(Map<String, dynamic> data) {
    final parts = <String>[];
    
    final make = _extractField(data, ['CarMake', 'MakeDescription', 'Make']);
    final model = _extractField(data, ['CarModel', 'ModelDescription', 'Model']);
    final year = _extractField(data, ['RegistrationYear', 'Year']);
    final engine = _extractField(data, ['EngineSize', 'EngineCapacity']);
    final fuel = _extractField(data, ['FuelType', 'Fuel']);
    
    if (make != null) parts.add(make);
    if (model != null) parts.add(model);
    if (year != null) parts.add(year);
    if (engine != null) parts.add(engine);
    if (fuel != null) parts.add(fuel);
    
    return parts.join(' - ');
  }
  
  String _cleanPlateNumber(String plate) {
    return plate
        .toUpperCase()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('·', '')
        .replaceAll('•', '');
  }
  
  bool _isValidPlateFormat(String plate) {
    if (plate.isEmpty || plate.length < 6) return false;
    
    final validPattern = RegExp(r'^[A-Z0-9]+$');
    return validPattern.hasMatch(plate);
  }
  
  Future<Either<Failure, int>> checkRemainingCredits() async {
    try {
      final uri = Uri.parse(
        'https://www.regcheck.org.uk/ajax/getcredits.aspx?username=$apiUsername',
      );
      
      final response = await httpClient
          .get(uri)
          .timeout(const Duration(seconds: _requestTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final credits = int.tryParse(response.body) ?? 0;
        return Right(credits);
      }
      
      return const Left(ServerFailure('Impossible de vérifier les crédits'));
    } catch (e) {
      return Left(NetworkFailure('Erreur réseau: ${e.toString()}'));
    }
  }
  
  void dispose() {
    httpClient.close();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}