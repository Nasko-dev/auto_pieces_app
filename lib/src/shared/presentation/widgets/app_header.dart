import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/particulier_auth_providers.dart';
import '../../../core/providers/user_settings_providers.dart';
import '../../../features/parts/domain/entities/user_settings.dart';
import 'app_menu.dart';

class AppHeader extends ConsumerStatefulWidget {
  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.actions,
    this.centerTitle = false,
  });

  final String? title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final bool centerTitle;

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  static const Color _blue = Color(0xFF1976D2);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGray = Color(0xFF6B7280);

  UserSettings? _userSettings;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  void _loadUserSettings() async {
    final currentUser = ref.read(particulierAuthControllerProvider).when(
      initial: () => null,
      loading: () => null,
      anonymousAuthenticated: (particulier) => particulier,
      error: (_) => null,
    );

    if (currentUser?.id == null) return;

    final getUserSettings = ref.read(getUserSettingsProvider);
    final result = await getUserSettings(currentUser!.id);

    result.fold(
      (failure) => null,
      (settings) {
        if (settings != null && mounted) {
          setState(() {
            _userSettings = settings;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: media.padding.top + 16, bottom: 30),
      margin: const EdgeInsets.only(bottom: 16),
      color: widget.backgroundColor ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: widget.title != null
            ? _buildTitleHeader(context)
            : _buildProfileHeader(),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        // Avatar utilisateur
        Consumer(
          builder: (context, ref, child) {
            final authState = ref.watch(particulierAuthControllerProvider);

            return authState.when(
              initial: () => _buildDefaultAvatar(),
              loading: () => _buildDefaultAvatar(),
              anonymousAuthenticated: (particulier) {
                final avatarUrl = particulier.avatar_url ?? _userSettings?.avatarUrl;

                if (avatarUrl != null && avatarUrl.isNotEmpty) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(22.5),
                    child: Image.network(
                      avatarUrl,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildDefaultAvatar();
                      },
                    ),
                  );
                } else {
                  return _buildDefaultAvatar();
                }
              },
              error: (message) => _buildDefaultAvatar(),
            );
          },
        ),

        const SizedBox(width: 16),

        // Section texte avec données utilisateur
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(particulierAuthControllerProvider);

              return authState.when(
                initial: () => _buildUserInfo('Bienvenue', 'Connexion...'),
                loading: () => _buildUserInfo('Bienvenue', 'Connexion...'),
                anonymousAuthenticated: (particulier) {
                  return _buildUserInfo('Bienvenue', particulier.displayName);
                },
                error: (message) {
                  return _buildUserInfo('Bienvenue', 'Utilisateur');
                },
              );
            },
          ),
        ),

        // Actions personnalisées ou menu
        if (widget.actions != null)
          ...widget.actions!
        else
          const AppMenu(),
      ],
    );
  }

  Widget _buildTitleHeader(BuildContext context) {
    return Row(
      children: [
        // Bouton retour si demandé
        if (widget.showBackButton)
          GestureDetector(
            onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: _textDark,
              ),
            ),
          ),

        if (widget.showBackButton) const SizedBox(width: 16),

        // Titre
        if (widget.centerTitle)
          Expanded(
            child: Center(
              child: Text(
                widget.title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ),

        // Actions personnalisées
        if (widget.actions != null)
          Row(children: widget.actions!)
        else if (!widget.centerTitle)
          const AppMenu(),
      ],
    );
  }

  Widget _buildUserInfo(String greeting, String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            color: _textGray,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          displayName,
          style: const TextStyle(
            color: _textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _blue.withValues(alpha: 0.8),
            _blue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.5),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}