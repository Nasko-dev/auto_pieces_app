import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';

class SellerHelpPage extends ConsumerWidget {
  const SellerHelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkGray),
          onPressed: () => context.go('/seller/home'),
        ),
        title: const Text(
          'Centre d\'aide vendeur',
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section principale
            _buildWelcomeCard(),

            const SizedBox(height: 24),

            // FAQ Sections
            _buildFAQSection('Gestion des commandes', Icons.inventory_2_outlined, [
              _buildFAQItem(
                'Comment recevoir les demandes clients ?',
                'Vous recevrez automatiquement les demandes correspondant à votre zone géographique et à vos spécialités. Activez les notifications push pour être alerté immédiatement.',
              ),
              _buildFAQItem(
                'Comment répondre à une demande ?',
                'Consultez les détails de la demande dans l\'onglet "Demandes". Vérifiez la disponibilité de la pièce, proposez un prix compétitif et ajoutez des photos de qualité pour augmenter vos chances.',
              ),
              _buildFAQItem(
                'Combien de temps ai-je pour répondre ?',
                'Nous recommandons de répondre dans les 24h pour maintenir un bon taux de réactivité. Les demandes urgentes sont marquées spécialement et nécessitent une réponse plus rapide.',
              ),
            ]),

            const SizedBox(height: 20),

            _buildFAQSection('Optimiser mes ventes', Icons.trending_up_outlined, [
              _buildFAQItem(
                'Comment améliorer ma visibilité ?',
                'Complétez votre profil professionnel, ajoutez des photos de votre établissement, maintenez des évaluations positives et répondez rapidement aux demandes.',
              ),
              _buildFAQItem(
                'Comment fixer mes prix ?',
                'Analysez les prix du marché local, considérez l\'état de la pièce et sa rareté. Un prix compétitif augmente vos chances d\'être choisi par le client.',
              ),
              _buildFAQItem(
                'Comment gérer mes stocks ?',
                'Tenez à jour la disponibilité de vos pièces dans votre profil. Marquez comme indisponibles les pièces vendues pour éviter les demandes inutiles.',
              ),
            ]),

            const SizedBox(height: 20),

            _buildFAQSection('Communication client', Icons.chat_bubble_outline, [
              _buildFAQItem(
                'Bonnes pratiques de communication',
                'Soyez professionnel, réactif et précis. Fournissez tous les détails techniques nécessaires et soyez transparent sur l\'état des pièces.',
              ),
              _buildFAQItem(
                'Comment négocier efficacement ?',
                'Restez ferme sur vos marges tout en étant ouvert au dialogue. Expliquez la valeur ajoutée de vos services (garantie, expertise, livraison).',
              ),
              _buildFAQItem(
                'Que faire face à un client difficile ?',
                'Gardez votre calme, documentez tous les échanges et n\'hésitez pas à nous contacter si la situation devient problématique.',
              ),
            ]),

            const SizedBox(height: 20),

            _buildFAQSection(
              'Facturation et paiements',
              Icons.receipt_long_outlined,
              [
                _buildFAQItem(
                  'Quels modes de paiement accepter ?',
                  'Privilégiez les espèces pour les remises directes, les chèques d\'entreprise ou les virements bancaires. Évitez les modes de paiement non sécurisés.',
                ),
                _buildFAQItem(
                  'Comment établir mes factures ?',
                  'Utilisez votre système de facturation habituel. Incluez toutes les mentions légales obligatoires et conservez une copie pour votre comptabilité.',
                ),
                _buildFAQItem(
                  'Que faire en cas de litige ?',
                  'Tentez d\'abord un règlement à l\'amiable avec le client. Documentez tous les échanges et contactez notre support pour médiation si nécessaire.',
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildFAQSection('Mon profil professionnel', Icons.business_outlined, [
              _buildFAQItem(
                'Comment optimiser mon profil ?',
                'Ajoutez une description détaillée de votre activité, vos spécialités, vos certifications et des photos de votre établissement. Un profil complet inspire confiance.',
              ),
              _buildFAQItem(
                'Importance des évaluations clients',
                'Les évaluations positives augmentent votre crédibilité et votre classement dans les résultats. Encouragez vos clients satisfaits à laisser un avis.',
              ),
              _buildFAQItem(
                'Comment gérer mes disponibilités ?',
                'Mettez à jour régulièrement vos horaires d\'ouverture et vos périodes de congés dans votre profil pour éviter les malentendus.',
              ),
            ]),

            const SizedBox(height: 30),

            // Contact Support
            _buildContactCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: AppTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Maximisez vos ventes !',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Découvrez toutes les bonnes pratiques pour optimiser votre présence sur notre plateforme et développer votre activité de vente de pièces détachées.',
            style: TextStyle(color: AppTheme.white, fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(String title, IconData icon, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.darkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: AppTheme.darkGray,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: AppTheme.primaryBlue,
        collapsedIconColor: AppTheme.gray,
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(
            answer,
            style: const TextStyle(
              color: AppTheme.gray,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.headset_mic_outlined,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Support commercial dédié',
                  style: TextStyle(
                    color: AppTheme.darkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Notre équipe commerciale est à votre disposition pour vous accompagner dans le développement de votre activité sur la plateforme.',
            style: TextStyle(color: AppTheme.gray, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter la navigation vers le support commercial
                    // ou l'ouverture du système de tickets
                  },
                  icon: const Icon(Icons.support_agent, size: 18),
                  label: const Text('Contacter le support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
