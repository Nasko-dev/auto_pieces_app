import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

// Test version of BatchProcessor to avoid external dependencies
class TestBatchProcessor<T> {
  final Duration _batchDelay;
  final int _maxBatchSize;
  final Future<void> Function(List<T> items) _processor;

  final List<T> _pendingItems = [];
  Timer? _batchTimer;

  TestBatchProcessor({
    required Duration batchDelay,
    required int maxBatchSize,
    required Future<void> Function(List<T> items) processor,
  })  : _batchDelay = batchDelay,
        _maxBatchSize = maxBatchSize,
        _processor = processor;

  void add(T item) {
    _pendingItems.add(item);

    if (_pendingItems.length >= _maxBatchSize) {
      _processBatch();
    } else {
      _resetTimer();
    }
  }

  void addAll(List<T> items) {
    if (items.isEmpty) return;

    _pendingItems.addAll(items);

    if (_pendingItems.length >= _maxBatchSize) {
      _processBatch();
    } else {
      _resetTimer();
    }
  }

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

    final itemsToProcess = List<T>.from(_pendingItems);
    _pendingItems.clear();

    try {
      await _processor(itemsToProcess);
    } catch (e) {
      _pendingItems.insertAll(0, itemsToProcess);
    }
  }

  void dispose() {
    _batchTimer?.cancel();
    _pendingItems.clear();
  }

  // Test helper methods
  int get pendingItemsCount => _pendingItems.length;
  List<T> get pendingItems => List.from(_pendingItems);
  bool get hasActiveTimer => _batchTimer?.isActive ?? false;
}

// Test version of MessageReadBatcher
class TestMessageReadBatcher {
  late final TestBatchProcessor<String> _batcher;
  final Future<void> Function(List<String> messageIds) markAsRead;

  TestMessageReadBatcher({required this.markAsRead}) {
    _batcher = TestBatchProcessor<String>(
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

  // Test helper methods
  int get pendingItemsCount => _batcher.pendingItemsCount;
}

void main() {
  group('BatchProcessor Tests', () {
    late TestBatchProcessor<String> batchProcessor;
    late List<List<String>> processedBatches;

    setUp(() {
      processedBatches = [];
      batchProcessor = TestBatchProcessor<String>(
        batchDelay: const Duration(milliseconds: 100),
        maxBatchSize: 3,
        processor: (items) async {
          processedBatches.add(List.from(items));
        },
      );
    });

    tearDown(() {
      batchProcessor.dispose();
    });

    group('Constructor', () {
      test('should initialize with correct parameters', () {
        final processor = TestBatchProcessor<int>(
          batchDelay: const Duration(seconds: 5),
          maxBatchSize: 10,
          processor: (items) async {},
        );

        expect(processor.pendingItemsCount, equals(0));
        processor.dispose();
      });
    });

    group('add', () {
      test('should add single item to pending list', () {
        batchProcessor.add('item1');

        expect(batchProcessor.pendingItemsCount, equals(1));
        expect(batchProcessor.pendingItems, contains('item1'));
      });

      test('should trigger immediate processing when max size reached',
          () async {
        batchProcessor.add('item1');
        batchProcessor.add('item2');
        batchProcessor.add('item3'); // Should trigger processing

        // Wait a bit for async processing
        await Future.delayed(const Duration(milliseconds: 10));

        expect(processedBatches.length, equals(1));
        expect(processedBatches.first, equals(['item1', 'item2', 'item3']));
        expect(batchProcessor.pendingItemsCount, equals(0));
      });

      test('should start timer when below max size', () {
        batchProcessor.add('item1');

        expect(batchProcessor.hasActiveTimer, isTrue);
        expect(batchProcessor.pendingItemsCount, equals(1));
      });

      test('should reset timer when adding multiple items below max size',
          () async {
        batchProcessor.add('item1');
        await Future.delayed(const Duration(milliseconds: 50));
        batchProcessor.add('item2');

        // Should still have timer active and not have processed yet
        expect(batchProcessor.hasActiveTimer, isTrue);
        expect(batchProcessor.pendingItemsCount, equals(2));
        expect(processedBatches.length, equals(0));
      });
    });

    group('addAll', () {
      test('should add multiple items to pending list', () {
        batchProcessor.addAll(['item1', 'item2']);

        expect(batchProcessor.pendingItemsCount, equals(2));
        expect(batchProcessor.pendingItems, containsAll(['item1', 'item2']));
      });

      test('should trigger immediate processing when max size exceeded',
          () async {
        batchProcessor.addAll(['item1', 'item2', 'item3', 'item4']);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(processedBatches.length, equals(1));
        expect(processedBatches.first,
            equals(['item1', 'item2', 'item3', 'item4']));
        expect(batchProcessor.pendingItemsCount, equals(0));
      });

      test('should handle empty list', () {
        batchProcessor.addAll([]);

        expect(batchProcessor.pendingItemsCount, equals(0));
        expect(batchProcessor.hasActiveTimer, isFalse);
      });
    });

    group('flush', () {
      test('should process pending items immediately', () async {
        batchProcessor.add('item1');
        batchProcessor.add('item2');

        await batchProcessor.flush();

        expect(processedBatches.length, equals(1));
        expect(processedBatches.first, equals(['item1', 'item2']));
        expect(batchProcessor.pendingItemsCount, equals(0));
      });

      test('should do nothing when no pending items', () async {
        await batchProcessor.flush();

        expect(processedBatches.length, equals(0));
      });

      test('should cancel timer when flushing', () async {
        batchProcessor.add('item1');
        expect(batchProcessor.hasActiveTimer, isTrue);

        await batchProcessor.flush();

        expect(batchProcessor.hasActiveTimer, isFalse);
      });
    });

    group('timer-based processing', () {
      test('should process items after batch delay', () async {
        batchProcessor.add('item1');
        batchProcessor.add('item2');

        // Wait for timer to expire
        await Future.delayed(const Duration(milliseconds: 150));

        expect(processedBatches.length, equals(1));
        expect(processedBatches.first, equals(['item1', 'item2']));
        expect(batchProcessor.pendingItemsCount, equals(0));
      });
    });

    group('error handling', () {
      test('should re-queue items when processing fails', () async {
        final errorProcessor = TestBatchProcessor<String>(
          batchDelay: const Duration(milliseconds: 100),
          maxBatchSize: 3,
          processor: (items) async {
            throw Exception('Processing failed');
          },
        );

        errorProcessor.add('item1');
        errorProcessor.add('item2');
        errorProcessor.add('item3'); // Should trigger processing

        await Future.delayed(const Duration(milliseconds: 10));

        // Items should be re-queued after error
        expect(errorProcessor.pendingItemsCount, equals(3));
        expect(errorProcessor.pendingItems,
            containsAll(['item1', 'item2', 'item3']));

        errorProcessor.dispose();
      });
    });

    group('dispose', () {
      test('should cancel timer and clear pending items', () {
        batchProcessor.add('item1');
        batchProcessor.add('item2');

        expect(batchProcessor.pendingItemsCount, equals(2));
        expect(batchProcessor.hasActiveTimer, isTrue);

        batchProcessor.dispose();

        expect(batchProcessor.pendingItemsCount, equals(0));
        expect(batchProcessor.hasActiveTimer, isFalse);
      });

      test('should be safe to call multiple times', () {
        batchProcessor.add('item1');
        batchProcessor.dispose();

        expect(() => batchProcessor.dispose(), returnsNormally);
      });
    });

    group('Different types', () {
      test('should work with integer type', () async {
        final List<List<int>> intBatches = [];
        final intProcessor = TestBatchProcessor<int>(
          batchDelay: const Duration(milliseconds: 100),
          maxBatchSize: 2,
          processor: (items) async {
            intBatches.add(List.from(items));
          },
        );

        intProcessor.add(1);
        intProcessor.add(2); // Should trigger processing

        await Future.delayed(const Duration(milliseconds: 10));

        expect(intBatches.length, equals(1));
        expect(intBatches.first, equals([1, 2]));

        intProcessor.dispose();
      });
    });
  });

  group('MessageReadBatcher Tests', () {
    late TestMessageReadBatcher batcher;
    late List<List<String>> processedBatches;

    setUp(() {
      processedBatches = [];
      batcher = TestMessageReadBatcher(
        markAsRead: (messageIds) async {
          processedBatches.add(List.from(messageIds));
        },
      );
    });

    tearDown(() {
      batcher.dispose();
    });

    group('Integration tests', () {
      test('should mark single message as read', () {
        batcher.markMessageAsRead('msg1');

        expect(batcher.pendingItemsCount, equals(1));
      });

      test('should batch multiple messages', () async {
        batcher.markMessageAsRead('msg1');
        batcher.markMessageAsRead('msg2');
        batcher.markMessageAsRead('msg3');

        await batcher.flush();

        expect(processedBatches.length, equals(1));
        expect(processedBatches.first, equals(['msg1', 'msg2', 'msg3']));
      });

      test('should use correct batch configuration', () async {
        // Add 10 messages to trigger max batch size
        for (int i = 1; i <= 10; i++) {
          batcher.markMessageAsRead('msg$i');
        }

        await Future.delayed(const Duration(milliseconds: 10));

        expect(processedBatches.length, equals(1));
        expect(processedBatches.first.length, equals(10));
      });
    });
  });
}
