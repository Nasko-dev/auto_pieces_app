/// Configuration pour activer/désactiver les logs debug
class DebugConfig {
  /// Active/désactive tous les logs debug
  static const bool enableDebugLogs = false;

  /// Active les logs pour des modules spécifiques
  static const bool enableConversationLogs = false;
  static const bool enableRealtimeLogs = false;
  static const bool enableAuthLogs = false;
  static const bool enableDataSourceLogs = false;

  /// Helper pour les logs conditionnels
  static void log(String message, {bool force = false, bool? module}) {
    if (force || enableDebugLogs || (module ?? false)) {
      // ignore: avoid_print
    }
  }
}