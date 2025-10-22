import '../config/environment_config.dart';

class AppConstants {
  static const String appName = 'Pièces d\'Occasion';

  // Configuration dynamique basée sur l'environnement
  static String get appVersion => EnvironmentConfig.appVersion;

  // Supabase Configuration (dynamique selon l'environnement)
  static String get supabaseUrl => EnvironmentConfig.supabaseUrl;
  static String get supabaseAnonKey => EnvironmentConfig.supabaseAnonKey;

  // API Endpoints
  static String get baseUrl => EnvironmentConfig.baseUrl;

  // Immatriculation API Configuration - LEGACY (RegCheck)
  static const String immatriculationApiUsername =
      'Moïse134'; // À remplacer par votre username
  static const bool immatriculationApiEnabled =
      false; // Désactivé - remplacé par TecAlliance

  // TecAlliance API Configuration (dynamique selon l'environnement)
  static String get tecAllianceProviderId =>
      EnvironmentConfig.tecallianceClientId;
  static String get tecAllianceApiKey => EnvironmentConfig.tecallianceApiKey;
  static String get tecAllianceBaseUrl => EnvironmentConfig.tecallianceBaseUrl;
  static const bool tecAllianceApiEnabled = true;

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

  // Legal URLs
  static const String privacyPolicyUrl = 'https://www.pieceautoenligne.fr/privacy';
  static const String termsOfServiceUrl = 'https://www.pieceautoenligne.fr/terms';
  static const String supportEmail = 'contact@pieceautoenligne.fr';
}
