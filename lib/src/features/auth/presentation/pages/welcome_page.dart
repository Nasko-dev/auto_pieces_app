import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/particulier_auth_providers.dart';
import '../controllers/particulier_auth_controller.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkGray),
          onPressed: () {
            if (context.mounted) {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Logo et titre
              const Icon(
                Icons.car_repair,
                size: 100,
                color: AppTheme.primaryBlue,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Pièces d\'Occasion',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Trouvez les pièces automobiles dont vous avez besoin',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.gray,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Boutons de choix
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Vous êtes :',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Bouton Particulier
                    _buildUserTypeButton(
                      context: context,
                      ref: ref,
                      title: 'Particulier',
                      subtitle: 'Je recherche des pièces',
                      icon: Icons.person,
                      onTap: () => _loginAsParticulier(ref, context),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Bouton Vendeur
                    _buildUserTypeButton(
                      context: context,
                      ref: ref,
                      title: 'Vendeur',
                      subtitle: 'Je vends des pièces',
                      icon: Icons.store,
                      onTap: () => _goToSellerLogin(context),
                      isOutlined: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeButton({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : AppTheme.primaryBlue,
            border: isOutlined 
                ? Border.all(color: AppTheme.primaryBlue, width: 2)
                : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOutlined 
                      ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                      : AppTheme.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isOutlined ? AppTheme.primaryBlue : AppTheme.white,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isOutlined ? AppTheme.primaryBlue : AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isOutlined 
                            ? AppTheme.gray 
                            : AppTheme.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                color: isOutlined ? AppTheme.primaryBlue : AppTheme.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loginAsParticulier(WidgetRef ref, BuildContext context) async {
    await ref.read(particulierAuthControllerProvider.notifier).signInAnonymously();
    
    // Redirection après connexion réussie
    if (context.mounted) {
      final state = ref.read(particulierAuthControllerProvider);
      if (state.isAuthenticated) {
        context.go('/home');
      }
    }
  }

  void _goToSellerLogin(BuildContext context) {
    context.push('/seller/login');
  }
}