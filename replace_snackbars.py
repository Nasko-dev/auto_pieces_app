#!/usr/bin/env python3
import os
import re
import sys

# Patterns de remplacement pour les SnackBar
replacements = [
    # Import du service de notification
    {
        "pattern": r"(import 'package:flutter/material\.dart';)",
        "replacement": r"\1\nimport '../../../../../core/services/notification_service.dart';"
    },

    # SnackBar de succès simple
    {
        "pattern": r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const SnackBar\(\s*content: Text\('([^']+)'\),\s*backgroundColor: Colors\.green[^)]*,?\s*(?:duration: [^,)]+)?\),?\s*\);",
        "replacement": r"notificationService.success(context, '\1');"
    },

    # SnackBar d'erreur simple
    {
        "pattern": r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const SnackBar\(\s*content: Text\('([^']+)'\),\s*backgroundColor: Colors\.red[^)]*,?\s*(?:duration: [^,)]+)?\),?\s*\);",
        "replacement": r"notificationService.error(context, '\1');"
    },

    # SnackBar avec AppTheme.success
    {
        "pattern": r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const SnackBar\(\s*content: Text\('([^']+)'\),\s*backgroundColor: AppTheme\.success,?\s*(?:duration: [^,)]+)?\),?\s*\);",
        "replacement": r"notificationService.success(context, '\1');"
    },

    # SnackBar avec AppTheme.error
    {
        "pattern": r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const SnackBar\(\s*content: Text\('([^']+)'\),\s*backgroundColor: AppTheme\.error,?\s*(?:duration: [^,)]+)?\),?\s*\);",
        "replacement": r"notificationService.error(context, '\1');"
    },

    # SnackBar avec AppTheme.warning
    {
        "pattern": r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const SnackBar\(\s*content: Text\('([^']+)'\),\s*backgroundColor: AppTheme\.warning,?\s*(?:duration: [^,)]+)?\),?\s*\);",
        "replacement": r"notificationService.warning(context, '\1');"
    },
]

def replace_snackbars_in_file(filepath):
    """Remplace les SnackBar par les notifications iOS dans un fichier"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        original_content = content

        # Ajouter l'import du service de notification si pas présent
        if "notification_service.dart" not in content and "ScaffoldMessenger" in content:
            # Trouver le dernier import
            import_pattern = r"(import '[^']*';)"
            imports = re.findall(import_pattern, content)
            if imports:
                last_import = imports[-1]
                content = content.replace(
                    last_import,
                    last_import + "\nimport '../../../../../core/services/notification_service.dart';"
                )

        # Appliquer les remplacements
        for replacement in replacements[1:]:  # Skip import replacement
            content = re.sub(
                replacement["pattern"],
                replacement["replacement"],
                content,
                flags=re.MULTILINE | re.DOTALL
            )

        # Écrire le fichier modifié
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Modifié: {filepath}")
            return True
        else:
            print(f"Aucun changement: {filepath}")
            return False

    except Exception as e:
        print(f"Erreur avec {filepath}: {e}")
        return False

def main():
    # Liste des fichiers à traiter (trouvés par find)
    files_to_process = [
        "lib/src/features/auth/presentation/pages/seller_forgot_password_page.dart",
        "lib/src/features/auth/presentation/pages/seller_login_page.dart",
        "lib/src/features/auth/presentation/pages/seller_register_page.dart",
        "lib/src/features/parts/presentation/pages/particulier/become_seller_page.dart",
        "lib/src/features/parts/presentation/pages/particulier/conversations_list_page.dart",
        "lib/src/features/parts/presentation/pages/particulier/conversation_detail_page.dart",
        "lib/src/features/parts/presentation/pages/particulier/profile_page.dart",
        "lib/src/features/parts/presentation/pages/particulier/settings_page.dart",
        "lib/src/features/parts/presentation/pages/seller/seller_profile_page.dart",
        "lib/src/features/parts/presentation/pages/seller/seller_settings_page.dart",
        "lib/src/features/parts/presentation/pages/Vendeur/all_notifications_page.dart",
        "lib/src/features/parts/presentation/pages/Vendeur/conversation_detail_page.dart",
        "lib/src/features/parts/presentation/pages/Vendeur/home_selleur.dart",
        "lib/src/features/parts/presentation/pages/Vendeur/my_ads_page.dart",
        "lib/src/shared/presentation/widgets/app_menu.dart",
        "lib/src/shared/presentation/widgets/seller_menu.dart"
    ]

    modified_count = 0

    for filepath in files_to_process:
        if os.path.exists(filepath):
            if replace_snackbars_in_file(filepath):
                modified_count += 1
        else:
            print(f"Fichier non trouvé: {filepath}")

    print(f"\nTerminé! {modified_count} fichiers modifiés sur {len(files_to_process)}")

if __name__ == "__main__":
    main()