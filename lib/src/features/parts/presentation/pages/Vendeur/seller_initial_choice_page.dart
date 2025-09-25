import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/presentation/widgets/seller_header.dart';

class SellerInitialChoicePage extends ConsumerWidget {
  const SellerInitialChoicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Column(
        children: [
          const SellerHeader(title: 'Espace Professionnel'),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Que souhaitez-vous faire ?',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'En tant que professionnel, vous pouvez :\n• Vendre vos pièces avec une annonce\n• Rechercher des pièces spécifiques',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 40),

              // Option 1: Poster une annonce
              _buildChoiceCard(
                context: context,
                icon: Icons.sell_outlined,
                title: 'Poster une annonce',
                subtitle: 'Vendre une pièce • Gestion professionnelle',
                color: AppTheme.primaryBlue,
                badge: 'PRO',
                onTap: () {
                  // Aller vers le flow d'annonce vendeur existant
                  context.go('/seller/create-ad');
                },
              ),

              const SizedBox(height: 16),

              // Option 2: Faire une demande
              _buildChoiceCard(
                context: context,
                icon: Icons.search,
                title: 'Rechercher une pièce',
                subtitle: 'Trouver une pièce • Demande prioritaire',
                color: AppTheme.success,
                badge: 'PRO',
                onTap: () {
                  // Aller vers le flow de demande vendeur
                  context.go('/seller/create-request');
                },
              ),

              const Spacer(),
            ],
          ),
        ),
    );
  }

  Widget _buildChoiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.gray.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gray.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.gray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.gray.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}