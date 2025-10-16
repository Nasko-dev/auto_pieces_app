import 'package:shared_preferences/shared_preferences.dart';

class RateLimiterService {
  static const String _keyPrefix = 'plate_search_attempts_';
  static const String _lastResetKey = 'plate_search_last_reset';
  static const int _maxAttempts = 3;
  static const int _windowMinutes = 5;

  final SharedPreferences _prefs;

  RateLimiterService(this._prefs);

  /// Vérifie si l'utilisateur peut faire une recherche
  Future<bool> canMakeSearch() async {
    await _resetIfNeeded();
    final currentAttempts = await _getCurrentAttempts();
    return currentAttempts < _maxAttempts;
  }

  /// Enregistre une tentative de recherche
  Future<void> recordAttempt() async {
    await _resetIfNeeded();
    final currentAttempts = await _getCurrentAttempts();
    final newAttempts = currentAttempts + 1;
    await _prefs.setInt(_getAttemptsKey(), newAttempts);
  }

  /// Obtient le nombre de tentatives restantes
  Future<int> getRemainingAttempts() async {
    await _resetIfNeeded();
    final currentAttempts = await _getCurrentAttempts();
    return (_maxAttempts - currentAttempts).clamp(0, _maxAttempts);
  }

  /// Obtient le temps restant avant reset (en minutes)
  Future<int> getTimeUntilReset() async {
    final lastReset = _prefs.getInt(_lastResetKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - lastReset;
    final elapsedMinutes = elapsed / (1000 * 60);

    if (elapsedMinutes >= _windowMinutes) {
      return 0;
    }

    return (_windowMinutes - elapsedMinutes).ceil();
  }

  /// Vérifie et remet à zéro si la fenêtre de temps est écoulée
  Future<void> _resetIfNeeded() async {
    final lastReset = _prefs.getInt(_lastResetKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - lastReset;

    // Si plus de 5 minutes se sont écoulées, reset
    if (elapsed >= _windowMinutes * 60 * 1000) {
      await _prefs.setInt(_lastResetKey, now);
      await _prefs.setInt(_getAttemptsKey(), 0);
    }
  }

  /// Obtient le nombre actuel de tentatives
  Future<int> _getCurrentAttempts() async {
    return _prefs.getInt(_getAttemptsKey()) ?? 0;
  }

  /// Génère la clé pour stocker les tentatives
  String _getAttemptsKey() {
    final today = DateTime.now();
    final dateKey =
        '${today.year}_${today.month}_${today.day}_${today.hour ~/ (_windowMinutes / 60).ceil()}';
    return '$_keyPrefix$dateKey';
  }

  /// Reset manuel pour les tests
  Future<void> resetForTesting() async {
    await _prefs.setInt(_lastResetKey, DateTime.now().millisecondsSinceEpoch);
    await _prefs.setInt(_getAttemptsKey(), 0);
  }
}
