import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../features/parts/domain/entities/vehicle_info.dart';
import '../errors/failures.dart';
import '../constants/app_constants.dart';

class ImmatriculationService {
  static const String _baseUrl = 'https://vehicle-identification.tecalliance.services';
  static const int _requestTimeoutSeconds = 10;
  
  final String apiUsername; // Gardé pour compatibilité mais non utilisé
  final http.Client httpClient;
  
  ImmatriculationService({
    required this.apiUsername,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();
  
  Future<Either<Failure, VehicleInfo>> getVehicleInfoFromPlate(String plate) async {
    try {
      print('🔍 [TecAllianceAPI] Début recherche pour plaque: $plate');
      final cleanPlate = _cleanPlateNumber(plate);
      print('🔧 [TecAllianceAPI] Plaque nettoyée: $cleanPlate');
      
      if (!_isValidPlateFormat(cleanPlate)) {
        print('❌ [TecAllianceAPI] Format de plaque invalide: $cleanPlate');
        return const Left(
          ValidationFailure('Format de plaque invalide'),
        );
      }
      
      // Construction de l'URL selon la doc Swagger TecAlliance: /api/v1/vrm/{country}/{numberPlate}
      final uri = Uri.parse('$_baseUrl/api/v1/vrm/FR/$cleanPlate');
      
      print('🌐 [TecAllianceAPI] URL de requête: $uri');
      
      final response = await httpClient
          .get(
            uri,
            headers: {
              'X-API-Key': AppConstants.tecAllianceApiKey,
              'X-Provider': AppConstants.tecAllianceProviderId,
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: _requestTimeoutSeconds));
      
      print('📡 [TecAllianceAPI] Code de réponse: ${response.statusCode}');
      print('📄 [TecAllianceAPI] Corps de réponse (${response.body.length} caractères)');
      
      if (response.statusCode != 200) {
        print('❌ [TecAllianceAPI] Erreur serveur: ${response.statusCode}');
        return Left(
          ServerFailure(
            'Erreur serveur: ${response.statusCode} - ${response.body}',
          ),
        );
      }
      
      return _parseResponse(response.body, cleanPlate);
    } on Exception catch (e) {
      print('💥 [TecAllianceAPI] Exception: ${e.toString()}');
      return Left(
        NetworkFailure('Erreur réseau: ${e.toString()}'),
      );
    }
  }
  
  Either<Failure, VehicleInfo> _parseResponse(String responseBody, String plate) {
    try {
      print('🔬 [TecAllianceAPI] Début du parsing JSON...');
      final Map<String, dynamic> data = json.decode(responseBody);
      
      // Vérifier s'il y a des véhicules dans la réponse
      final List<dynamic>? vehicles = data['vehicles'];
      if (vehicles == null || vehicles.isEmpty) {
        print('❌ [TecAllianceAPI] Aucun véhicule trouvé dans la réponse');
        return const Left(
          ServerFailure('Aucun véhicule trouvé pour cette plaque'),
        );
      }
      
      // Prendre le premier véhicule
      final Map<String, dynamic> vehicleData = vehicles.first;
      print('✅ [TecAllianceAPI] Véhicule trouvé, extraction des données...');
      
      final vehicleInfo = _extractVehicleInfo(vehicleData, plate);
      print('🚗 [TecAllianceAPI] VehicleInfo créé: ${vehicleInfo.description}');
      
      // Afficher les informations sur les clics restants
      final int? remainingClicks = data['lastClickCount'];
      if (remainingClicks != null) {
        print('🎫 [TecAllianceAPI] Clics restants: $remainingClicks');
      }
      
      return Right(vehicleInfo);
    } catch (e, stackTrace) {
      print('💥 [TecAllianceAPI] Erreur de parsing: ${e.toString()}');
      print('📚 [TecAllianceAPI] Stack trace: $stackTrace');
      return Left(
        ParsingFailure('Erreur lors du parsing: ${e.toString()}'),
      );
    }
  }
  
  VehicleInfo _extractVehicleInfo(Map<String, dynamic> vehicleData, String plate) {
    final vehicleInfo = vehicleData['vehicleInformation'] as Map<String, dynamic>? ?? {};
    final engines = vehicleData['engine'] as List<dynamic>? ?? [];
    final gearbox = vehicleData['gearbox'] as Map<String, dynamic>? ?? {};
    final brakes = vehicleData['brakes'] as Map<String, dynamic>? ?? {};
    final tyres = vehicleData['tyres'] as List<dynamic>? ?? [];
    final fluids = vehicleData['fluids'] as Map<String, dynamic>? ?? {};
    
    // Extraire les données du moteur (prendre le premier)
    final engine = engines.isNotEmpty ? engines.first as Map<String, dynamic> : <String, dynamic>{};
    final environmental = engine['environmental'] as Map<String, dynamic>? ?? {};
    
    return VehicleInfo(
      registrationNumber: plate,
      make: vehicleInfo['make']?.toString(),
      model: vehicleInfo['model']?.toString(),
      fuelType: engine['fuel']?.toString(),
      bodyStyle: vehicleInfo['bodyName']?.toString(),
      engineSize: engine['capacityLiters']?.toString() ?? 
                  (engine['ccm'] != null ? '${engine['ccm']}cc' : null),
      year: _extractYearFromDate(vehicleInfo['salesStartDate']?.toString()),
      color: vehicleInfo['color']?.toString(),
      vin: vehicleInfo['vin']?.toString(),
      engineNumber: null, // Pas disponible dans TecAlliance
      engineCode: engine['code']?.toString(),
      co2Emissions: environmental['combinedCO2'] as int?,
      transmission: gearbox['type']?.toString(),
      numberOfDoors: vehicleInfo['numberOfDoors'] as int?,
      euroStatus: environmental['euroStandard']?.toString(),
      cylinderCapacity: engine['ccm']?.toString(),
      power: engine['powerKW'] as int? ?? vehicleInfo['powerKW'] as int?,
      powerUnit: 'kW',
      description: _buildDescription(vehicleInfo, engine),
      rawData: vehicleData,
    );
  }
  
  String _buildDescription(Map<String, dynamic> vehicleInfo, Map<String, dynamic> engine) {
    final parts = <String>[];
    
    final make = vehicleInfo['make']?.toString();
    final fullModel = vehicleInfo['fullModel']?.toString();
    final model = vehicleInfo['model']?.toString();
    final capacity = engine['capacityLiters']?.toString();
    final fuel = engine['fuel']?.toString();
    final power = engine['powerHP']?.toString() ?? engine['powerKW']?.toString();
    
    if (make != null) parts.add(make);
    if (fullModel != null) {
      parts.add(fullModel);
    } else if (model != null) {
      parts.add(model);
    }
    
    if (capacity != null) parts.add('${capacity}L');
    if (fuel != null) parts.add(fuel);
    if (power != null) {
      final unit = engine['powerHP'] != null ? 'HP' : 'kW';
      parts.add('${power}$unit');
    }
    
    return parts.join(' - ');
  }
  
  int? _extractYearFromDate(String? dateString) {
    if (dateString == null || dateString.length < 4) return null;
    return int.tryParse(dateString.substring(0, 4));
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
    // TecAlliance retourne le nombre de clics dans chaque réponse
    // On fait une requête test pour obtenir ce nombre
    try {
      print('🎫 [TecAllianceAPI] Vérification des crédits restants...');
      final result = await getVehicleInfoFromPlate('TEST123');
      return result.fold(
        (failure) {
          // Même en cas d'échec, on essaie d'extraire les clics depuis l'erreur
          print('⚠️ [TecAllianceAPI] Impossible de récupérer les crédits directement');
          return const Right(0); // Valeur par défaut
        },
        (vehicleInfo) {
          // Extraire le nombre de clics depuis rawData
          final rawData = vehicleInfo.rawData as Map<String, dynamic>?;
          final clicks = rawData?['lastClickCount'] as int? ?? 0;
          print('✅ [TecAllianceAPI] Crédits restants: $clicks');
          return Right(clicks);
        },
      );
    } catch (e) {
      return Left(NetworkFailure('Erreur lors de la vérification des crédits: $e'));
    }
  }
  
  void dispose() {
    httpClient.close();
  }
}