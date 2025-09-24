import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_menu.dart';

class SellerHeader extends ConsumerWidget {
  const SellerHeader({
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

  static const Color _blue = Color(0xFF1976D2);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGray = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: media.padding.top + 16, bottom: 30),
      margin: const EdgeInsets.only(bottom: 16),
      color: backgroundColor ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: title != null
            ? _buildTitleHeader(context)
            : _buildProfileHeader(ref),
      ),
    );
  }

  Widget _buildProfileHeader(WidgetRef ref) {
    return Row(
      children: [
        // Avatar vendeur
        _buildSellerAvatar(ref),
        const SizedBox(width: 16),

        // Section texte avec données vendeur
        Expanded(
          child: _buildSellerInfo(ref),
        ),

        // Actions personnalisées ou menu
        if (actions != null)
          ...actions!
        else
          const AppMenu(),
      ],
    );
  }

  Widget _buildTitleHeader(BuildContext context) {
    return Row(
      children: [
        // Bouton retour si demandé
        if (showBackButton)
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.of(context).pop(),
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

        if (showBackButton) const SizedBox(width: 16),

        // Titre
        if (centerTitle)
          Expanded(
            child: Center(
              child: Text(
                title!,
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
              title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ),

        // Actions personnalisées
        if (actions != null)
          Row(children: actions!)
        else if (!centerTitle)
          const AppMenu(),
      ],
    );
  }

  Widget _buildSellerAvatar(WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;

    // Essayer d'utiliser l'avatar de l'utilisateur connecté
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

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
  }

  Widget _buildSellerInfo(WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;

    // Récupérer le nom d'affichage depuis les métadonnées ou l'email
    String displayName = 'Vendeur';

    if (user != null) {
      final fullName = user.userMetadata?['full_name'] as String?;
      final firstName = user.userMetadata?['first_name'] as String?;
      final lastName = user.userMetadata?['last_name'] as String?;

      if (fullName != null && fullName.isNotEmpty) {
        displayName = fullName;
      } else if (firstName != null && firstName.isNotEmpty) {
        displayName = firstName;
        if (lastName != null && lastName.isNotEmpty) {
          displayName += ' $lastName';
        }
      } else if (user.email != null) {
        // Utiliser la première partie de l'email comme fallback
        displayName = user.email!.split('@').first;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Espace Vendeur',
          style: TextStyle(
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
        Icons.store,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}