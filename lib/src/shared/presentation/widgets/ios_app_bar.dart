import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_helper.dart';

/// AppBar iOS natif réutilisable avec design system cohérent
///
/// Features:
/// - Hauteur iOS standard (44px)
/// - Bouton retour avec chevron iOS
/// - Haptic feedback sur interactions
/// - Trailing actions optionnelles
/// - Border bottom subtile iOS
/// - Support automatique du bouton retour
///
/// Exemple d'utilisation:
/// ```dart
/// IOSAppBar(
///   title: 'Mes Pièces',
///   trailing: [
///     CupertinoButton(
///       padding: EdgeInsets.zero,
///       onPressed: () {},
///       child: Icon(CupertinoIcons.add),
///     ),
///   ],
/// )
/// ```
class IOSAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Titre de l'AppBar (centré par défaut)
  final String title;

  /// Widget personnalisé pour le leading (remplace le bouton retour)
  final Widget? leading;

  /// Actions à droite de l'AppBar
  final List<Widget>? trailing;

  /// Couleur de fond (par défaut: blanc)
  final Color? backgroundColor;

  /// Si true, affiche automatiquement le bouton retour quand possible
  final bool automaticallyImplyLeading;

  /// Callback personnalisé pour le bouton retour
  final VoidCallback? onBackPressed;

  /// Style du titre (par défaut: iOS standard)
  final TextStyle? titleStyle;

  /// Padding horizontal de l'AppBar
  final EdgeInsetsGeometry? padding;

  /// Afficher la border bottom
  final bool showBorder;

  const IOSAppBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.titleStyle,
    this.padding,
    this.showBorder = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBackButton = automaticallyImplyLeading && canPop && leading == null;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.white,
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.gray.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 44,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
          child: NavigationToolbar(
            // Bouton retour iOS avec chevron
            leading: shouldShowBackButton
                ? _buildBackButton(context)
                : leading,

            // Titre centré
            middle: Text(
              title,
              style: titleStyle ?? const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
                letterSpacing: -0.41,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Actions à droite
            trailing: trailing != null && trailing!.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: trailing!,
                  )
                : null,

            middleSpacing: 16,
          ),
        ),
      ),
    );
  }

  /// Construit le bouton retour iOS avec chevron et haptic feedback
  Widget _buildBackButton(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.only(left: 8, right: 16),
      onPressed: () {
        // Haptic feedback pour la navigation
        HapticHelper.navigation();

        // Callback personnalisé ou navigation par défaut
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          context.pop();
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chevron iOS
          Icon(
            CupertinoIcons.chevron_back,
            size: 28,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 4),
          // Texte "Retour"
          Text(
            'Retour',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: AppTheme.primaryBlue,
              letterSpacing: -0.41,
            ),
          ),
        ],
      ),
    );
  }
}

/// Variante de IOSAppBar avec large title iOS
///
/// Utilise le style "Large Title" d'iOS avec collapse au scroll
/// Hauteur: 96px (44px nav + 52px large title)
class IOSLargeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? trailing;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;

  const IOSLargeAppBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: backgroundColor ?? AppTheme.white,
      border: Border(
        bottom: BorderSide(
          color: AppTheme.gray.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      leading: leading,
      middle: Text(title),
      trailing: trailing != null && trailing!.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: trailing!,
            )
          : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }
}
