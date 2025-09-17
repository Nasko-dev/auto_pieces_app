import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/providers/user_settings_providers.dart';
import '../../../domain/entities/user_settings.dart';

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
            _selectedCountry = settings.country;
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
          onPressed: () => context.go('/home'),
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
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.gray),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
                  hintText: 'Ex: 123 Rue de la Paix',
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
                        hintText: 'Ex: Paris',
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
                        hintText: '75000',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📍 Localisation détectée avec succès'),
              backgroundColor: AppTheme.success,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Afficher l'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Erreur de localisation'),
              backgroundColor: AppTheme.error,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Paramètres',
                textColor: AppTheme.white,
                onPressed: () {
                  // TODO: Ouvrir les paramètres de l'app
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: $e'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _saveSettings() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: utilisateur non connecté'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Validation basique
    if (_addressController.text.isEmpty && _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune information à sauvegarder'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    // Afficher un indicateur de chargement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Sauvegarde en cours...'),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        duration: Duration(seconds: 10),
      ),
    );

    try {
      // Créer l'objet UserSettings
      final userSettings = UserSettings(
        userId: currentUser.id,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
        country: _selectedCountry,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: DateTime.now(),
      );

      // Sauvegarder via le use case
      final saveUserSettings = ref.read(saveUserSettingsProvider);
      final result = await saveUserSettings(userSettings);
      
      // Masquer l'indicateur de chargement
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de sauvegarde: ${failure.message}'),
              backgroundColor: AppTheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        },
        (savedSettings) {

          // Invalider les providers pour mettre à jour les indicateurs rouges
          ref.invalidate(particulierSettingsStatusProvider);
          ref.invalidate(particulierMenuStatusProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Paramètres sauvegardés avec succès'),
                ],
              ),
              backgroundColor: AppTheme.success,
              duration: Duration(seconds: 2),
            ),
          );

          // Rester sur la page paramètres après sauvegarde
          // L'utilisateur peut retourner manuellement s'il le souhaite
        },
      );
    } catch (e) {
      // Masquer l'indicateur de chargement
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: $e'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}