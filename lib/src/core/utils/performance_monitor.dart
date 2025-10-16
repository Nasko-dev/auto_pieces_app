import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Système de monitoring des performances en temps réel
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final _metrics = <String, List<PerformanceMetric>>{};
  final _thresholds = <String, double>{};

  // Configuration par défaut
  static const int maxMetricsPerType = 100;
  static const Duration cleanupInterval = Duration(minutes: 5);

  Timer? _cleanupTimer;

  /// Démarre le monitoring
  void start() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _cleanup());
  }

  /// Arrête le monitoring
  void stop() {
    _cleanupTimer?.cancel();
  }

  /// Enregistre une métrique de performance
  void recordMetric(String type, double value,
      {Map<String, dynamic>? metadata}) {
    final metric = PerformanceMetric(
      type: type,
      value: value,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _metrics.putIfAbsent(type, () => <PerformanceMetric>[]);
    _metrics[type]!.add(metric);

    // Limiter le nombre de métriques par type
    if (_metrics[type]!.length > maxMetricsPerType) {
      _metrics[type]!.removeAt(0);
    }

    // Vérifier les seuils d'alerte
    _checkThreshold(type, value);

    // Log en debug
    if (kDebugMode) {}
  }

  /// Mesure automatiquement le temps d'exécution
  Future<T> measureAsync<T>(String type, Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      return result;
    } finally {
      stopwatch.stop();
      recordMetric(type, stopwatch.elapsedMilliseconds.toDouble());
    }
  }

  /// Mesure synchrone
  T measureSync<T>(String type, T Function() operation) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      return result;
    } finally {
      stopwatch.stop();
      recordMetric(type, stopwatch.elapsedMilliseconds.toDouble());
    }
  }

  /// Définit un seuil d'alerte pour un type de métrique
  void setThreshold(String type, double threshold) {
    _thresholds[type] = threshold;
  }

  /// Obtient les statistiques pour un type
  PerformanceStats? getStats(String type) {
    final metrics = _metrics[type];
    if (metrics == null || metrics.isEmpty) return null;

    final values = metrics.map((m) => m.value).toList();
    values.sort();

    return PerformanceStats(
      type: type,
      count: values.length,
      average: values.reduce((a, b) => a + b) / values.length,
      min: values.first,
      max: values.last,
      p50: _percentile(values, 0.5),
      p95: _percentile(values, 0.95),
      p99: _percentile(values, 0.99),
    );
  }

  /// Obtient toutes les statistiques
  Map<String, PerformanceStats> getAllStats() {
    final stats = <String, PerformanceStats>{};

    for (final type in _metrics.keys) {
      final stat = getStats(type);
      if (stat != null) {
        stats[type] = stat;
      }
    }

    return stats;
  }

  /// Identifie les goulots d'étranglement
  List<PerformanceIssue> identifyIssues() {
    final issues = <PerformanceIssue>[];

    for (final entry in _metrics.entries) {
      final type = entry.key;
      final stats = getStats(type);

      if (stats == null) continue;

      // Temps de réponse élevé
      if (stats.p95 > 2000) {
        // Plus de 2 secondes
        issues.add(PerformanceIssue(
          type: type,
          severity: IssueSeverity.high,
          description:
              'Temps de réponse élevé (P95: ${stats.p95.toStringAsFixed(0)}ms)',
          recommendation: 'Optimiser les requêtes ou ajouter du cache',
        ));
      } else if (stats.p95 > 1000) {
        // Plus de 1 seconde
        issues.add(PerformanceIssue(
          type: type,
          severity: IssueSeverity.medium,
          description:
              'Temps de réponse lent (P95: ${stats.p95.toStringAsFixed(0)}ms)',
          recommendation: 'Analyser et optimiser si possible',
        ));
      }

      // Variabilité élevée
      final variance = stats.max - stats.min;
      if (variance > stats.average * 3) {
        issues.add(PerformanceIssue(
          type: type,
          severity: IssueSeverity.medium,
          description:
              'Performance inconsistante (variance: ${variance.toStringAsFixed(0)}ms)',
          recommendation: 'Vérifier les conditions réseau et serveur',
        ));
      }
    }

    return issues;
  }

  double _percentile(List<double> values, double percentile) {
    final index = (values.length * percentile).round() - 1;
    return values[index.clamp(0, values.length - 1)];
  }

  void _checkThreshold(String type, double value) {
    final threshold = _thresholds[type];
    if (threshold != null && value > threshold) {
      if (kDebugMode) {
        debugPrint(
            '⚠️ Performance Alert: $type (${value.toStringAsFixed(2)}ms) '
            'exceeded threshold (${threshold.toStringAsFixed(2)}ms)');
      }
    }
  }

  void _cleanup() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));

    for (final metrics in _metrics.values) {
      metrics.removeWhere((m) => m.timestamp.isBefore(cutoff));
    }
  }

  /// Export des métriques pour analyse
  Map<String, dynamic> exportMetrics() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'stats': getAllStats().map((k, v) => MapEntry(k, v.toJson())),
      'issues': identifyIssues().map((i) => i.toJson()).toList(),
    };
  }
}

class PerformanceMetric {
  final String type;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.type,
    required this.value,
    required this.timestamp,
    this.metadata,
  });
}

class PerformanceStats {
  final String type;
  final int count;
  final double average;
  final double min;
  final double max;
  final double p50;
  final double p95;
  final double p99;

  PerformanceStats({
    required this.type,
    required this.count,
    required this.average,
    required this.min,
    required this.max,
    required this.p50,
    required this.p95,
    required this.p99,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'count': count,
        'average': average,
        'min': min,
        'max': max,
        'p50': p50,
        'p95': p95,
        'p99': p99,
      };

  @override
  String toString() {
    return '$type: avg=${average.toStringAsFixed(1)}ms, '
        'p95=${p95.toStringAsFixed(1)}ms, count=$count';
  }
}

class PerformanceIssue {
  final String type;
  final IssueSeverity severity;
  final String description;
  final String recommendation;

  PerformanceIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'severity': severity.name,
        'description': description,
        'recommendation': recommendation,
      };
}

enum IssueSeverity { low, medium, high, critical }

/// Widget pour afficher les métriques en debug
class PerformanceDebugOverlay extends StatefulWidget {
  final Widget child;

  const PerformanceDebugOverlay({super.key, required this.child});

  @override
  State<PerformanceDebugOverlay> createState() =>
      _PerformanceDebugOverlayState();
}

class _PerformanceDebugOverlayState extends State<PerformanceDebugOverlay> {
  bool _showOverlay = false;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_showOverlay && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (kDebugMode)
          Positioned(
            top: 50,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () => setState(() => _showOverlay = !_showOverlay),
                  child: Icon(_showOverlay ? Icons.close : Icons.speed),
                ),
                if (_showOverlay) _buildStatsPanel(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatsPanel() {
    final monitor = PerformanceMonitor();
    final stats = monitor.getAllStats();
    final issues = monitor.identifyIssues();

    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Performance Monitor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (stats.isEmpty)
            const Text('Aucune donnée', style: TextStyle(color: Colors.grey))
          else
            ...stats.values.take(5).map((stat) => Text(
                  stat.toString(),
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                )),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Issues:', style: TextStyle(color: Colors.red)),
            ...issues.take(3).map((issue) => Text(
                  '${issue.type}: ${issue.description}',
                  style: const TextStyle(color: Colors.orange, fontSize: 11),
                )),
          ],
        ],
      ),
    );
  }
}
