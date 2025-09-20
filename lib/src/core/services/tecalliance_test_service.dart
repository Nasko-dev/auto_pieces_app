import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class TecAllianceTestService {
  static String get baseUrl => AppConstants.tecAllianceBaseUrl;
  static String get providerId => AppConstants.tecAllianceProviderId;
  static String get apiKey => AppConstants.tecAllianceApiKey;
  
  static Future<void> testAllEndpoints() async {
    final testPlate = 'AB123CD';
    final endpoints = [
      '/api/v1/vehicles/lookup',
      '/api/vehicles/search',
      '/api/vrm/lookup',
      '/vrm/search',
      '/vehicle-identification',
      '/lookup',
      '/search',
    ];
    
    
    for (final endpoint in endpoints) {
      
      // Test 1: Query parameters
      await _testMethod1(endpoint, testPlate);
      
      // Test 2: Headers
      await _testMethod2(endpoint, testPlate);
      
      // Test 3: Bearer token
      await _testMethod3(endpoint, testPlate);
      
      // Test 4: POST request
      await _testMethod4(endpoint, testPlate);
    }
  }
  
  // Method 1: Query parameters
  static Future<void> _testMethod1(String endpoint, String plate) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint')
          .replace(queryParameters: {
        'providerId': providerId,
        'apiKey': apiKey,
        'vrm': plate,
      });
      
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
      // Ignorer l'erreur silencieusement
    }
  }
  
  // Method 2: Headers
  static Future<void> _testMethod2(String endpoint, String plate) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint')
          .replace(queryParameters: {'vrm': plate});
      
      final response = await http.get(
        url,
        headers: {
          'X-Provider-Id': providerId,
          'X-API-Key': apiKey,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
      // Ignorer l'erreur silencieusement
    }
  }
  
  // Method 3: Bearer token
  static Future<void> _testMethod3(String endpoint, String plate) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint')
          .replace(queryParameters: {'vrm': plate});
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
      // Ignorer l'erreur silencieusement
    }
  }
  
  // Method 4: POST request
  static Future<void> _testMethod4(String endpoint, String plate) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'providerId': providerId,
          'apiKey': apiKey,
          'vrm': plate,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
      // Ignorer l'erreur silencieusement
    }
  }
}