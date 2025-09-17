import 'package:flutter/material.dart';
import '../../../../core/services/tecalliance_test_service.dart';

class TestApiPage extends StatefulWidget {
  const TestApiPage({super.key});

  @override
  State<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  bool _isTesting = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    // Rediriger les prints vers les logs
    _startLogging();
  }

  void _startLogging() {
    // Note: Cannot reassign print function in production
    // This is a placeholder for logging functionality
  }

  Future<void> _runTests() async {
    setState(() {
      _isTesting = true;
      _logs.clear();
    });

    try {
      await TecAllianceTestService.testAllEndpoints();
    } catch (e) {
      _logs.add('❌ Erreur générale: $e');
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API TecAlliance'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration API',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Provider ID: ${TecAllianceTestService.providerId}'),
                    Text('API Key: ${TecAllianceTestService.apiKey.substring(0, 20)}...'),
                    Text('Base URL: ${TecAllianceTestService.baseUrl}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isTesting ? null : _runTests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isTesting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Test en cours...'),
                        ],
                      )
                    : const Text(
                        'Démarrer les tests',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'Logs de test:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(12),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun log pour le moment.\nCliquez sur "Démarrer les tests" pour commencer.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          Color textColor = Colors.black87;
                          
                          if (log.contains('✅')) {
                            textColor = Colors.green[700]!;
                          } else if (log.contains('❌')) {
                            textColor = Colors.red[700]!;
                          } else if (log.contains('🧪')) {
                            textColor = Colors.blue[700]!;
                          } else if (log.contains('Status: 200')) {
                            textColor = Colors.green[600]!;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}