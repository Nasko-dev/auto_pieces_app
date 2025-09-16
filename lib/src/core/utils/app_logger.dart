import 'dart:developer' as developer;

class AppLogger {
  static const bool _debugMode = true;

  static void main(String message) {
    _log('🚀', 'Main', message);
  }

  static void auth(String message) {
    _log('🔐', 'Auth', message);
  }

  static void partRequest(String message) {
    _log('📋', 'PartRequest', message);
  }

  static void dataSource(String message) {
    _log('📡', 'DataSource', message);
  }

  static void homePage(String message) {
    _log('🏠', 'HomePage', message);
  }

  static void requestsPage(String message) {
    _log('📥', 'RequestsPage', message);
  }

  static void navigation(String message) {
    _log('🧭', 'Navigation', message);
  }

  static void error(String category, String message) {
    _log('❌', category, message);
  }

  static void success(String category, String message) {
    _log('✅', category, message);
  }

  static void info(String category, String message) {
    _log('ℹ️', category, message);
  }

  static void warning(String category, String message) {
    _log('⚠️', category, message);
  }

  static void _log(String emoji, String category, String message) {
    if (_debugMode) {
      final logMessage = '$emoji [$category] $message';
      developer.log(logMessage, name: category);
    }
  }
}