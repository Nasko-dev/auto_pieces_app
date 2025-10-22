import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../core/constants/app_constants.dart';

/// Page de Politique de Confidentialité
/// Requise par Apple App Store Review Guidelines 5.1.1
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static Future<void> _openWebPrivacyPolicy() async {
    HapticHelper.medium();
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D1D1F)),
          onPressed: () {
            HapticHelper.light();
            context.pop();
          },
        ),
        title: const Text(
          'Politique de confidentialité',
          style: TextStyle(
            color: Color(0xFF1D1D1F),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton pour ouvrir la version web
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.open_in_new,
                      color: Color(0xFF007AFF),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Version web complète disponible',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _openWebPrivacyPolicy,
                      icon: const Icon(Icons.language, size: 20),
                      label: const Text('Ouvrir sur le web'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildSection(
                title: '1. Introduction',
                content:
                    'Bienvenue sur Pièces d\'Occasion. Nous respectons votre vie privée et nous nous engageons à protéger vos données personnelles. Cette politique de confidentialité vous informe sur la manière dont nous collectons et traitons vos données lorsque vous utilisez notre application.',
              ),
              _buildSection(
                title: '2. Données collectées',
                content: 'Nous collectons les données suivantes :\n\n'
                    '• Informations de compte : nom, prénom, email, téléphone\n'
                    '• Localisation : votre position géographique (uniquement lorsque vous utilisez l\'app) pour vous proposer des pièces près de chez vous\n'
                    '• Photos : images des pièces automobiles que vous publiez\n'
                    '• Informations sur les pièces : marque, modèle, année du véhicule\n'
                    '• Données de messagerie : vos conversations avec les vendeurs/acheteurs',
              ),
              _buildSection(
                title: '3. Utilisation des données',
                content: 'Vos données sont utilisées pour :\n\n'
                    '• Créer et gérer votre compte\n'
                    '• Publier et rechercher des annonces de pièces automobiles\n'
                    '• Vous mettre en relation avec d\'autres utilisateurs\n'
                    '• Améliorer nos services\n'
                    '• Vous envoyer des notifications importantes',
              ),
              _buildSection(
                title: '4. Partage des données',
                content: 'Vos données ne sont JAMAIS vendues à des tiers.\n\n'
                    'Nous partageons vos données uniquement :\n\n'
                    '• Avec les autres utilisateurs dans le cadre des annonces (nom, localisation approximative)\n'
                    '• Avec nos prestataires techniques (Supabase pour l\'hébergement)\n'
                    '• Si requis par la loi',
              ),
              _buildSection(
                title: '5. Localisation',
                content:
                    'Nous utilisons votre localisation UNIQUEMENT lorsque vous utilisez l\'application (permission "When In Use").\n\n'
                    'La localisation sert à :\n'
                    '• Vous proposer des pièces près de chez vous\n'
                    '• Afficher votre ville sur vos annonces\n\n'
                    'Vous pouvez désactiver la localisation à tout moment dans les paramètres de votre appareil.',
              ),
              _buildSection(
                title: '6. Photos et médias',
                content:
                    'Nous accédons à votre galerie photo uniquement pour vous permettre de :\n'
                    '• Sélectionner des photos de pièces pour vos annonces\n'
                    '• Prendre des photos directement depuis l\'app\n\n'
                    'Les photos sont stockées de manière sécurisée et ne sont visibles que dans le contexte de vos annonces.',
              ),
              _buildSection(
                title: '7. Notifications',
                content:
                    'Nous utilisons OneSignal pour envoyer des notifications push.\n\n'
                    'Les notifications vous informent de :\n'
                    '• Nouveaux messages\n'
                    '• Réponses à vos annonces\n'
                    '• Nouvelles pièces correspondant à vos recherches\n\n'
                    'Vous pouvez désactiver les notifications dans les paramètres de votre appareil.',
              ),
              _buildSection(
                title: '8. Sécurité',
                content:
                    'Vos données sont stockées de manière sécurisée chez Supabase (hébergement européen conforme RGPD).\n\n'
                    'Nous utilisons :\n'
                    '• Chiffrement SSL/TLS pour toutes les communications\n'
                    '• Authentification sécurisée\n'
                    '• Accès limité aux données personnelles',
              ),
              _buildSection(
                title: '9. Vos droits',
                content: 'Conformément au RGPD, vous avez le droit de :\n\n'
                    '• Accéder à vos données\n'
                    '• Corriger vos données\n'
                    '• Supprimer votre compte et toutes vos données\n'
                    '• Exporter vos données\n'
                    '• Vous opposer au traitement de vos données\n\n'
                    'Pour exercer ces droits, contactez-nous à : contact@piecesdoccasion.com',
              ),
              _buildSection(
                title: '10. Cookies et tracking',
                content:
                    'Notre application N\'UTILISE PAS de cookies de tracking publicitaire.\n\n'
                    'Nous utilisons uniquement des données techniques nécessaires au fonctionnement de l\'app (préférences utilisateur, session).',
              ),
              _buildSection(
                title: '11. Modifications',
                content:
                    'Nous pouvons modifier cette politique de confidentialité. Vous serez informé de tout changement important par notification dans l\'application.',
              ),
              _buildSection(
                title: '12. Contact',
                content:
                    'Pour toute question concernant cette politique de confidentialité :\n\n'
                    'Email : contact@piecesdoccasion.com\n'
                    'Dernière mise à jour : 22 octobre 2025',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF3C3C43),
            ),
          ),
        ],
      ),
    );
  }
}
