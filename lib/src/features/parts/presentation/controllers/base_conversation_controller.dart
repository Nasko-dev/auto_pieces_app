import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';

/// Classe de base abstraite pour les controllers de conversations
/// Contient la logique commune pour le polling et la gestion du cycle de vie
abstract class BaseConversationController<T> extends StateNotifier<T> {
  Timer? _pollingTimer;
  bool _isPollingActive = false;

  BaseConversationController(super.state);

  /// Démarre le polling intelligent
  void startIntelligentPolling({
    required Duration interval,
    required Future<void> Function() onPoll,
    String? logPrefix,
  }) {
    if (_isPollingActive) {
      Logger.warning('${logPrefix ?? "Controller"}: Polling déjà actif');
      return;
    }

    _isPollingActive = true;
    Logger.info(
        '⏰ ${logPrefix ?? "Controller"}: Démarrage polling ($interval)');

    _pollingTimer = Timer.periodic(interval, (timer) async {
      if (mounted) {
        try {
          await onPoll();
        } catch (e) {
          Logger.error('${logPrefix ?? "Controller"}: Erreur polling: $e');
        }
      }
    });
  }

  /// Arrête le polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPollingActive = false;
    Logger.info('⏹️ Polling arrêté');
  }

  /// Vérifie si le polling est actif
  bool get isPollingActive => _isPollingActive;

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
