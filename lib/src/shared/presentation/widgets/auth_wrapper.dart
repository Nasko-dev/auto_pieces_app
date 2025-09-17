import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/particulier_auth_providers.dart';
import '../../../core/providers/session_providers.dart' as session;

class AuthWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Vérifier si l'utilisateur est déjà connecté via Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCurrentAuth();
    });
  }
  
  Future<void> _checkCurrentAuth() async {
    // Si un utilisateur est déjà connecté via Supabase, mettre à jour l'état
    final supabase = ref.read(session.supabaseClientProvider);
    final currentUser = supabase.auth.currentUser;
    
    if (currentUser != null && mounted) {
      // L'utilisateur est déjà connecté, déclencher la connexion anonyme pour mettre à jour l'état
      ref.read(particulierAuthControllerProvider.notifier).signInAnonymously();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(particulierAuthControllerProvider);

    return authState.when(
      initial: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      anonymousAuthenticated: (_) => widget.child,
      error: (message) => _buildErrorView(context, message),
    );
  }


  Widget _buildErrorView(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 32),
              
              Text(
                'Erreur de connexion',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF86868B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(particulierAuthControllerProvider.notifier).resetState();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Réessayer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}