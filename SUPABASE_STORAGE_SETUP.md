# Configuration Supabase Storage pour les Avatars

## Étape 1 : Créer le bucket dans l'interface Supabase

1. **Aller sur le Dashboard Supabase**
   - Ouvrir le projet dans le dashboard Supabase

2. **Naviguer vers Storage**
   - Cliquer sur l'onglet **Storage** dans le menu latéral

3. **Créer un nouveau bucket**
   - Cliquer sur **"New bucket"**
   - **Nom** : `avatars`
   - **Public bucket** : ✅ Cocher cette case (important!)
   - **File size limit** : `5` MB
   - **Allowed MIME types** : Laisser vide (autorise tous les types)
   - Cliquer sur **"Save"**

## Étape 2 : Configurer les politiques RLS

1. **Aller dans l'onglet Policies**
   - Dans Storage, cliquer sur le bucket `avatars`
   - Cliquer sur l'onglet **"Policies"**

2. **Créer une politique pour SELECT (lecture)**
   - Cliquer sur **"New Policy"**
   - **Policy name** : `Public Avatar Access`
   - **Allowed operation** : `SELECT`
   - **Target** : `For all users`
   - **Policy definition** : `true` (permet à tous de lire)
   - Cliquer sur **"Save"**

3. **Créer une politique pour INSERT (upload)**
   - Cliquer sur **"New Policy"**
   - **Policy name** : `Avatar Upload Policy`
   - **Allowed operation** : `INSERT`
   - **Target** : `For all users`
   - **Policy definition** : `true` (permet à tous d'uploader)
   - Cliquer sur **"Save"**

4. **Créer une politique pour UPDATE (modification)**
   - Cliquer sur **"New Policy"**
   - **Policy name** : `Avatar Update Policy`
   - **Allowed operation** : `UPDATE`
   - **Target** : `For all users`
   - **Policy definition** : `true` (permet à tous de modifier)
   - Cliquer sur **"Save"**

5. **Créer une politique pour DELETE (suppression)**
   - Cliquer sur **"New Policy"**
   - **Policy name** : `Avatar Delete Policy`
   - **Allowed operation** : `DELETE`
   - **Target** : `For all users`
   - **Policy definition** : `true` (permet à tous de supprimer)
   - Cliquer sur **"Save"**

## Étape 3 : Vérifier la configuration

1. **Vérifier le bucket**
   - Le bucket `avatars` doit apparaître dans la liste des buckets
   - Il doit être marqué comme **Public**

2. **Vérifier les politiques**
   - 4 politiques doivent être créées (SELECT, INSERT, UPDATE, DELETE)
   - Toutes avec la définition `true`

## Pourquoi cette configuration ?

- **Bucket public** : Permet l'accès direct aux images via URL
- **Politiques permissives** : Nécessaire car nos utilisateurs sont "anonymes" (pas authentifiés via Supabase Auth)
- **Sécurité au niveau app** : La sécurité est gérée par l'application Flutter, pas par RLS
- **Structure des fichiers** : Les fichiers sont organisés par `userId/filename.jpg`

Une fois cette configuration terminée, la fonctionnalité de photo de profil fonctionnera parfaitement !