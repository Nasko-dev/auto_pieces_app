import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/seller_settings_providers.dart';
import '../../../../../core/services/image_upload_service.dart';
import '../../../../../core/utils/haptic_helper.dart';
import '../../../domain/entities/seller_settings.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../shared/presentation/widgets/ios_dialog.dart';

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
          icon: const Icon(Icons.chevron_left, color: AppTheme.darkGray),
          onPressed: () {
            HapticHelper.light();
            context.go('/seller/home');
          },
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
                thumbColor: WidgetStateProperty.all(AppTheme.primaryBlue),
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
      notificationService.error(context, 'Erreur: utilisateur non connecté');
      return;
    }

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

      result.fold(
        (failure) {
          notificationService.error(context, 'Erreur de sauvegarde', subtitle: failure.message);
        },
        (savedSettings) {
          setState(() {
            _isEditingName = false;
          });

          notificationService.success(context, 'Nom de l\'entreprise mis à jour');
        },
      );
    } catch (e) {
      if (mounted) {
        notificationService.error(context, 'Erreur inattendue', subtitle: e.toString());
      }
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

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Changer la photo de profil'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              _selectImageSource(ImageSource.camera);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(CupertinoIcons.camera, color: AppTheme.primaryBlue),
                SizedBox(width: 12),
                Text('Appareil photo'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              _selectImageSource(ImageSource.gallery);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(CupertinoIcons.photo, color: AppTheme.primaryBlue),
                SizedBox(width: 12),
                Text('Galerie'),
              ],
            ),
          ),
          if (_avatarUrl != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.heavyImpact();
                _removeProfilePicture();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.delete),
                  SizedBox(width: 12),
                  Text('Supprimer la photo'),
                ],
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: const Text('Annuler'),
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
        notificationService.error(context, 'Erreur lors de la sélection de l\'image', subtitle: e.toString());
      }
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _uploadAndSaveAvatar(File imageFile) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      notificationService.error(context, 'Erreur: utilisateur non connecté');
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

  void _logout() async {
    final result = await context.showConfirmationDialog(
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      confirmText: 'Se déconnecter',
      cancelText: 'Annuler',
      isDestructive: false,
    );

    if (result == true && context.mounted) {
      _performLogout();
    }
  }

  void _performLogout() {
    // TODO: Implémenter déconnexion vendeur
    if (context.mounted) {
      context.go('/welcome');
    }

    notificationService.success(context, 'Déconnexion réussie');
  }

  void _deleteAccount() async {
    // Utiliser le nouveau dialog destructive natif
    final result = await context.showDestructiveDialog(
      title: 'Supprimer le compte',
      message: 'Cette action est irréversible. Toutes vos annonces et données seront définitivement supprimées.\n\nÊtes-vous absolument sûr ?',
      destructiveText: 'Supprimer définitivement',
      cancelText: 'Annuler',
    );

    if (result == true && mounted) {
      // TODO: Implémenter suppression de compte vendeur
      if (mounted) {
        notificationService.error(context, 'Suppression de compte - Fonctionnalité à venir');
      }
    }
  }
}
