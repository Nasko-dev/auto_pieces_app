class AppConstants {
  static const String appName = 'Pièces d\'Occasion';
  static const String appVersion = '1.0.0';

  // Supabase Configuration
  static const String supabaseUrl = 'https://gekeygkohcchdckujfwa.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdla2V5Z2tvaGNjaGRja3VqZndhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTgyMTEsImV4cCI6MjA3MTM3NDIxMX0.N2cd9uINT6iEQynOhTeWx2EZNqqF9j7W2-v4OZuVaC8'; // Remplacez par votre publishable key

  // API Endpoints
  static const String baseUrl = 'https://api.example.com';

  // Immatriculation API Configuration
  static const String immatriculationApiUsername =
      'Moïse134'; // À remplacer par votre username
  static const bool immatriculationApiEnabled =
      true; // Pour activer/désactiver l'API en production

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userTypeKey = 'user_type';

  // User Types
  static const String userTypeParticulier = 'particulier';
  static const String userTypeVendeur = 'vendeur';
  static const String userTypeSeller = 'seller';

  // Schemes
  static const String appScheme = 'pieces-occasion';

  // Part Types
  static const String partTypeMoteur = 'moteur';
  static const String partTypeCarrosserie = 'carrosserie';
}
