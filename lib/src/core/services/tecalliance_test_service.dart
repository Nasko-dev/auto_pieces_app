import 'dart:convert';
import 'package:http/http.dart' as http;

class TecAllianceTestService {
  static const String baseUrl = 'https://vehicle-identification.tecalliance.services';
  static const String providerId = '25200';
  static const String apiKey = '2BeBXg6RC5myrQufHsxH8BsjG4BuhvU2Z1zn9fBukD4argoKAzJC';
  
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
    }
  }
}