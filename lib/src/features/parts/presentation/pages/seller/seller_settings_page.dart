import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/providers/seller_settings_providers.dart';
import '../../../domain/entities/seller_settings.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../shared/presentation/widgets/ios_notification_fixed.dart';

class SellerSettingsPage extends ConsumerStatefulWidget {
  const SellerSettingsPage({super.key});

  @override
  ConsumerState<SellerSettingsPage> createState() => _SellerSettingsPageState();
}

class _SellerSettingsPageState extends ConsumerState<SellerSettingsPage> {
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoadingSettings = true;
  bool _isLoadingLocation = false;
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSellerSettings();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _loadSellerSettings() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      setState(() => _isLoadingSettings = false);
      return;
    }

    final getSellerSettings = ref.read(getSellerSettingsProvider);
    final result = await getSellerSettings(currentUser.id);

    result.fold(
      (failure) {
        setState(() => _isLoadingSettings = false);
      },
      (settings) {
        if (settings != null && mounted) {
          setState(() {
            _companyNameController.text = settings.companyName ?? '';
            _phoneController.text = settings.phone ?? '';
            _addressController.text = settings.address ?? '';
            _cityController.text = settings.city ?? '';
            _postalCodeController.text = settings.postalCode ?? '';
            _firstNameController.text = settings.firstName ?? '';
            _lastNameController.text = settings.lastName ?? '';
            // Avatar URL géré directement par les settings
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
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkGray),
          onPressed: () => context.go('/seller/home'),
        ),
        title: const Text(
          'Paramètres Professionnels',
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
                // Section Entreprise
                _buildCompanySection(),

                const SizedBox(height: 24),

                // Section Adresse professionnelle
                _buildAddressSection(),

                const SizedBox(height: 24),

                // Section Notifications
                _buildNotificationsSection(),

                const SizedBox(height: 24),

                // Bouton Sauvegarder
                _buildSaveButton(),
              ],
            ),
          ),
    );
  }

  Widget _buildCompanySection() {
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
                  Icons.business_outlined,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Informations Entreprise',
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
            'Ces informations apparaîtront sur vos annonces et dans vos échanges avec les clients.',
            style: TextStyle(
              color: AppTheme.gray,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Nom de l'entreprise
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nom de l\'entreprise',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  hintText: 'Ex: Auto Pièces Services',
                  prefixIcon: const Icon(Icons.business, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Téléphone professionnel
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Téléphone professionnel',
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
                  hintText: 'Ex: 01 23 45 67 89',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
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
                  Icons.location_on_outlined,
                  color: AppTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Adresse Professionnelle',
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
            'Adresse de votre entreprise pour la récupération des pièces et les livraisons.',
            style: TextStyle(
              color: AppTheme.gray,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

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
                              valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
                            ),
                          )
                        : const Icon(Icons.my_location, size: 16),
                    label: Text(_isLoadingLocation ? 'Localisation...' : 'Ma position'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Ex: Zone Industrielle, 123 Rue des Mécaniques',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        hintText: 'Ex: Rennes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        hintText: '35000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildNotificationsSection() {
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
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Notifications',
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
            'Gérez vos préférences de notification pour ne rien manquer des demandes clients.',
            style: TextStyle(
              color: AppTheme.gray,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Notifications générales
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications push',
                        style: TextStyle(
                          color: AppTheme.darkGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nouvelles demandes, messages clients, etc.',
                        style: TextStyle(
                          color: AppTheme.gray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeThumbColor: AppTheme.primaryBlue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Notifications email
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications par email',
                        style: TextStyle(
                          color: AppTheme.darkGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Résumé quotidien des activités',
                        style: TextStyle(
                          color: AppTheme.gray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _emailNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _emailNotificationsEnabled = value;
                    });
                  },
                  activeThumbColor: AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
        ],
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

  void _saveSettings() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      notificationService.error(context, 'Erreur: utilisateur non connecté');
      return;
    }

    // Validation basique
    if (_companyNameController.text.isEmpty && _phoneController.text.isEmpty && _addressController.text.isEmpty) {
      notificationService.warning(context, 'Aucune information à sauvegarder');
      return;
    }

    // Afficher un indicateur de chargement
    notificationService.showLoading(context, 'Sauvegarde en cours...');

    try {
      // Créer l'objet SellerSettings
      final sellerSettings = SellerSettings(
        sellerId: currentUser.id,
        email: currentUser.email ?? '',
        companyName: _companyNameController.text.trim().isEmpty ? null : _companyNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: DateTime.now(),
      );

      // Sauvegarder via le use case
      final saveSellerSettings = ref.read(saveSellerSettingsProvider);
      final result = await saveSellerSettings(sellerSettings);

      // Vérifier que le contexte est toujours monté
      if (!context.mounted) return;

      result.fold(
        (failure) {
          notificationService.error(
            context,
            'Erreur de sauvegarde',
            subtitle: failure.message,
          );
        },
        (savedSettings) {
          notificationService.success(
            context,
            'Paramètres sauvegardés avec succès',
          );
        },
      );
    } catch (e) {
      // Gérer l'erreur
      if (mounted) {
        notificationService.error(
          context,
          'Erreur inattendue',
          subtitle: e.toString(),
        );
      }
    }
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
          });

          notificationService.success(
            context,
            '📍 Localisation détectée avec succès',
          );
        } else {
          // Afficher l'erreur
          notificationService.showWithAction(
            context: context,
            message: result.error ?? 'Erreur de localisation',
            actionLabel: 'Paramètres',
            type: NotificationType.error,
            onAction: () {
              // TODO: Ouvrir les paramètres de l'app
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });

        notificationService.error(
          context,
          'Erreur inattendue',
          subtitle: e.toString(),
        );
      }
    }
  }
}