# 🔐 COMPTES DE DÉMONSTRATION POUR APPLE APP STORE REVIEW

**OBLIGATOIRE:** Apple demande des comptes de test fonctionnels pour reviewer l'app!

---

## 📋 À FOURNIR DANS APP STORE CONNECT

### Section "App Review Information"
- ✅ **Demo Account Required:** YES
- ✅ **Username + Password** pour tester toutes les fonctionnalités

---

## 👥 COMPTES DE TEST À CRÉER

### 1. COMPTE PARTICULIER (Acheteur)

**Email:** `demo.particulier@pieceautoenligne.fr`
**Mot de passe:** `AppleReview2025!`
**Type:** Utilisateur particulier

**Profil pré-rempli:**
- ✅ Nom: Jean Dupont
- ✅ Téléphone: 06 12 34 56 78
- ✅ Adresse: 123 Rue de la République, 75001 Paris
- ✅ Localisation: Paris, France

**Données de démo:**
- ✅ 2-3 demandes de pièces actives
- ✅ 1-2 conversations avec vendeurs
- ✅ Notifications activées

---

### 2. COMPTE VENDEUR (Professionnel)

**Email:** `demo.vendeur@pieceautoenligne.fr`
**Mot de passe:** `AppleReview2025!`
**Type:** Vendeur professionnel

**Profil pré-rempli:**
- ✅ Entreprise: Auto Pièces Demo SARL
- ✅ Téléphone: 01 23 45 67 89
- ✅ Adresse: Zone Industrielle, 456 Avenue des Mécaniques, 69001 Lyon
- ✅ SIRET: 12345678901234

**Données de démo:**
- ✅ 5-10 annonces de pièces publiées (avec photos)
- ✅ 2-3 conversations avec particuliers
- ✅ Quelques demandes reçues
- ✅ Notifications activées

---

## ✅ CHECKLIST AVANT SOUMISSION

### Comptes de démo:
- [ ] Créer compte particulier avec email + password
- [ ] Créer compte vendeur avec email + password
- [ ] Remplir profils complètement
- [ ] Ajouter photos de profil
- [ ] Publier annonces de démo (vendeur)
- [ ] Créer demandes de démo (particulier)
- [ ] Créer conversations entre les 2 comptes
- [ ] Tester connexion avec les 2 comptes
- [ ] Vérifier toutes les fonctionnalités marchent

### Données de démo réalistes:
- [ ] Photos de pièces automobiles (vraies ou stock photos)
- [ ] Descriptions détaillées des pièces
- [ ] Prix réalistes
- [ ] Conversations naturelles (pas de lorem ipsum!)
- [ ] Localisation cohérente

### Documentation pour Apple:
- [ ] Noter les identifiants dans App Store Connect
- [ ] Ajouter notes explicatives si nécessaire
- [ ] Préciser quelles fonctionnalités tester en priorité

---

## 📝 NOTES POUR APP STORE CONNECT

### "Review Notes" à fournir:

```
DEMO ACCOUNTS:

1. COMPTE PARTICULIER (Buyer):
   Email: demo.particulier@pieceautoenligne.fr
   Password: AppleReview2025!

   Ce compte permet de tester:
   - Création de demandes de pièces automobiles
   - Recherche par immatriculation
   - Messagerie avec vendeurs
   - Notifications push
   - Géolocalisation (Paris)

2. COMPTE VENDEUR (Seller):
   Email: demo.vendeur@pieceautoenligne.fr
   Password: AppleReview2025!

   Ce compte permet de tester:
   - Publication d'annonces de pièces
   - Gestion du catalogue
   - Réponse aux demandes clients
   - Messagerie avec acheteurs
   - Notifications push
   - Géolocalisation (Lyon)

FONCTIONNALITÉS CLÉS À TESTER:
- Privacy Policy accessible depuis Settings et Help
- Permissions (Camera, Photos, Location When In Use)
- Notifications push (OneSignal)
- Messagerie en temps réel (Supabase)
- Recherche géolocalisée

NOTES IMPORTANTES:
- L'app utilise uniquement "Location When In Use" (pas Always)
- Toutes les données sont stockées sur Supabase (Europe)
- Aucun tracking publicitaire
- Privacy Policy: https://www.pieceautoenligne.fr/privacy
```

---

## 🔒 SÉCURITÉ DES COMPTES DE DÉMO

### Bonnes pratiques:
- ✅ Email dédié (pas personnel)
- ✅ Mot de passe fort mais simple à retenir
- ✅ Données fictives réalistes
- ✅ Pas de vraies données personnelles
- ✅ Supprimer après validation Apple (optionnel)

### À NE PAS FAIRE:
- ❌ Utiliser votre email personnel
- ❌ Mettre de vraies données bancaires
- ❌ Laisser le compte vide sans données

---

## 🎬 SCÉNARIOS DE TEST POUR APPLE REVIEWERS

### Scénario 1: Utilisateur Particulier
1. Se connecter avec compte particulier
2. Aller sur Home → "Poster une demande"
3. Entrer immatriculation (ex: AB-123-CD)
4. Sélectionner type de pièce (ex: Moteur)
5. Compléter la demande
6. Voir la demande dans "Mes Recherches"
7. Recevoir notification quand vendeur répond
8. Ouvrir messagerie et discuter

### Scénario 2: Vendeur Professionnel
1. Se connecter avec compte vendeur
2. Aller sur Tableau de bord vendeur
3. Cliquer "Déposer une annonce"
4. Ajouter photos de pièce
5. Remplir informations (marque, modèle, prix)
6. Publier l'annonce
7. Voir l'annonce dans "Mes annonces"
8. Recevoir demande d'un particulier
9. Répondre via messagerie

### Scénario 3: Privacy & Permissions
1. Aller dans Settings → "Informations légales"
2. Cliquer "Politique de confidentialité"
3. Lire le contenu in-app
4. Cliquer "Ouvrir sur le web" → vérifie le lien
5. Revenir dans Help → vérifier liens également
6. Tester ajout photo → vérifie permission Camera/Photos
7. Tester localisation → vérifie permission "When In Use"

---

## 🚨 POINTS D'ATTENTION POUR REVIEWERS

### Ce qu'Apple va vérifier:
- ✅ **Privacy Policy accessible** in-app
- ✅ **Permissions justifiées** (When In Use uniquement)
- ✅ **Pas de crash** lors de l'utilisation
- ✅ **Fonctionnalités principales fonctionnent**
- ✅ **Contenu approprié** (pas de contenu choquant)
- ✅ **Respect des guidelines** Apple

### Messages d'erreur acceptables:
- "Aucune pièce trouvée pour cette recherche" (normal si démo)
- "Aucun vendeur dans votre région" (normal si démo)

### Messages d'erreur NON acceptables:
- ❌ Crashes
- ❌ "API Key invalid"
- ❌ "Network error" constant
- ❌ Écrans blancs

---

## 📧 TEMPLATE EMAIL DE SUIVI

Si Apple demande des clarifications:

```
Subject: Demo Account Access for "Pièces d'Occasion" Review

Hello Apple Review Team,

Thank you for reviewing our app "Pièces d'Occasion".

Here are the demo credentials again:

BUYER ACCOUNT:
Email: demo.particulier@pieceautoenligne.fr
Password: AppleReview2025!

SELLER ACCOUNT:
Email: demo.vendeur@pieceautoenligne.fr
Password: AppleReview2025!

Both accounts have pre-filled profiles and demo data.

Key features to test:
1. Privacy Policy (Settings → Legal Information)
2. Location "When In Use" permission
3. Messaging between buyer and seller
4. Push notifications

Our Privacy Policy is accessible:
- In-app: Settings → Legal Information → Privacy Policy
- Web: https://www.pieceautoenligne.fr/privacy

Please let me know if you need any additional information.

Best regards,
[Your Name]
```

---

## ✅ VALIDATION FINALE

Avant de soumettre, **TESTER SOI-MÊME** avec ces comptes:

```bash
# Checklist de validation:
1. [ ] Les 2 comptes se connectent sans erreur
2. [ ] Profils sont complets et réalistes
3. [ ] Données de démo présentes et cohérentes
4. [ ] Toutes les fonctionnalités principales fonctionnent
5. [ ] Permissions demandées correctement
6. [ ] Privacy Policy accessible partout
7. [ ] Notifications fonctionnent
8. [ ] Messagerie fonctionne
9. [ ] Photos uploadent correctement
10. [ ] Pas de crash sur parcours utilisateur classique
```

---

## 🎯 RÉSUMÉ

**OBLIGATOIRE AVANT SOUMISSION:**

1. ✅ Créer 2 comptes de démo (particulier + vendeur)
2. ✅ Remplir les profils complètement
3. ✅ Ajouter données réalistes (annonces, demandes, messages)
4. ✅ Tester les 2 comptes fonctionnent parfaitement
5. ✅ Noter identifiants dans App Store Connect
6. ✅ Ajouter notes explicatives pour reviewers

**Sans comptes de démo fonctionnels = REJET AUTOMATIQUE!** ⚠️

---

**Créé le:** 22 octobre 2025
**Par:** Claude Code
**Statut:** ⏳ À CRÉER AVANT SOUMISSION
