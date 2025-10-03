import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/particulier_auth_providers.dart';
import '../../../../../core/providers/user_settings_providers.dart';
import '../../../../../core/services/image_upload_service.dart';
import '../../../domain/entities/user_settings.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../shared/presentation/widgets/ios_dialog.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _displayNameController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _isEditingName = false;
  bool _isLoadingProfile = true;
  bool _isUploadingImage = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _loadUserProfile() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      setState(() => _isLoadingProfile = false);
      return;
    }

    final getUserSettings = ref.read(getUserSettingsProvider);
    final result = await getUserSettings(currentUser.id);

    result.fold(
      (failure) {
        setState(() => _isLoadingProfile = false);
      },
      (settings) {
        if (settings != null && mounted) {
          setState(() {
            _displayNameController.text = settings.displayName ?? 'Utilisateur';
            _notificationsEnabled = settings.notificationsEnabled;
            _emailNotificationsEnabled = settings.emailNotificationsEnabled;
            _avatarUrl = settings.avatarUrl;
            _isLoadingProfile = false;
          });
        } else {
          setState(() {
            _displayNameController.text = 'Utilisateur';
            _isLoadingProfile = false;
          });
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
          'Mon Profil',
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingProfile
        ? const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryBlue,
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Section Profil
                _buildProfileSection(),

                const SizedBox(height: 24),

                // Section Préférences
                _buildPreferencesSection(),

                const SizedBox(height: 24),

                // Section Données
                _buildDataSection(),

                const SizedBox(height: 24),

                // Section Actions
                _buildActionsSection(),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.lightGray,
                backgroundImage: _avatarUrl != null
                    ? NetworkImage(_avatarUrl!)
                    : null,
                child: _avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: AppTheme.gray,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.white, width: 2),
                    ),
                    child: _isUploadingImage
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppTheme.white),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            color: AppTheme.white,
                            size: 16,
                          ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Nom d'affichage
          Row(
            children: [
              Expanded(
                child: _isEditingName
                    ? TextField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom d\'affichage',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        autofocus: true,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nom d\'affichage',
                            style: TextStyle(
                              color: AppTheme.gray,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _displayNameController.text,
                            style: const TextStyle(
                              color: AppTheme.darkBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _isEditingName ? _saveName : _editName,
                icon: Icon(
                  _isEditingName ? Icons.check : Icons.edit_outlined,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          
          if (_isEditingName) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _cancelEdit,
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: AppTheme.gray),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Sauvegarder'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
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
                  Icons.notifications_outlined,
                  color: AppTheme.primaryBlue,
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
          
          const SizedBox(height: 20),
          
          // Notifications générales
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recevoir des notifications',
                      style: TextStyle(
                        color: AppTheme.darkGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Notifications des nouvelles offres et messages',
                      style: TextStyle(
                        color: AppTheme.gray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                    if (!value) {
                      _emailNotificationsEnabled = false;
                    }
                  });
                  _saveNotificationPreferences();
                },
                thumbColor: WidgetStateProperty.all(AppTheme.primaryBlue),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Notifications email
          Row(
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
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _emailNotificationsEnabled && _notificationsEnabled,
                onChanged: _notificationsEnabled ? (value) {
                  setState(() {
                    _emailNotificationsEnabled = value;
                  });
                  _saveNotificationPreferences();
                } : null,
                thumbColor: WidgetStateProperty.all(AppTheme.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
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
                  Icons.storage_outlined,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mes Données',
                style: TextStyle(
                  color: AppTheme.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Effacer les données de localisation
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_off,
                color: AppTheme.warning,
                size: 20,
              ),
            ),
            title: const Text(
              'Effacer mes données de localisation',
              style: TextStyle(
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Supprimer adresse, ville et code postal',
              style: TextStyle(
                color: AppTheme.gray,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.gray,
            ),
            onTap: _clearLocationData,
          ),

          const Divider(height: 32),

          // Informations sur le compte
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Compte anonyme',
                      style: TextStyle(
                        color: AppTheme.darkBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vos données sont stockées localement sur cet appareil. Aucune adresse email requise.',
                  style: TextStyle(
                    color: AppTheme.darkGray,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
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
        children: [
          // Se déconnecter
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Supprimer le compte
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Supprimer mon compte'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editName() {
    setState(() {
      _isEditingName = true;
    });
  }

  void _saveName() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      notificationService.error(context, 'Erreur: utilisateur non connecté');
      return;
    }

    // Pas besoin d'indicateur de chargement, l'opération est rapide

    try {
      // Créer l'objet UserSettings avec le nom mis à jour
      final userSettings = UserSettings(
        userId: currentUser.id,
        displayName: _displayNameController.text.trim(),
        address: null, // On ne touche pas aux autres champs
        city: null,
        postalCode: null,
        country: 'France',
        phone: null,
        avatarUrl: _avatarUrl, // Conserver l'URL de l'avatar existant
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: null, // Laisser la base de données gérer ce champ
      );

      // Sauvegarder via le use case
      final saveUserSettings = ref.read(saveUserSettingsProvider);
      final result = await saveUserSettings(userSettings);

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
          setState(() {
            _isEditingName = false;
          });

          // Invalider les providers pour mettre à jour les indicateurs rouges
          ref.invalidate(particulierProfileStatusProvider);
          ref.invalidate(particulierMenuStatusProvider);

          notificationService.success(
            context,
            'Nom d\'affichage mis à jour',
          );
        },
      );
    } catch (e) {
      if (mounted) {
        notificationService.error(
          context,
          'Erreur inattendue',
          subtitle: e.toString(),
        );
      }
    }
  }

  void _cancelEdit() {
    // Recharger les données originales
    _loadUserProfile();
    setState(() {
      _isEditingName = false;
    });
  }

  void _saveNotificationPreferences() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    try {
      // Créer l'objet UserSettings avec les préférences mises à jour
      final userSettings = UserSettings(
        userId: currentUser.id,
        displayName: _displayNameController.text.trim(),
        address: null, // On ne touche pas aux champs d'adresse
        city: null,
        postalCode: null,
        country: 'France',
        phone: null,
        avatarUrl: _avatarUrl, // Conserver l'URL de l'avatar existant
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: null, // Laisser la base de données gérer ce champ
      );

      // Sauvegarder via le use case
      final saveUserSettings = ref.read(saveUserSettingsProvider);
      final result = await saveUserSettings(userSettings);

      result.fold(
        (failure) {
          // Restaurer l'état précédent en cas d'erreur
          _loadUserProfile();
        },
        (savedSettings) {
          // Pas de message visible, sauvegarde silencieuse
        },
      );
    } catch (e) {
      // Restaurer l'état précédent en cas d'erreur
      _loadUserProfile();
    }
  }

  void _clearLocationData() async {
    final result = await context.showWarningDialog(
      title: 'Effacer les données de localisation',
      message: 'Cette action supprimera définitivement votre adresse, ville et code postal. Vous pourrez les saisir à nouveau plus tard si nécessaire.',
      confirmText: 'Effacer',
      cancelText: 'Annuler',
    );

    if (result == true && context.mounted) {
      _performClearLocationData();
    }
  }

  void _performClearLocationData() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      notificationService.error(context, 'Erreur: utilisateur non connecté');
      return;
    }

    try {
      // Utiliser directement le dataSource pour supprimer les données de localisation
      final dataSource = ref.read(userSettingsRemoteDataSourceProvider);
      await dataSource.deleteUserSettings(currentUser.id);

      if (mounted) {
        notificationService.success(context, 'Données de localisation supprimées');
        // Recharger le profil pour refléter les changements
        _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        notificationService.error(context, 'Erreur inattendue', subtitle: e.toString());
      }
    }
  }

  void _logout() async {
    final result = await context.showConfirmationDialog(
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      confirmText: 'Se déconnecter',
      cancelText: 'Annuler',
    );

    if (result == true && context.mounted) {
      _performLogout();
    }
  }

  void _performLogout() {
    // Déconnexion via le contrôleur auth
    ref.read(particulierAuthControllerProvider.notifier).logout();
    
    // Navigation vers la page d'accueil
    if (context.mounted) {
      context.go('/welcome');
    }
    
    // Message de confirmation
    notificationService.success(context, 'Déconnexion réussie');
  }

  void _pickImage() async {
    if (_isUploadingImage) return; // Empêcher les doubles taps

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Changer la photo de profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Appareil photo
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _selectImageSource(ImageSource.camera);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppTheme.primaryBlue,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Appareil photo',
                              style: TextStyle(
                                color: AppTheme.darkGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Galerie
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _selectImageSource(ImageSource.gallery);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.photo_library,
                                color: AppTheme.primaryBlue,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Galerie',
                              style: TextStyle(
                                color: AppTheme.darkGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_avatarUrl != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _removeProfilePicture();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer la photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _selectImageSource(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80, // Optimiser la qualité pour réduire la taille
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        setState(() {
          _isUploadingImage = true;
        });

        await _uploadAndSaveAvatar(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        notificationService.error(context, 'Erreur lors de la sélection de l\'image', subtitle: e.toString());
      }
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _uploadAndSaveAvatar(File imageFile) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      notificationService.error(context, 'Erreur: utilisateur non connecté');
      setState(() {
        _isUploadingImage = false;
      });
      return;
    }

    try {
      // Upload de l'image vers Supabase Storage
      final imageUploadService = ImageUploadService(Supabase.instance.client);
      final imageUrl = await imageUploadService.uploadAvatar(
        userId: currentUser.id,
        imageFile: imageFile,
      );


      // Sauvegarder l'URL dans les paramètres utilisateur
      final userSettings = UserSettings(
        userId: currentUser.id,
        displayName: _displayNameController.text.trim(),
        address: null,
        city: null,
        postalCode: null,
        country: 'France',
        phone: null,
        avatarUrl: imageUrl, // Nouvelle URL de l'avatar
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: null, // Laisser la base de données gérer ce champ
      );

      final saveUserSettings = ref.read(saveUserSettingsProvider);
      final result = await saveUserSettings(userSettings);

      result.fold(
        (failure) {
          notificationService.error(context, 'Erreur de sauvegarde', subtitle: failure.message);
        },
        (savedSettings) {
          setState(() {
            _avatarUrl = savedSettings.avatarUrl;
          });

          notificationService.success(context, 'Photo de profil mise à jour');
        },
      );
    } catch (e) {
      if (mounted) {
        notificationService.error(context, 'Erreur lors de l\'upload', subtitle: e.toString());
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _removeProfilePicture() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    try {
      setState(() {
        _isUploadingImage = true;
      });

      // Supprimer l'ancienne image du stockage si elle existe
      if (_avatarUrl != null) {
        final imageUploadService = ImageUploadService(Supabase.instance.client);
        await imageUploadService.deleteAvatar(_avatarUrl!);
      }

      // Mettre à jour les paramètres utilisateur pour supprimer l'avatarUrl
      final userSettings = UserSettings(
        userId: currentUser.id,
        displayName: _displayNameController.text.trim(),
        address: null,
        city: null,
        postalCode: null,
        country: 'France',
        phone: null,
        avatarUrl: null, // Supprimer l'URL de l'avatar
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: null, // Laisser la base de données gérer ce champ
      );

      final saveUserSettings = ref.read(saveUserSettingsProvider);
      final result = await saveUserSettings(userSettings);

      result.fold(
        (failure) {
          notificationService.error(context, 'Erreur', subtitle: failure.message);
        },
        (savedSettings) {
          setState(() {
            _avatarUrl = null;
          });

          notificationService.success(context, 'Photo de profil supprimée');
        },
      );
    } catch (e) {
      if (mounted) {
        notificationService.error(context, 'Erreur', subtitle: e.toString());
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _deleteAccount() async {
    final result = await context.showIOSDialog(
      title: 'Supprimer le compte',
      message: 'Cette action est irréversible. Toutes vos demandes et messages seront définitivement supprimés.\n\nÊtes-vous absolument sûr ?',
      type: DialogType.error,
      confirmText: 'Supprimer définitivement',
      cancelText: 'Annuler',
    );

    if (result == true && mounted) {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          notificationService.error(context, 'Erreur: utilisateur non connecté');
        }
        return;
      }

      try {
        // Afficher un loader
        if (mounted) {
          notificationService.info(context, 'Suppression du compte en cours...');
        }

        // 1. Supprimer les données du particulier dans la base de données
        // Les RLS et CASCADE devraient gérer la suppression des données liées
        await Supabase.instance.client
            .from('particuliers')
            .delete()
            .eq('id', currentUser.id);

        // 2. Nettoyer le cache local
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 3. Déconnexion
        await Supabase.instance.client.auth.signOut();

        if (mounted) {
          notificationService.success(
            context,
            'Compte supprimé',
            subtitle: 'Votre compte et toutes vos données ont été supprimés.',
          );

          // 4. Rediriger vers la page d'accueil
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          notificationService.error(
            context,
            'Erreur lors de la suppression',
            subtitle: e.toString(),
          );
        }
      }
    }
  }
}