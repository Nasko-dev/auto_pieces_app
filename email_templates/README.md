# Templates d'emails pour Supabase - Pièces d'Occasion

Ce dossier contient les templates d'emails modernes et responsives pour l'application **Pièces d'Occasion**.

## 📧 Templates disponibles

### 1. `confirmation_signup.html`
- **Usage** : Confirmation d'inscription
- **Couleur principale** : Bleu (#007AFF)
- **Fonctionnalités** :
  - Design responsive
  - Présentation des fonctionnalités de l'app
  - Bouton de confirmation sécurisé
  - Lien alternatif en cas de problème

### 2. `reset_password.html`
- **Usage** : Réinitialisation de mot de passe
- **Couleur principale** : Orange (#FF6B35)
- **Fonctionnalités** :
  - Alertes de sécurité
  - Conseils pour un mot de passe fort
  - Indicateur d'expiration (1 heure)
  - Design sécurisé et rassurant

### 3. `magic_link.html`
- **Usage** : Connexion sans mot de passe
- **Couleur principale** : Vert (#28a745)
- **Fonctionnalités** :
  - Badge "Magic Link"
  - Mise en avant de la sécurité
  - Informations sur l'appareil/session
  - Design moderne et fluide

### 4. `invite_user.html`
- **Usage** : Invitation d'utilisateurs
- **Couleur principale** : Violet (#6f42c1)
- **Fonctionnalités** :
  - Informations sur l'invitant
  - Statistiques de la plateforme
  - Présentation des avantages
  - Design engageant et professionnel

## 🎨 Caractéristiques du design

- **Responsive** : Optimisé pour mobile et desktop
- **Moderne** : Gradients, ombres et coins arrondis
- **Accessible** : Contrastes respectés et polices lisibles
- **Cohérent** : Charte graphique uniforme avec l'application

## ⚙️ Configuration dans Supabase

### Étapes pour importer les templates :

1. **Accéder au Dashboard Supabase**
   ```
   https://app.supabase.com/project/[PROJECT_ID]/auth/templates
   ```

2. **Sélectionner le type d'email**
   - "Confirm signup"
   - "Reset password" 
   - "Magic Link"
   - "Invite user"

3. **Remplacer le contenu**
   - Copier le contenu HTML du fichier correspondant
   - Coller dans l'éditeur Supabase
   - Sauvegarder

### Variables Supabase disponibles :

- `{{ .ConfirmationURL }}` : URL de confirmation/action
- `{{ .Email }}` : Email de l'utilisateur
- `{{ .Date }}` : Date de la demande
- `{{ .InviterName }}` : Nom de l'invitant (pour invite_user)
- `{{ .InviterEmail }}` : Email de l'invitant (pour invite_user)

## 🎯 Customisation

Pour personnaliser les templates :

### Couleurs principales par template :
- **Confirmation** : `#007AFF` (bleu iOS)
- **Reset** : `#FF6B35` (orange sécurité)  
- **Magic Link** : `#28a745` (vert confiance)
- **Invitation** : `#6f42c1` (violet premium)

### Polices utilisées :
```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
```

### Responsive breakpoint :
```css
@media only screen and (max-width: 600px)
```

## 🛠️ Tests recommandés

Avant de déployer :

1. **Test sur différents clients emails** :
   - Gmail (desktop/mobile)
   - Outlook (desktop/mobile)
   - Apple Mail
   - Thunderbird

2. **Test des liens** :
   - Vérifier que `{{ .ConfirmationURL }}` fonctionne
   - Tester le fallback du lien alternatif

3. **Test responsive** :
   - Affichage mobile
   - Affichage desktop
   - Différentes tailles d'écran

## 📱 Fonctionnalités avancées

- **Dark mode ready** : Couleurs adaptées pour le mode sombre
- **High DPI** : Icônes et images optimisées pour écrans Retina
- **Accessibilité** : Structure sémantique et contrastes WCAG
- **Performance** : CSS inline pour compatibilité maximale

## 🔧 Maintenance

Pour maintenir les templates :

1. **Cohérence visuelle** : Garder l'alignement avec l'application
2. **Tests réguliers** : Vérifier la compatibilité avec nouveaux clients
3. **Optimisation** : Réduire la taille pour améliorer les performances
4. **A/B Testing** : Tester différentes versions pour optimiser le taux de conversion

---

**Note** : Ces templates suivent les meilleures pratiques en matière d'email design et sont optimisés pour maximiser la délivrabilité et l'engagement utilisateur.