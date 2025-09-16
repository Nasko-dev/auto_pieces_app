import '../constants/debug_config.dart';

/// Classe utilitaire pour la gestion des logs
class Logger {
  static void conversations(String message) {
    DebugConfig.log(message, module: DebugConfig.enableConversationLogs);
  }

  static void realtime(String message) {
    DebugConfig.log(message, module: DebugConfig.enableRealtimeLogs);
  }

  static void auth(String message) {
    DebugConfig.log(message, module: DebugConfig.enableAuthLogs);
  }

  static void dataSource(String message) {
    DebugConfig.log(message, module: DebugConfig.enableDataSourceLogs);
  }

  static void error(String message) {
    // Les erreurs sont toujours loggées
    DebugConfig.log('❌ ERROR: $message', force: true);
  }

  static void warning(String message) {
    DebugConfig.log('⚠️ WARNING: $message', module: DebugConfig.enableDebugLogs);
  }

  static void info(String message) {
    DebugConfig.log(message, module: DebugConfig.enableDebugLogs);
  }
}