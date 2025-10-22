import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget unifié pour tous les menus contextuels de l'application
/// Utilise le même design que AppMenu et SellerMenu
class ContextMenu extends StatelessWidget {
  const ContextMenu({
    super.key,
    required this.items,
    this.onSelected,
  });

  final List<ContextMenuItem> items;
  final void Function(String)? onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: AppTheme.darkGray,
        size: 20,
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppTheme.white,
      onSelected: onSelected,
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> menuItems = [];

        for (int i = 0; i < items.length; i++) {
          final item = items[i];

          // Ajouter un séparateur si nécessaire
          if (item.showDividerBefore && i > 0) {
            menuItems.add(const PopupMenuDivider());
          }

          menuItems.add(
            PopupMenuItem(
              value: item.value,
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color:
                        item.isDestructive ? AppTheme.error : AppTheme.darkGray,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: item.isDestructive
                          ? AppTheme.error
                          : AppTheme.darkGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return menuItems;
      },
    );
  }
}

/// Modèle pour un élément de menu contextuel
class ContextMenuItem {
  final String value;
  final String label;
  final IconData icon;
  final bool isDestructive;
  final bool showDividerBefore;

  const ContextMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.isDestructive = false,
    this.showDividerBefore = false,
  });
}

/// Menu contextuel pré-configuré pour les actions de suppression
class DeleteContextMenu extends StatelessWidget {
  const DeleteContextMenu({
    super.key,
    required this.onDelete,
  });

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ContextMenu(
      items: const [
        ContextMenuItem(
          value: 'delete',
          label: 'Supprimer',
          icon: Icons.delete_outline,
          isDestructive: true,
        ),
      ],
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
    );
  }
}

/// Menu contextuel pré-configuré pour les actions de modification/suppression
class EditDeleteContextMenu extends StatelessWidget {
  const EditDeleteContextMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ContextMenu(
      items: const [
        ContextMenuItem(
          value: 'edit',
          label: 'Modifier',
          icon: Icons.edit_outlined,
        ),
        ContextMenuItem(
          value: 'delete',
          label: 'Supprimer',
          icon: Icons.delete_outline,
          isDestructive: true,
          showDividerBefore: true,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
    );
  }
}

/// Menu contextuel pré-configuré pour les annonces (modifier/renommer/supprimer)
class EditRenameDeleteContextMenu extends StatelessWidget {
  const EditRenameDeleteContextMenu({
    super.key,
    required this.onEdit,
    required this.onRename,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ContextMenu(
      items: const [
        ContextMenuItem(
          value: 'edit',
          label: 'Modifier',
          icon: Icons.edit_outlined,
        ),
        ContextMenuItem(
          value: 'rename',
          label: 'Renommer',
          icon: Icons.drive_file_rename_outline,
        ),
        ContextMenuItem(
          value: 'delete',
          label: 'Supprimer',
          icon: Icons.delete_outline,
          isDestructive: true,
          showDividerBefore: true,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'rename':
            onRename();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
    );
  }
}
