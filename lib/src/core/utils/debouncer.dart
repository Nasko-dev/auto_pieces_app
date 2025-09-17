import 'dart:async';

/// Classe utilitaire pour débouncer les appels de fonction
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Exécute la fonction après le délai, annulant les appels précédents
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Annule le timer en cours
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose le debouncer
  void dispose() {
    _timer?.cancel();
  }
}

/// Version throttle qui limite le nombre d'appels
class Throttler {
  final Duration interval;
  Timer? _timer;
  DateTime? _lastRun;

  Throttler({required this.interval});

  /// Exécute la fonction immédiatement si le délai est passé
  void run(void Function() action) {
    final now = DateTime.now();

    if (_lastRun == null || now.difference(_lastRun!).compareTo(interval) >= 0) {
      _lastRun = now;
      action();
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}