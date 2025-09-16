import 'dart:async';
import '../utils/logger.dart';

/// Service pour traiter des opérations en batch
class BatchProcessor<T> {
  final Duration _batchDelay;
  final int _maxBatchSize;
  final Future<void> Function(List<T> items) _processor;

  final List<T> _pendingItems = [];
  Timer? _batchTimer;

  BatchProcessor({
    required Duration batchDelay,
    required int maxBatchSize,
    required Future<void> Function(List<T> items) processor,
  })  : _batchDelay = batchDelay,
        _maxBatchSize = maxBatchSize,
        _processor = processor;

  /// Ajoute un élément au batch
  void add(T item) {
    _pendingItems.add(item);

    // Si on atteint la taille max, traiter immédiatement
    if (_pendingItems.length >= _maxBatchSize) {
      _processBatch();
    } else {
      // Sinon, démarrer/réinitialiser le timer
      _resetTimer();
    }
  }

  /// Ajoute plusieurs éléments au batch
  void addAll(List<T> items) {
    _pendingItems.addAll(items);

    if (_pendingItems.length >= _maxBatchSize) {
      _processBatch();
    } else {
      _resetTimer();
    }
  }

  /// Force le traitement du batch
  Future<void> flush() async {
    if (_pendingItems.isNotEmpty) {
      await _processBatch();
    }
  }

  void _resetTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer(_batchDelay, _processBatch);
  }

  Future<void> _processBatch() async {
    _batchTimer?.cancel();

    if (_pendingItems.isEmpty) return;

    // Copier et vider la liste pour éviter les conflits
    final itemsToProcess = List<T>.from(_pendingItems);
    _pendingItems.clear();

    try {
      Logger.info('📦 BatchProcessor: Traitement de ${itemsToProcess.length} éléments');
      await _processor(itemsToProcess);
    } catch (e) {
      Logger.error('BatchProcessor: Erreur lors du traitement: $e');
      // Optionnel : remettre les items dans la file en cas d'erreur
      _pendingItems.insertAll(0, itemsToProcess);
    }
  }

  /// Dispose le processor
  void dispose() {
    _batchTimer?.cancel();
    _pendingItems.clear();
  }
}

/// Exemple d'utilisation pour marquer des messages comme lus en batch
class MessageReadBatcher {
  late final BatchProcessor<String> _batcher;
  final Future<void> Function(List<String> messageIds) markAsRead;

  MessageReadBatcher({required this.markAsRead}) {
    _batcher = BatchProcessor<String>(
      batchDelay: const Duration(seconds: 2),
      maxBatchSize: 10,
      processor: markAsRead,
    );
  }

  void markMessageAsRead(String messageId) {
    _batcher.add(messageId);
  }

  Future<void> flush() => _batcher.flush();

  void dispose() => _batcher.dispose();
}