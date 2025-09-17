import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/seller_settings_providers.dart';
import '../../../../../core/services/image_upload_service.dart';
import '../../../domain/entities/seller_settings.dart';

class SellerProfilePage extends ConsumerStatefulWidget {
  const SellerProfilePage({super.key});

  @override
  ConsumerState<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends ConsumerState<SellerProfilePage> {
  final _companyNameController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _isEditingName = false;
  bool _isLoadingProfile = true;
  bool _isUploadingImage = false;
  String? _avatarUrl;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadSellerProfile();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  void _loadSellerProfile() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      setState(() => _isLoadingProfile = false);
      return;
    }

    final getSellerSettings = ref.read(getSellerSettingsProvider);
    final result = await getSellerSettings(currentUser.id);

    result.fold(
      (failure) {
        setState(() => _isLoadingProfile = false);
      },
      (settings) {
        if (settings != null && mounted) {
          setState(() {
            _companyNameController.text = settings.companyName ?? 'Mon Entreprise';
            _notificationsEnabled = settings.notificationsEnabled;
            _emailNotificationsEnabled = settings.emailNotificationsEnabled;
            _avatarUrl = settings.avatarUrl;
            _userEmail = settings.email;
            _isLoadingProfile = false;
          });
        } else {
          setState(() {
            _companyNameController.text = 'Mon Entreprise';
            _userEmail = currentUser.email ?? 'Email non disponible';
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
          onPressed: () => context.go('/seller/home'),
        ),
        title: const Text(
          'Mon Profil Professionnel',
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
                        Icons.business,
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

          // Nom de l'entreprise
          Row(
            children: [
              Expanded(
                child: _isEditingName
                    ? TextField(
                        controller: _companyNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom de l\'entreprise',
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
                            'Nom de l\'entreprise',
                            style: TextStyle(
                              color: AppTheme.gray,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _companyNameController.text,
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
                onPressed: _isEditingName ? _saveCompanyName : _editCompanyName,
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
                  onPressed: _saveCompanyName,
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

          const SizedBox(height: 20),

          // Email professionnel (non éditable)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  color: AppTheme.gray,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email professionnel',
                        style: TextStyle(
                          color: AppTheme.gray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userEmail ?? 'Email non disponible',
                        style: const TextStyle(
                          color: AppTheme.darkGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                      'Notifications des nouvelles demandes et messages',
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
                activeColor: AppTheme.primaryBlue,
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
                      'Résumé quotidien des nouvelles demandes',
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
                activeColor: AppTheme.primaryBlue,
              ),
            ],
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

  void _editCompanyName() {
    setState(() {
      _isEditingName = true;
    });
  }

  void _cancelEdit() {
    _loadSellerProfile();
    setState(() {
      _isEditingName = false;
    });
  }

  void _saveCompanyName() async {
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
      final sellerSettings = SellerSettings(
        sellerId: currentUser.id,
        email: _userEmail ?? currentUser.email ?? '',
        companyName: _companyNameController.text.trim(),
        avatarUrl: _avatarUrl,
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: DateTime.now(),
      );

      final saveSellerSettings = ref.read(saveSellerSettingsProvider);
      final result = await saveSellerSettings(sellerSettings);

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
          setState(() {
            _isEditingName = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Nom de l\'entreprise mis à jour'),
                ],
              ),
              backgroundColor: AppTheme.success,
              duration: Duration(seconds: 2),
            ),
          );
        },
      );
    } catch (e) {
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

  void _saveNotificationPreferences() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    try {
      final sellerSettings = SellerSettings(
        sellerId: currentUser.id,
        email: _userEmail ?? currentUser.email ?? '',
        companyName: _companyNameController.text.trim(),
        avatarUrl: _avatarUrl,
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: DateTime.now(),
      );

      final saveSellerSettings = ref.read(saveSellerSettingsProvider);
      final result = await saveSellerSettings(sellerSettings);

      result.fold(
        (failure) {
          _loadSellerProfile();
        },
        (savedSettings) {
        },
      );
    } catch (e) {
      _loadSellerProfile();
    }
  }

  void _pickImage() async {
    if (_isUploadingImage) return;

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
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        setState(() {
          _isUploadingImage = true;
        });

        _uploadAndSaveAvatar(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _uploadAndSaveAvatar(File imageFile) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: utilisateur non connecté'),
          backgroundColor: AppTheme.error,
        ),
      );
      setState(() {
        _isUploadingImage = false;
      });
      return;
    }

    try {
      final imageUploadService = ImageUploadService(Supabase.instance.client);
      final imageUrl = await imageUploadService.uploadAvatar(
        userId: currentUser.id,
        imageFile: imageFile,
      );


      final sellerSettings = SellerSettings(
        sellerId: currentUser.id,
        email: _userEmail ?? currentUser.email ?? '',
        companyName: _companyNameController.text.trim(),
        avatarUrl: imageUrl,
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: DateTime.now(),
      );

      final saveSellerSettings = ref.read(saveSellerSettingsProvider);
      final result = await saveSellerSettings(sellerSettings);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de sauvegarde: ${failure.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        },
        (savedSettings) {
          setState(() {
            _avatarUrl = savedSettings.avatarUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Photo de profil mise à jour'),
                ],
              ),
              backgroundColor: AppTheme.success,
              duration: Duration(seconds: 2),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
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

      if (_avatarUrl != null) {
        final imageUploadService = ImageUploadService(Supabase.instance.client);
        await imageUploadService.deleteAvatar(_avatarUrl!);
      }

      final sellerSettings = SellerSettings(
        sellerId: currentUser.id,
        email: _userEmail ?? currentUser.email ?? '',
        companyName: _companyNameController.text.trim(),
        avatarUrl: null,
        notificationsEnabled: _notificationsEnabled,
        emailNotificationsEnabled: _emailNotificationsEnabled,
        updatedAt: DateTime.now(),
      );

      final saveSellerSettings = ref.read(saveSellerSettingsProvider);
      final result = await saveSellerSettings(sellerSettings);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${failure.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        },
        (savedSettings) {
          setState(() {
            _avatarUrl = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Photo de profil supprimée'),
                ],
              ),
              backgroundColor: AppTheme.success,
              duration: Duration(seconds: 2),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.primaryBlue, size: 24),
            SizedBox(width: 12),
            Text(
              'Déconnexion',
              style: TextStyle(
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(
            color: AppTheme.darkGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: AppTheme.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: AppTheme.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // TODO: Implémenter déconnexion vendeur
    if (context.mounted) {
      context.go('/welcome');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Déconnexion réussie'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.error, size: 24),
            SizedBox(width: 12),
            Text(
              'Supprimer le compte',
              style: TextStyle(
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Cette action est irréversible. Toutes vos annonces et données seront définitivement supprimées.\n\nÊtes-vous absolument sûr ?',
          style: TextStyle(
            color: AppTheme.darkGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: AppTheme.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implémenter suppression de compte vendeur
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suppression de compte - Fonctionnalité à venir'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: AppTheme.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Supprimer définitivement',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}