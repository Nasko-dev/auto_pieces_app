import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_helper.dart';

/// Widget de filtres pour les conversations avec deux options : Tous / Non lus
///
/// Affiche deux chips côte à côte permettant de filtrer :
/// - Toutes les conversations
/// - Uniquement les conversations avec messages non lus
class ConversationFilterChips extends StatelessWidget {
  /// Si le filtre "Non lus" est actif
  final bool showOnlyUnread;

  /// Callback appelé quand l'utilisateur change de filtre
  final ValueChanged<bool> onFilterChanged;

  /// Nombre total de messages non lus
  final int unreadCount;

  const ConversationFilterChips({
    super.key,
    required this.showOnlyUnread,
    required this.onFilterChanged,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildFilterChip(
          label: 'Tous',
          icon: Icons.chat_bubble_outline,
          isActive: !showOnlyUnread,
          onTap: () {
            HapticHelper.light();
            onFilterChanged(false);
          },
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          label: 'Non lus',
          icon: Icons.mark_email_unread,
          isActive: showOnlyUnread,
          onTap: () {
            HapticHelper.light();
            onFilterChanged(true);
          },
          badge: unreadCount > 0 ? unreadCount : null,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryBlue
                : AppTheme.gray.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppTheme.white : AppTheme.darkGray,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? AppTheme.white : AppTheme.darkGray,
              ),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.white : AppTheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppTheme.primaryBlue : AppTheme.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de filtre pour afficher uniquement les conversations avec messages non lus
///
/// @deprecated Utiliser ConversationFilterChips à la place
class UnreadFilterChip extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;
  final int? unreadCount;

  const UnreadFilterChip({
    super.key,
    required this.isActive,
    required this.onToggle,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return ConversationFilterChips(
      showOnlyUnread: isActive,
      onFilterChanged: (value) => onToggle(),
      unreadCount: unreadCount ?? 0,
    );
  }
}
