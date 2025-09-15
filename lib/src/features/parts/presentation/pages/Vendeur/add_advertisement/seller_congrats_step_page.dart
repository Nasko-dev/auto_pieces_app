import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'seller_shared_widgets.dart';

class SellerCongratsStepPage extends StatelessWidget {
  final String partName;
  final double price;
  final VoidCallback onFinish;

  const SellerCongratsStepPage({
    super.key,
    required this.partName,
    required this.price,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Icône de succès
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: AppTheme.success,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Félicitations !',
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkBlue,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Votre annonce a été publiée\navec succès !',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.35,
                      color: AppTheme.darkGray,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Détails de l'annonce
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.success.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.build,
                                color: AppTheme.success,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                partName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.euro,
                                color: AppTheme.success,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${price.toStringAsFixed(0)} €',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Messages informatifs
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Prochaines étapes :',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.darkBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        _buildStep('Votre annonce est maintenant visible'),
                        const SizedBox(height: 8),
                        _buildStep('Les acheteurs pourront vous contacter'),
                        const SizedBox(height: 8),
                        _buildStep('Vous recevrez des notifications pour les messages'),
                        const SizedBox(height: 8),
                        _buildStep('Gérez vos annonces dans "Mes annonces"'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Boutons d'action
          Column(
            children: [
              SellerSharedWidgets.buildPrimaryButton(
                label: 'Voir mes annonces',
                onPressed: () {
                  // TODO: Navigation vers mes annonces
                  onFinish();
                },
              ),
              
              const SizedBox(height: 12),
              
              SellerSharedWidgets.buildGhostButton(
                label: 'Retour à l\'accueil',
                onPressed: onFinish,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.darkGray,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}