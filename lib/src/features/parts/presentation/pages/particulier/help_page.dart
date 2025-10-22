import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/haptic_helper.dart';
import '../../../../../core/constants/app_constants.dart';

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppTheme.darkGray),
          onPressed: () {
            HapticHelper.light();
            context.go('/home');
          },
        ),
        title: const Text(
          'Centre d\'aide',
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
            _buildFAQSection(
              'Comment ça marche ?',
              Icons.help_outline,
              [
                _buildFAQItem(
                  'Comment rechercher une pièce ?',
                  'Entrez votre numéro d\'immatriculation sur la page d\'accueil, sélectionnez le type de pièce recherchée, et précisez vos besoins. Les vendeurs recevront votre demande et vous proposeront leurs offres.',
                ),
                _buildFAQItem(
                  'Que faire si aucun vendeur ne répond ?',
                  'Vérifiez que votre immatriculation est correcte et que vos critères ne sont pas trop spécifiques. Vous pouvez aussi essayer de reformuler votre demande ou élargir vos critères de recherche.',
                ),
                _buildFAQItem(
                  'Comment contacter un vendeur ?',
                  'Une fois qu\'un vendeur vous a fait une offre, vous recevrez une notification. Vous pourrez alors échanger directement avec lui via notre système de messagerie intégré.',
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildFAQSection(
              'Gestion des demandes',
              Icons.description_outlined,
              [
                _buildFAQItem(
                  'Comment suivre mes demandes ?',
                  'Rendez-vous dans l\'onglet "Demandes" pour voir toutes vos demandes en cours, les offres reçues et l\'historique de vos recherches.',
                ),
                _buildFAQItem(
                  'Puis-je modifier ma demande ?',
                  'Une fois votre demande envoyée, vous ne pouvez plus la modifier. Cependant, vous pouvez créer une nouvelle demande avec les informations corrigées.',
                ),
                _buildFAQItem(
                  'Comment annuler une demande ?',
                  'Vous pouvez supprimer une demande depuis l\'onglet "Demandes" en appuyant sur les trois points à côté de votre demande.',
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildFAQSection(
              'Messagerie',
              Icons.chat_bubble_outline,
              [
                _buildFAQItem(
                  'Comment négocier le prix ?',
                  'Utilisez la messagerie intégrée pour discuter directement avec le vendeur. Soyez poli et proposez un prix raisonnable basé sur l\'état de la pièce.',
                ),
                _buildFAQItem(
                  'Les messages sont-ils sécurisés ?',
                  'Oui, tous nos échanges sont chiffrés et sécurisés. Nous vous recommandons de ne pas partager d\'informations personnelles sensibles.',
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildFAQSection(
              'Sécurité et paiement',
              Icons.security_outlined,
              [
                _buildFAQItem(
                  'Comment payer en toute sécurité ?',
                  'Nous recommandons les paiements en espèces lors de la remise en main propre, ou les virements bancaires pour les envois. Évitez les modes de paiement non traçables.',
                ),
                _buildFAQItem(
                  'Que faire en cas de litige ?',
                  'Contactez d\'abord le vendeur pour trouver une solution à l\'amiable. Si le problème persiste, vous pouvez nous contacter via le support.',
                ),
                _buildFAQItem(
                  'Comment reconnaître un vendeur fiable ?',
                  'Vérifiez les évaluations et commentaires des autres acheteurs, privilégiez les vendeurs avec un profil complet et des photos détaillées des pièces.',
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Contact Support
            _buildContactCard(),

            const SizedBox(height: 20),

            // Legal Section
            _buildLegalCard(context),

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
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withValues(alpha: 0.8),
          ],
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
                  Icons.support_agent,
                  color: AppTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Nous sommes là pour vous aider !',
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
            'Trouvez rapidement des réponses à vos questions sur l\'utilisation de notre plateforme de pièces détachées d\'occasion.',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 15,
              height: 1.5,
            ),
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
                  child: Icon(
                    icon,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
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
                  'Besoin d\'aide personnalisée ?',
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
            'Notre équipe de support est disponible pour vous accompagner dans vos recherches de pièces détachées.',
            style: TextStyle(
              color: AppTheme.gray,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter la navigation vers le chat support
                    // ou l'ouverture de l'email client
                  },
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Nous contacter'),
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

  Widget _buildLegalCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Informations légales',
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
            'Consultez nos politiques et conditions d\'utilisation',
            style: TextStyle(
              color: AppTheme.gray,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Privacy Policy button
          _buildLegalButton(
            context: context,
            icon: Icons.shield_outlined,
            title: 'Politique de confidentialité',
            onTap: () {
              HapticHelper.selection();
              context.push('/privacy');
            },
          ),

          const SizedBox(height: 12),

          // Terms of Service button
          _buildLegalButton(
            context: context,
            icon: Icons.description_outlined,
            title: 'Conditions générales',
            onTap: () async {
              HapticHelper.selection();
              final uri = Uri.parse(AppConstants.termsOfServiceUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightGray.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.gray.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.darkBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.gray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
