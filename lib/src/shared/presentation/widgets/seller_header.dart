import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/seller_settings_providers.dart';
import '../../../features/parts/domain/entities/seller_settings.dart';
import 'seller_menu.dart';

class SellerHeader extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<SellerHeader> createState() => _SellerHeaderState();
}

class _SellerHeaderState extends ConsumerState<SellerHeader> {
  static const Color _blue = Color(0xFF1976D2);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGray = Color(0xFF6B7280);

  SellerSettings? _sellerSettings;

  @override
  void initState() {
    super.initState();
    _loadSellerSettings();
  }

  void _loadSellerSettings() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final getSellerSettings = ref.read(getSellerSettingsProvider);
    final result = await getSellerSettings(currentUser.id);

    result.fold(
      (failure) => null,
      (settings) {
        if (settings != null && mounted) {
          setState(() {
            _sellerSettings = settings;
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
      padding: EdgeInsets.only(top: media.padding.top + 16, bottom: 0),
      margin: const EdgeInsets.only(bottom: 0),
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
        // Avatar vendeur
        _buildSellerAvatar(),
        const SizedBox(width: 16),

        // Section texte avec données vendeur
        Expanded(
          child: _buildSellerInfo(),
        ),

        // Actions personnalisées ou menu
        if (widget.actions != null)
          ...widget.actions!
        else
          const SellerMenu(),
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
          const SellerMenu(),
      ],
    );
  }

  Widget _buildSellerAvatar() {
    // Utiliser l'avatar des paramètres vendeur ou fallback utilisateur auth
    final avatarUrl = _sellerSettings?.avatarUrl ??
                     Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] as String?;

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

  Widget _buildSellerInfo() {
    // Utiliser le nom de l'entreprise des paramètres vendeur ou fallback
    String displayName = _sellerSettings?.companyName ?? 'Entreprise';

    // Si pas de nom d'entreprise, utiliser les données auth
    if (displayName == 'Entreprise' || displayName.isEmpty) {
      final user = Supabase.instance.client.auth.currentUser;
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
          displayName = user.email!.split('@').first;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bienvenue',
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