#!/usr/bin/env python3
import os
import re
import sys

def replace_complex_snackbars_in_file(filepath):
    """Remplace les SnackBar complexes par les notifications iOS dans un fichier"""
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

        # Patterns complexes de remplacement
        complex_patterns = [
            # SnackBar de loading complexe
            {
                "pattern": r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const SnackBar\(\s*content: Row\(\s*children: \[\s*SizedBox\(\s*width: 20,\s*height: 20,\s*child: CircularProgressIndicator\([^)]*\),\s*\),\s*SizedBox\(width: 16\),\s*Text\('([^']+)'\),\s*\],\s*\),\s*backgroundColor: [^,]*,\s*duration: [^,)]*\),?\s*\),?\s*\);",
                "replacement": r"notificationService.showLoading(context, '\1');"
            },

            # SnackBar avec icône de succès
            {
                "pattern": r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const SnackBar\(\s*content: Row\(\s*children: \[\s*Icon\(Icons\.check_circle, color: Colors\.white\),\s*SizedBox\(width: 8\),\s*Text\('([^']+)'\),\s*\],\s*\),\s*backgroundColor: AppTheme\.success,\s*duration: Duration\(seconds: \d+\),\s*\),\s*\);",
                "replacement": r"notificationService.success(context, '\1');"
            },

            # SnackBar avec emoji
            {
                "pattern": r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const SnackBar\(\s*content: Text\('📍 ([^']+)'\),\s*backgroundColor: AppTheme\.success,\s*duration: Duration\(seconds: \d+\),\s*\),\s*\);",
                "replacement": r"notificationService.success(context, '\1');"
            },

            # SnackBar d'erreur avec action
            {
                "pattern": r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content: Text\([^)]+\),\s*backgroundColor: AppTheme\.error,\s*duration: const Duration\(seconds: \d+\),\s*action: SnackBarAction\(\s*label: '([^']+)',\s*onPressed: [^,]+,\s*textColor: Colors\.white,\s*\),\s*\),\s*\);",
                "replacement": r"// TODO: Remplacer par notification avec action"
            },

            # Masquer les snackbar
            {
                "pattern": r"ScaffoldMessenger\.of\(context\)\.hideCurrentSnackBar\(\);",
                "replacement": r"// Loading se masque automatiquement"
            }
        ]

        # Appliquer les remplacements complexes
        for replacement in complex_patterns:
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
            print(f"Modifié (complexe): {filepath}")
            return True
        else:
            print(f"Aucun changement complexe: {filepath}")
            return False

    except Exception as e:
        print(f"Erreur avec {filepath}: {e}")
        return False

def main():
    # Fichiers avec SnackBar complexes restants
    files_to_process = [
        "lib/src/features/parts/presentation/pages/seller/seller_settings_page.dart",
        "lib/src/features/parts/presentation/pages/seller/seller_profile_page.dart",
        "lib/src/features/parts/presentation/pages/Vendeur/all_notifications_page.dart",
        "lib/src/features/parts/presentation/pages/Vendeur/conversation_detail_page.dart",
        "lib/src/features/parts/presentation/pages/Vendeur/home_selleur.dart",
        "lib/src/features/parts/presentation/pages/Vendeur/my_ads_page.dart",
    ]

    modified_count = 0

    for filepath in files_to_process:
        if os.path.exists(filepath):
            if replace_complex_snackbars_in_file(filepath):
                modified_count += 1
        else:
            print(f"Fichier non trouvé: {filepath}")

    print(f"\nTerminé! {modified_count} fichiers modifiés sur {len(files_to_process)}")

if __name__ == "__main__":
    main()