import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

// Test version of Debouncer
class TestDebouncer {
  final Duration delay;
  Timer? _timer;

  TestDebouncer({required this.delay});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }

  // Test helper
  bool get hasActiveTimer => _timer?.isActive ?? false;
}

// Test version of Throttler
class TestThrottler {
  final Duration interval;
  Timer? _timer;
  DateTime? _lastRun;

  TestThrottler({required this.interval});

  void run(void Function() action) {
    final now = DateTime.now();

    if (_lastRun == null ||
        now.difference(_lastRun!).compareTo(interval) >= 0) {
      _lastRun = now;
      action();
    }
  }

  void dispose() {
    _timer?.cancel();
  }

  // Test helpers
  DateTime? get lastRun => _lastRun;
}

void main() {
  group('Debouncer Tests', () {
    late TestDebouncer debouncer;

    setUp(() {
      debouncer = TestDebouncer(delay: const Duration(milliseconds: 100));
    });

    tearDown(() {
      debouncer.dispose();
    });

    group('Constructor', () {
      test('should initialize with correct delay', () {
        final testDebouncer = TestDebouncer(delay: const Duration(seconds: 1));

        expect(testDebouncer.delay, equals(const Duration(seconds: 1)));
        expect(testDebouncer.hasActiveTimer, isFalse);

        testDebouncer.dispose();
      });
    });

    group('run', () {
      test('should execute action after delay', () async {
        bool actionExecuted = false;

        debouncer.run(() {
          actionExecuted = true;
        });

        expect(actionExecuted, isFalse);
        expect(debouncer.hasActiveTimer, isTrue);

        await Future.delayed(const Duration(milliseconds: 150));

        expect(actionExecuted, isTrue);
        expect(debouncer.hasActiveTimer, isFalse);
      });

      test('should cancel previous timer when called multiple times', () async {
        int executionCount = 0;

        debouncer.run(() {
          executionCount++;
        });

        await Future.delayed(const Duration(milliseconds: 50));

        debouncer.run(() {
          executionCount++;
        });

        await Future.delayed(const Duration(milliseconds: 150));

        expect(executionCount, equals(1));
      });

      test('should execute latest action when called multiple times', () async {
        String result = '';

        debouncer.run(() {
          result = 'first';
        });

        await Future.delayed(const Duration(milliseconds: 50));

        debouncer.run(() {
          result = 'second';
        });

        await Future.delayed(const Duration(milliseconds: 150));

        expect(result, equals('second'));
      });

      test('should handle rapid successive calls correctly', () async {
        int executionCount = 0;
        String lastValue = '';

        for (int i = 0; i < 10; i++) {
          debouncer.run(() {
            executionCount++;
            lastValue = 'call_$i';
          });
          await Future.delayed(const Duration(milliseconds: 10));
        }

        await Future.delayed(const Duration(milliseconds: 150));

        expect(executionCount, equals(1));
        expect(lastValue, equals('call_9'));
      });
    });

    group('cancel', () {
      test('should cancel pending action', () async {
        bool actionExecuted = false;

        debouncer.run(() {
          actionExecuted = true;
        });

        expect(debouncer.hasActiveTimer, isTrue);

        debouncer.cancel();

        expect(debouncer.hasActiveTimer, isFalse);

        await Future.delayed(const Duration(milliseconds: 150));

        expect(actionExecuted, isFalse);
      });

      test('should be safe to call when no timer is active', () {
        expect(() => debouncer.cancel(), returnsNormally);
      });

      test('should be safe to call multiple times', () {
        debouncer.run(() {});
        debouncer.cancel();

        expect(() => debouncer.cancel(), returnsNormally);
      });
    });

    group('dispose', () {
      test('should cancel active timer', () async {
        bool actionExecuted = false;

        debouncer.run(() {
          actionExecuted = true;
        });

        expect(debouncer.hasActiveTimer, isTrue);

        debouncer.dispose();

        expect(debouncer.hasActiveTimer, isFalse);

        await Future.delayed(const Duration(milliseconds: 150));

        expect(actionExecuted, isFalse);
      });

      test('should be safe to call when no timer is active', () {
        expect(() => debouncer.dispose(), returnsNormally);
      });

      test('should be safe to call multiple times', () {
        debouncer.run(() {});
        debouncer.dispose();

        expect(() => debouncer.dispose(), returnsNormally);
      });
    });

    group('Edge cases', () {
      test('should handle very short delays', () async {
        final shortDebouncer =
            TestDebouncer(delay: const Duration(milliseconds: 1));
        bool actionExecuted = false;

        shortDebouncer.run(() {
          actionExecuted = true;
        });

        await Future.delayed(const Duration(milliseconds: 5));

        expect(actionExecuted, isTrue);

        shortDebouncer.dispose();
      });

      test('should handle zero delay', () async {
        final zeroDebouncer = TestDebouncer(delay: Duration.zero);
        bool actionExecuted = false;

        zeroDebouncer.run(() {
          actionExecuted = true;
        });

        await Future.delayed(const Duration(milliseconds: 1));

        expect(actionExecuted, isTrue);

        zeroDebouncer.dispose();
      });
    });
  });

  group('Throttler Tests', () {
    late TestThrottler throttler;

    setUp(() {
      throttler = TestThrottler(interval: const Duration(milliseconds: 100));
    });

    tearDown(() {
      throttler.dispose();
    });

    group('Constructor', () {
      test('should initialize with correct interval', () {
        final testThrottler =
            TestThrottler(interval: const Duration(seconds: 1));

        expect(testThrottler.interval, equals(const Duration(seconds: 1)));
        expect(testThrottler.lastRun, isNull);

        testThrottler.dispose();
      });
    });

    group('run', () {
      test('should execute action immediately on first call', () {
        bool actionExecuted = false;

        throttler.run(() {
          actionExecuted = true;
        });

        expect(actionExecuted, isTrue);
        expect(throttler.lastRun, isNotNull);
      });

      test('should ignore subsequent calls within interval', () {
        int executionCount = 0;

        throttler.run(() {
          executionCount++;
        });

        throttler.run(() {
          executionCount++;
        });

        throttler.run(() {
          executionCount++;
        });

        expect(executionCount, equals(1));
      });

      test('should allow execution after interval has passed', () async {
        int executionCount = 0;

        throttler.run(() {
          executionCount++;
        });

        expect(executionCount, equals(1));

        await Future.delayed(const Duration(milliseconds: 150));

        throttler.run(() {
          executionCount++;
        });

        expect(executionCount, equals(2));
      });

      test('should track last run time correctly', () async {
        DateTime? firstRun;
        DateTime? secondRun;

        throttler.run(() {});
        firstRun = throttler.lastRun;

        await Future.delayed(const Duration(milliseconds: 150));

        throttler.run(() {});
        secondRun = throttler.lastRun;

        expect(firstRun, isNotNull);
        expect(secondRun, isNotNull);
        expect(secondRun!.isAfter(firstRun!), isTrue);
      });

      test('should handle rapid successive calls correctly', () {
        int executionCount = 0;

        for (int i = 0; i < 10; i++) {
          throttler.run(() {
            executionCount++;
          });
        }

        expect(executionCount, equals(1));
      });
    });

    group('dispose', () {
      test('should dispose without errors', () {
        throttler.run(() {});

        expect(() => throttler.dispose(), returnsNormally);
      });

      test('should be safe to call multiple times', () {
        throttler.dispose();

        expect(() => throttler.dispose(), returnsNormally);
      });
    });

    group('Edge cases', () {
      test('should handle very short intervals', () async {
        final shortThrottler =
            TestThrottler(interval: const Duration(milliseconds: 1));
        int executionCount = 0;

        shortThrottler.run(() {
          executionCount++;
        });

        await Future.delayed(const Duration(milliseconds: 5));

        shortThrottler.run(() {
          executionCount++;
        });

        expect(executionCount, equals(2));

        shortThrottler.dispose();
      });

      test('should handle zero interval', () {
        final zeroThrottler = TestThrottler(interval: Duration.zero);
        int executionCount = 0;

        zeroThrottler.run(() {
          executionCount++;
        });

        zeroThrottler.run(() {
          executionCount++;
        });

        expect(executionCount, equals(2));

        zeroThrottler.dispose();
      });

      test('should maintain state across multiple throttle cycles', () async {
        int executionCount = 0;

        // First cycle
        throttler.run(() {
          executionCount++;
        });

        expect(executionCount, equals(1));

        // Wait for interval to pass
        await Future.delayed(const Duration(milliseconds: 150));

        // Second cycle
        throttler.run(() {
          executionCount++;
        });

        expect(executionCount, equals(2));

        // Wait for interval to pass again
        await Future.delayed(const Duration(milliseconds: 150));

        // Third cycle
        throttler.run(() {
          executionCount++;
        });

        expect(executionCount, equals(3));
      });
    });
  });
}
