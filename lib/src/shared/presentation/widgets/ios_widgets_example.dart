// FICHIER D'EXEMPLE - Ne pas utiliser en production
//
// Ce fichier montre comment utiliser les composants iOS réutilisables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ios_widgets.dart';

/// Exemple complet d'une page utilisant tous les composants iOS
class IOSWidgetsExamplePage extends StatefulWidget {
  const IOSWidgetsExamplePage({super.key});

  @override
  State<IOSWidgetsExamplePage> createState() => _IOSWidgetsExamplePageState();
}

class _IOSWidgetsExamplePageState extends State<IOSWidgetsExamplePage> {
  int _currentIndex = 0;
  int _unreadMessages = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IOSAppBar avec actions
      appBar: IOSAppBar(
        title: 'Composants iOS',
        trailing: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticHelper.light();
              // Action de recherche
            },
            child: const Icon(
              CupertinoIcons.search,
              size: 22,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticHelper.light();
              // Action de paramètres
            },
            child: const Icon(
              CupertinoIcons.settings,
              size: 22,
            ),
          ),
        ],
      ),

      body: _buildContent(),

      // IOSBottomNavigation
      bottomNavigationBar: IOSBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        unreadMessagesCount: _unreadMessages,
        isSellerMode: false,
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section Haptic Feedback
        _buildSection(
          title: 'Haptic Feedback',
          children: [
            _buildHapticButton(
              'Light Impact',
              'Sélections légères',
              () => HapticHelper.light(),
            ),
            _buildHapticButton(
              'Medium Impact',
              'Actions importantes',
              () => HapticHelper.medium(),
            ),
            _buildHapticButton(
              'Heavy Impact',
              'Actions critiques',
              () => HapticHelper.heavy(),
            ),
            _buildHapticButton(
              'Selection',
              'Changements de sélection',
              () => HapticHelper.selection(),
            ),
            _buildHapticButton(
              'Vibrate',
              'Erreurs',
              () => HapticHelper.vibrate(),
            ),
            _buildHapticButton(
              'Success',
              'Validation réussie',
              () => HapticHelper.success(),
            ),
            _buildHapticButton(
              'Navigation',
              'Changement de page',
              () => HapticHelper.navigation(),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Section Bottom Navigation
        _buildSection(
          title: 'Bottom Navigation',
          children: [
            _buildInfoCard(
              'Messages non lus',
              _unreadMessages.toString(),
              CupertinoIcons.chat_bubble_2_fill,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Ajouter +1',
                    () {
                      HapticHelper.light();
                      setState(() {
                        _unreadMessages++;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Réinitialiser',
                    () {
                      HapticHelper.medium();
                      setState(() {
                        _unreadMessages = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Section AppBar Variants
        _buildSection(
          title: 'AppBar Variants',
          children: [
            _buildInfoCard(
              'IOSAppBar Standard',
              'Hauteur: 44px, Bouton retour iOS, Border subtile',
              CupertinoIcons.device_phone_portrait,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'IOSLargeAppBar',
              'Hauteur: 96px, Large title iOS, Collapse au scroll',
              CupertinoIcons.textformat_size,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildHapticButton(
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.hand_point_left,
                color: CupertinoColors.systemBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: CupertinoColors.systemBlue,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: CupertinoColors.systemBlue,
      borderRadius: BorderRadius.circular(12),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
