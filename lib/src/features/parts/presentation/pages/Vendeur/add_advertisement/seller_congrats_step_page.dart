import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'seller_shared_widgets.dart';

class SellerCongratsStepPage extends StatelessWidget {
  final String? partName;
  final double? price;
  final bool isRequest;
  final VoidCallback onFinish;

  const SellerCongratsStepPage({
    super.key,
    this.partName,
    this.price,
    this.isRequest = false,
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
                      color: AppTheme.success.withValues(alpha: 0.1),
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

                  Text(
                    isRequest
                      ? 'Votre demande a été enregistrée\navec succès !'
                      : 'Votre annonce a été publiée\navec succès !',
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.35,
                      color: AppTheme.darkGray,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Détails de l'annonce ou de la demande
                  if (partName != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.success.withValues(alpha: 0.1),
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
                                  color: AppTheme.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isRequest ? Icons.search : Icons.build,
                                  color: AppTheme.success,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  partName!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.darkBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (price != null && !isRequest) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withValues(alpha: 0.1),
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
                                  '${price!.toStringAsFixed(0)} €',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Messages informatifs
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
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
                            Text(
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

                        if (isRequest) ...[
                          _buildStep('Votre demande est maintenant visible'),
                          const SizedBox(height: 8),
                          _buildStep('Les vendeurs pourront vous contacter'),
                          const SizedBox(height: 8),
                          _buildStep('Vous recevrez des notifications pour les réponses'),
                          const SizedBox(height: 8),
                          _buildStep('Gérez vos demandes dans "Mes demandes"'),
                        ] else ...[
                          _buildStep('Votre annonce est maintenant visible'),
                          const SizedBox(height: 8),
                          _buildStep('Les acheteurs pourront vous contacter'),
                          const SizedBox(height: 8),
                          _buildStep('Vous recevrez des notifications pour les messages'),
                          const SizedBox(height: 8),
                          _buildStep('Gérez vos annonces dans "Mes annonces"'),
                        ],
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
                label: isRequest ? 'Voir mes demandes' : 'Voir mes annonces',
                onPressed: () {
                  // TODO: Navigation vers mes annonces ou demandes
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