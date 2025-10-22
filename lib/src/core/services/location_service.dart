import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Vérifie les permissions et récupère la position actuelle
  static Future<LocationResult> getCurrentLocation() async {
    try {
      // Vérifier si le service de localisation est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.error(
            'Le service de localisation est désactivé. Veuillez l\'activer dans les paramètres.');
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.error('Permission de localisation refusée.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.error(
            'Permission de localisation refusée définitivement. Veuillez l\'autoriser dans les paramètres de l\'app.');
      }

      // Récupérer la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Géocodage inverse pour obtenir l'adresse
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: 'fr_FR',
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return LocationResult.success(
          latitude: position.latitude,
          longitude: position.longitude,
          address: _formatAddress(placemark),
          city: placemark.locality ?? '',
          postalCode: placemark.postalCode ?? '',
          country: placemark.country ?? 'France',
        );
      } else {
        return LocationResult.success(
          latitude: position.latitude,
          longitude: position.longitude,
          address: 'Adresse non trouvée',
          city: '',
          postalCode: '',
          country: 'France',
        );
      }
    } catch (e) {
      String errorMessage;
      if (e is LocationServiceDisabledException) {
        errorMessage = 'Le service de localisation est désactivé.';
      } else if (e is PermissionDeniedException) {
        errorMessage = 'Permission de localisation refusée.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Impossible d\'obtenir la position (timeout).';
      } else {
        errorMessage = 'Erreur lors de la récupération de la position: $e';
      }
      return LocationResult.error(errorMessage);
    }
  }

  /// Formate l'adresse à partir d'un Placemark
  static String _formatAddress(Placemark placemark) {
    List<String> addressParts = [];

    // Utiliser les propriétés disponibles du Placemark
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }

    if (addressParts.isEmpty) {
      if (placemark.thoroughfare != null &&
          placemark.thoroughfare!.isNotEmpty) {
        addressParts.add(placemark.thoroughfare!);
      }
    }

    if (addressParts.isEmpty) {
      if (placemark.name != null && placemark.name!.isNotEmpty) {
        addressParts.add(placemark.name!);
      }
    }

    return addressParts.join(' ').isEmpty
        ? 'Adresse non disponible'
        : addressParts.join(' ');
  }

  /// Calcule la distance entre deux points en kilomètres
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // Conversion en km
  }
}

/// Classe pour le résultat de géolocalisation
class LocationResult {
  final bool isSuccess;
  final String? error;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;

  LocationResult._({
    required this.isSuccess,
    this.error,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.postalCode,
    this.country,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
    required String address,
    required String city,
    required String postalCode,
    required String country,
  }) {
    return LocationResult._(
      isSuccess: true,
      latitude: latitude,
      longitude: longitude,
      address: address,
      city: city,
      postalCode: postalCode,
      country: country,
    );
  }

  factory LocationResult.error(String error) {
    return LocationResult._(
      isSuccess: false,
      error: error,
    );
  }
}
