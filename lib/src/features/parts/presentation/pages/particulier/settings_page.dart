import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/providers/user_settings_providers.dart';
import '../../../../../core/utils/haptic_helper.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../domain/entities/user_settings.dart';
import '../../../../../core/services/notification_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCountry = 'France';
  bool _isLoadingLocation = false;
  bool _isLoadingSettings = true;
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;

  final List<String> _countries = [
    'France',
    'Belgique',
    'Suisse',
    'Luxembourg',
    'Monaco',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserSettings() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      setState(() => _isLoadingSettings = false);
      return;
    }

    final getUserSettings = ref.read(getUserSettingsProvider);
    final result = await getUserSettings(currentUser.id);

    result.fold(
      (failure) {
        setState(() => _isLoadingSettings = false);
      },
      (settings) {
        if (settings != null && mounted) {
          setState(() {
            _addressController.text = settings.address ?? '';
            _cityController.text = settings.city ?? '';
            _postalCodeController.text = settings.postalCode ?? '';
            _phoneController.text = settings.phone ?? '';
            // Vérifier que le pays existe dans la liste, sinon utiliser France par défaut
            _selectedCountry = _countries.contains(settings.country)
                ? settings.country
                : 'France';
            _notificationsEnabled = settings.notificationsEnabled;
            _emailNotificationsEnabled = settings.emailNotificationsEnabled;
            _isLoadingSettings = false;
          });
        } else {
          setState(() => _isLoadingSettings = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Paramètres',
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingSettings
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Section Localisation
                  _buildLocationSection(),

                  const SizedBox(height: 24),

                  // Section Contact
                  _buildContactSection(),

                  const SizedBox(height: 24),

                  // Section Légal
                  _buildLegalSection(),

                  const SizedBox(height: 24),

                  // Bouton Sauvegarder
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationSection() {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Localisation',
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

          Text(
            'Ces informations aident les vendeurs à calculer les frais de livraison et à proposer des points de retrait proches.',
            style: TextStyle(
              color: AppTheme.gray,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Pays
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pays',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              // DropdownButton avec Container - CORRECTION DEFINITIVE pour GitHub Actions
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.gray),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButton<String>(
                  value: _countries.contains(_selectedCountry)
                      ? _selectedCountry
                      : 'France',
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: _countries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCountry = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Adresse avec bouton auto-remplissage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Adresse',
                    style: TextStyle(
                      color: AppTheme.darkGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(AppTheme.primaryBlue),
                            ),
                          )
                        : const Icon(Icons.my_location, size: 16),
                    label: Text(
                        _isLoadingLocation ? 'Localisation...' : 'Ma position'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Ex: 123 Rue de la Paix',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ville et Code postal
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ville',
                      style: TextStyle(
                        color: AppTheme.darkGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Paris',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Code postal',
                      style: TextStyle(
                        color: AppTheme.darkGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '75000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.phone_outlined,
                  color: AppTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Contact',
                style: TextStyle(
                  color: AppTheme.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Numéro de téléphone pour faciliter les échanges avec les vendeurs (optionnel).',
            style: TextStyle(
              color: AppTheme.gray,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Téléphone
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Numéro de téléphone',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Ex: 06 12 34 56 78',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Légal et Confidentialité',
                style: TextStyle(
                  color: AppTheme.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Privacy Policy
          _buildLegalTile(
            icon: Icons.shield_outlined,
            title: 'Politique de confidentialité',
            subtitle: 'Comment nous utilisons vos données',
            onTap: () {
              HapticHelper.selection();
              context.push('/privacy');
            },
          ),

          const SizedBox(height: 12),

          // Terms of Service (Web)
          _buildLegalTile(
            icon: Icons.description_outlined,
            title: 'Conditions générales',
            subtitle: 'Conditions d\'utilisation du service',
            onTap: () async {
              HapticHelper.selection();
              final uri = Uri.parse(AppConstants.termsOfServiceUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),

          const SizedBox(height: 12),

          // Contact Support
          _buildLegalTile(
            icon: Icons.email_outlined,
            title: 'Nous contacter',
            subtitle: AppConstants.supportEmail,
            onTap: () async {
              HapticHelper.selection();
              final uri = Uri.parse('mailto:${AppConstants.supportEmail}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.darkBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.gray,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: AppTheme.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Sauvegarder les paramètres',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final result = await LocationService.getCurrentLocation();

      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });

        if (result.isSuccess) {
          // Remplir les champs avec la vraie localisation
          setState(() {
            _addressController.text = result.address ?? '';
            _cityController.text = result.city ?? '';
            _postalCodeController.text = result.postalCode ?? '';
            _selectedCountry = result.country ?? 'France';
          });

          if (context.mounted) {
            notificationService.success(
                context, 'Localisation détectée avec succès');
          }
        } else {
          // Afficher l'erreur
          if (context.mounted) {
            notificationService.error(context, 'Erreur de localisation',
                subtitle: result.error);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });

        if (context.mounted) {
          notificationService.error(context, 'Erreur inattendue',
              subtitle: e.toString());
        }
      }
    }
  }

  void _saveSettings() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      notificationService.error(context, 'Erreur: utilisateur non connecté');
      return;
    }

    // Validation basique
    if (_addressController.text.isEmpty && _phoneController.text.isEmpty) {
      notificationService.warning(context, 'Aucune information à sauvegarder');
      return;
    }

    try {
      // Créer l'objet UserSettings
      final userSettings = UserSettings(
        userId: currentUser.id,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text.trim(),
        country: _selectedCountry,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: DateTime.now(),
      );

      // Sauvegarder via le use case
      final saveUserSettings = ref.read(saveUserSettingsProvider);
      final result = await saveUserSettings(userSettings);

      // L'indicateur de chargement se masque automatiquement
      if (!context.mounted) return;

      result.fold(
        (failure) {
          notificationService.error(context, 'Erreur de sauvegarde',
              subtitle: failure.message);
        },
        (savedSettings) {
          // Invalider les providers pour mettre à jour les indicateurs rouges
          ref.invalidate(particulierSettingsStatusProvider);
          ref.invalidate(particulierMenuStatusProvider);

          notificationService.success(
              context, 'Paramètres sauvegardés avec succès');

          // Rester sur la page paramètres après sauvegarde
          // L'utilisateur peut retourner manuellement s'il le souhaite
        },
      );
    } catch (e) {
      // Masquer l'indicateur de chargement et afficher l'erreur
      if (mounted) {
        notificationService.error(context, 'Erreur inattendue',
            subtitle: e.toString());
      }
    }
  }
}
