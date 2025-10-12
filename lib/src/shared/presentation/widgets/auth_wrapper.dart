import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/particulier_auth_providers.dart';
import '../../../core/providers/session_providers.dart' as session;
import '../../../core/theme/app_theme.dart';

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
        body: Center(child: CupertinoActivityIndicator(color: AppTheme.primaryBlue)),
      ),
      loading: () => const Scaffold(
        body: Center(child: CupertinoActivityIndicator(color: AppTheme.primaryBlue)),
      ),
      anonymousAuthenticated: (_) => widget.child,
      error: (message) => _buildErrorView(context, message),
    );
  }


  Widget _buildErrorView(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppTheme.white,
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
                color: AppTheme.error,
              ),
              const SizedBox(height: 32),

              const Text(
                'Erreur de connexion',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.gray,
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
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
