# Cahier des charges – Yannko (cente_pice)

## 1. Présentation du projet

### 1.1. Contexte et problématique
Aujourd'hui, les automobilistes recherchent des solutions rapides, simples et économiques pour trouver des pièces détachées.
- Les plateformes en ligne existantes sont souvent généralistes (ex. petites annonces) et ne garantissent ni la qualité ni la disponibilité des pièces.
- Les casses automobiles, quant à elles, disposent de nombreuses pièces mais manquent de visibilité et de moyens numériques pour toucher directement les particuliers.
- **Résultat** : les particuliers peinent à identifier rapidement une casse qui possède la pièce dont ils ont besoin, et les casses perdent des opportunités de vente.

### 1.2. Objectifs principaux de l'application
- Offrir une plateforme unique permettant la mise en relation directe entre particuliers et casses, sans passer par plusieurs services ou applications externes.
- Faciliter la recherche de pièces grâce à un système de catalogue, de filtres et/ou de recherche par modèle de véhicule.
- Simplifier la communication entre les deux parties (messagerie intégrée, notifications, suivi de demande).
- Garantir une expérience fluide et ergonomique, adaptée aussi bien aux particuliers qu'aux professionnels des casses.
- Intégrer une API de reconnaissance de véhicule par plaque d'immatriculation (TecAlliance).

### 1.3. Public cible
- **Cible principale** : Particuliers recherchant des pièces pour leur véhicule (18-65 ans)
- **Cible secondaire** : Casses automobiles et professionnels de la vente de pièces détachées
- **Utilisateurs potentiels** :
  - Automobilistes soucieux de leur budget
  - Passionnés d'automobile et de restauration
  - Garagistes indépendants
  - Recycleurs automobiles agréés

---

## 2. Description générale

### 2.1. Fonctionnalités principales
- Effectuer des recherches de pièce moteur ou de carrosserie, en renseignant une plaque d'immatriculation ou de façon manuelle en renseignant le moteur ou le modèle, marque et année du véhicule souhaité.
- Messagerie intégrée à l'application, avec possibilité d'ajouter des photos, proposer des offres.
- Poster des demandes/annonces pour se faire contacter par un vendeur.
- Poster des annonces pour vendre des pièces de motorisation ou carrosserie/intérieur.
- Créer un compte vendeur professionnel.
- Se connecter.
- Se déconnecter.
- Répondre à une annonce.
- Refuser une annonce.
- Contacter la personne qui a posté une annonce et qui est donc à la recherche d'une pièce.

### 2.2. Fonctionnalités secondaires
- Trier et regrouper les conversations dans la messagerie en fonction de la recherche du particulier.
- Modifier son pseudo.
- Modifier le nom de l'entreprise.
- Ajouter une photo de profil.
- Ajouter son numéro de téléphone.
- Ajouter son adresse manuellement ou automatiquement.
- Récupérer son mot de passe en cas d'oubli.
- Supprimer une conversation.
- Ouvrir le service de téléphonie du téléphone avec le numéro pré-composé.
- Activer/désactiver les notifications.
- Système de favoris pour sauvegarder des annonces.
- Historique des recherches.
- Système d'évaluation et d'avis sur les vendeurs.
- Export des factures et historique des transactions.

### 2.3. Contraintes techniques
- **Compatibilité** : iOS 13+ et Android 8.0+
- **Framework** : Flutter (développement hybride)
- **Responsive** : Adaptation tablettes et smartphones
- **Mode hors ligne** : Consultation des favoris et messages déjà chargés
- **Performance** : Temps de chargement < 3 secondes
- **Accessibilité** : Conformité WCAG 2.1 niveau AA

---

## 3. Design et expérience utilisateur

### 3.1. Charte graphique
- **Style** : Épuré, moderne et minimaliste
- **Couleurs principales** :
  - Bleu principal : #2563EB (confiance, professionnalisme)
  - Blanc : #FFFFFF (clarté, simplicité)
  - Gris clair : #F3F4F6 (arrière-plans)
  - Orange accent : #F97316 (boutons d'action, notifications)
- **Typographie** : Google Fonts (Inter)
- **Iconographie** : Material Design Icons
- **Animations** : Fluides et subtiles

### 3.2. Parcours utilisateur type
1. **Onboarding** : 3 écrans de présentation
2. **Inscription simplifiée** : Email ou réseaux sociaux
3. **Recherche intuitive** : Barre de recherche centrale
4. **Résultats filtrables** : Prix, distance, disponibilité
5. **Communication directe** : Chat intégré avec vendeur

---

## 4. Fonctionnalités détaillées

### 4.1. Parcours utilisateurs

#### Utilisateur non authentifié :
- Rechercher des pièces (moteur ou carrosserie)
- Consulter les annonces publiques
- Accéder à l'écran de connexion/inscription
- Connexion anonyme pour particuliers

#### Particulier authentifié :
- Créer des demandes de pièces (PartRequest)
- Recherche par plaque d'immatriculation (API TecAlliance)
- Recherche manuelle (marque, modèle, année, motorisation)
- Consulter et répondre aux messages
- Gérer son profil et paramètres
- Basculer vers un compte vendeur ("Devenir vendeur")
- Historique des demandes et conversations

#### Vendeur authentifié :
- Dashboard avec statistiques et notifications
- Répondre aux demandes de pièces des particuliers
- Rejeter des demandes avec motif
- Créer des annonces de pièces
- Gérer les conversations groupées
- Paramètres spécifiques vendeur
- Gestion du profil professionnel

### 4.2. Tableau des fonctionnalités

| Nom de la fonctionnalité | Description | Priorité | État actuel |
|---------------------------|-------------|----------|------|
| **Authentification** | |
| Inscription email | Création de compte avec email/mot de passe | Haute | ✅ Implémenté |
| Connexion anonyme | Connexion sans compte pour particuliers | Haute | ✅ Implémenté |
| Auth vendeur | Connexion spécifique vendeurs professionnels | Haute | ✅ Implémenté |
| Récupération MDP | Envoi email de réinitialisation | Haute | ✅ Implémenté |
| Double authentification | 2FA optionnel pour vendeurs pro | Basse | À planifier |
| **Recherche** | |
| Recherche par plaque | API TecAlliance pour identifier le véhicule | Haute | ✅ Implémenté |
| Recherche manuelle | Marque/Modèle/Année/Motorisation | Haute | ✅ Implémenté |
| Distinction pièces | Moteur vs Carrosserie/Intérieur | Haute | ✅ Implémenté |
| Filtres avancés | Prix, distance, état, garantie | Haute | ⚠️ En cours |
| Recherche vocale | Dictée vocale pour recherche | Basse | À planifier |
| **Annonces** | |
| Création demande | Poster une demande de pièce (PartRequest) | Haute | ✅ Implémenté |
| Création annonce | Formulaire avec photos (max 10) | Haute | ✅ Implémenté |
| Réponse vendeur | Répondre aux demandes de pièces | Haute | ✅ Implémenté |
| Rejet demande | Rejeter une demande avec motif | Haute | ✅ Implémenté |
| Modification annonce | Édition après publication | Moyenne | ⚠️ En cours |
| Suppression annonce | Avec confirmation | Moyenne | ⚠️ En cours |
| Mise en avant | Annonces sponsorisées (payant) | Basse | À planifier |
| **Messagerie** | |
| Chat temps réel | Supabase Realtime pour messages instantanés | Haute | ✅ Implémenté |
| Envoi photos | Upload et compression automatique | Haute | ✅ Implémenté |
| Conversations groupées | Regroupement par demande de pièce | Haute | ✅ Implémenté |
| Notifications push | Nouveaux messages | Haute | ⚠️ En cours |
| Messages vocaux | Enregistrement audio | Basse | À planifier |
| **Profil utilisateur** | |
| Édition profil | Photo, nom, bio, localisation | Moyenne | ⚠️ En cours |
| Compte pro | Dashboard vendeur avec statistiques | Haute | ✅ Implémenté |
| Historique | Achats, ventes, conversations | Moyenne | ✅ Implémenté |
| Paramètres | Notifications, confidentialité | Moyenne | ✅ Implémenté |
| Mode vendeur | Switch particulier vers vendeur | Haute | ✅ Implémenté |
| **Gestion profil** | |
| Modifier pseudo | Changement du nom d'utilisateur | Moyenne | ⚠️ En cours |
| Modifier nom entreprise | Pour les comptes vendeurs | Moyenne | ⚠️ En cours |
| Photo de profil | Upload et modification photo | Moyenne | ⚠️ En cours |
| Numéro de téléphone | Ajout/modification numéro | Moyenne | ⚠️ En cours |
| Adresse | Ajout manuel ou automatique | Moyenne | ⚠️ En cours |
| **Communication** | |
| Supprimer conversation | Suppression avec confirmation | Moyenne | À développer |
| Appel téléphonique | Ouvrir dialer avec numéro | Haute | ✅ Implémenté |
| **Fonctionnalités avancées** | |
| Favoris | Sauvegarder des annonces | Moyenne | À développer |
| Historique recherches | Sauvegarder les recherches récentes | Basse | À développer |
| Évaluation vendeurs | Système de notes et avis | Moyenne | À développer |
| Export factures | PDF des transactions | Basse | À développer |
| **Support** | |
| Page d'aide/FAQ | FAQ personnalisée par type d'utilisateur | Moyenne | À développer |
| Contacter support | Formulaire ou chat de support | Moyenne | À développer |
| **Géolocalisation** | |
| Localisation auto | Permission GPS avec Geolocator | Haute | ✅ Implémenté |
| Géocodage | Conversion adresse <-> coordonnées | Haute | ✅ Implémenté |
| Carte interactive | Affichage casses proches | Moyenne | À développer |
| Calcul distance | Entre acheteur et vendeur | Moyenne | ⚠️ En cours |
| Itinéraire | Redirection vers GPS natif | Basse | À planifier |

---

## 5. Architecture et technique

### 5.1. Technologies implémentées
- **Frontend Mobile** :
  - Framework : Flutter 3.6+
  - State Management : Riverpod 2.4
  - Local Storage : Shared Preferences
  - Navigation : GoRouter 14.0

- **Backend** :
  - BaaS : Supabase (PostgreSQL, Realtime, Auth, Storage)
  - API REST : Dio + Retrofit
  - Authentification : Supabase Auth (JWT)
  - Stockage fichiers : Supabase Storage

### 5.2. API et services intégrés
- **TecAlliance** : Identification véhicule par plaque (✅ Intégré)
- **Geolocator/Geocoding** : Géolocalisation et conversion adresses (✅ Intégré)
- **Supabase Realtime** : Websockets pour chat temps réel (✅ Intégré)
- **Image Picker** : Sélection et upload de photos (✅ Intégré)
- **URL Launcher** : Ouverture liens et numéros de téléphone (✅ Intégré)
- **Firebase** : Notifications push et analytics (⚠️ À implémenter)
- **Stripe/PayPal** : Paiements (phase 2)

### 5.3. Structure de la base de données (Supabase)
- **Tables implémentées** :
  - `profiles` : Profils utilisateurs (particuliers)
  - `sellers` : Profils vendeurs professionnels
  - `part_requests` : Demandes de pièces des particuliers
  - `part_advertisements` : Annonces de pièces des vendeurs
  - `seller_responses` : Réponses des vendeurs aux demandes
  - `seller_rejections` : Rejets de demandes avec motifs
  - `messages` : Messages de conversation
  - `conversation_groups` : Groupement des conversations
  - `user_settings` : Paramètres utilisateurs
  - `seller_settings` : Paramètres vendeurs

- **Hébergement actuel** :
  - Backend : Supabase Cloud (PostgreSQL, Realtime, Auth)
  - Storage : Supabase Storage (images, fichiers)
  - Application : Distribution via Google Play Store et Apple App Store
  - Monitoring : Supabase Dashboard + Logs intégrés (AppLogger)

### 5.4. Sécurité et optimisations
- **Sécurité implémentée** :
  - Chiffrement HTTPS/TLS via Supabase
  - Auth JWT avec refresh tokens
  - RLS (Row Level Security) sur toutes les tables
  - Rate limiting intégré (RateLimiterService)
  - Validation des données côté client et serveur

- **Optimisations implémentées** :
  - Cache mémoire (MemoryCache)
  - Batch processing pour opérations groupées
  - Debouncer pour éviter les appels API excessifs
  - Service Supabase optimisé avec pool de connexions
  - Lazy loading et pagination

---

## 6. Planning prévisionnel

### État actuel du projet (Janvier 2025)
- **Phase MVP** : 80% complété
- **Fonctionnalités principales** : Implémentées
- **Backend Supabase** : Opérationnel
- **Authentification** : Fonctionnelle (particuliers et vendeurs)
- **Messagerie temps réel** : Opérationnelle
- **API TecAlliance** : Intégrée

### Phase actuelle : Finalisation MVP (4 semaines)
- **Semaine 1-2** :
  - Finalisation des fonctionnalités de modification/suppression d'annonces
  - Intégration des notifications push
  - Amélioration de l'interface vendeur
- **Semaine 3** :
  - Tests d'intégration complets
  - Corrections de bugs identifiés
  - Optimisation des performances
- **Semaine 4** :
  - Préparation du déploiement
  - Documentation utilisateur
  - Configuration des environnements de production

### Phase suivante : Beta Testing (4 semaines)
- **Semaine 1-2** : Beta fermée avec 20 testeurs sélectionnés
- **Semaine 3-4** : Beta ouverte limitée (100 utilisateurs)

### Lancement production (Mars 2025)
- **Semaine 1** : Déploiement sur stores (iOS/Android)
- **Semaine 2** : Campagne de lancement et onboarding casses

### Roadmap post-lancement
- **Q2 2025** : Système de paiement intégré, carte interactive
- **Q3 2025** : Système d'évaluation, favoris, export factures
- **Q4 2025** : Version web, API partenaires

---

## 7. Budget prévisionnel

### Investissement réalisé (Phase MVP)
- **Développement Flutter** : ~30 000 €
- **Intégration Supabase** : ~8 000 €
- **API TecAlliance** : ~5 000 €
- **Design UI/UX** : ~6 000 €
- **Tests et débogage** : ~4 000 €
**Total investi** : ~53 000 €

### Budget restant pour finalisation

### Services et licences (annuel)
- **Supabase Pro** : 300 €/mois (3 600 €/an)
- **API TecAlliance** : 200-500 €/mois selon volume (2 400-6 000 €/an)
- **Apple Developer** : 99 €/an
- **Google Play Console** : 25 € (frais unique)
- **Nom de domaine** : 50 €/an
**Total annuel** : ~6 000-10 000 €

### Marketing et lancement
- **ASO (App Store Optimization)** : 2 000 - 3 000 €
- **Campagne de lancement** : 5 000 - 10 000 €
- **Community management** : 1 500 €/mois

### Maintenance et évolutions
- **Maintenance corrective** : 1 000 - 2 000 €/mois
- **Évolutions mineures** : 3 000 - 5 000 €/trimestre
- **Support technique** : 800 - 1 500 €/mois

**Budget total estimé année 1** : 75 000 - 95 000 € (incluant développement MVP + opérationnel)

---

## 8. Critères de validation

### 8.1. Définition d'une application "terminée" (MVP)
- [✅] Authentification fonctionnelle (inscription/connexion)
- [✅] Recherche de pièces opérationnelle (plaque + manuelle)
- [✅] Création de demandes de pièces (PartRequest)
- [✅] Création d'annonces vendeurs
- [✅] Messagerie temps réel entre utilisateurs
- [✅] Dashboard vendeur avec notifications
- [⚠️] Notifications push actives
- [⚠️] Tests unitaires > 80% coverage
- [⚠️] Documentation technique complète

### 8.2. Exigences de performance
- **Temps de démarrage** : < 2 secondes
- **Temps de recherche** : < 1 seconde
- **Upload photo** : < 5 secondes (réseau 4G)
- **Disponibilité** : 99.5% uptime
- **Concurrent users** : Support 10 000 utilisateurs simultanés
- **Taille app** : < 50 MB (iOS/Android)

### 8.3. Compatibilité minimale
- **iOS** : Version 13.0 minimum
- **Android** : API level 26 (Android 8.0)
- **Résolutions** : 320px à 2436px de largeur
- **Orientations** : Portrait principalement, paysage pour certaines vues
- **Langues** : Français (v1), Anglais (v2)

### 8.4. KPIs de succès (6 mois post-lancement)
- 10 000 téléchargements
- 3 000 utilisateurs actifs mensuels
- 500 annonces publiées/mois
- Note app store > 4.0/5
- Taux de rétention J30 > 40%
- 50 casses partenaires actives

---

## 9. Risques et mitigation

| Risque | Probabilité | Impact | Mitigation | Statut |
|--------|-------------|---------|------------|--------|
| Adoption lente par les casses | Moyenne | Élevé | Programme d'onboarding gratuit, formation, période d'essai | ⚠️ Prévu |
| Problèmes de scalabilité | Faible | Élevé | Supabase auto-scaling, optimisations implémentées | ✅ Mitigé |
| Concurrence accrue | Élevée | Moyen | Focus sur l'expérience utilisateur et rapidité | ⚠️ En cours |
| Problèmes légaux (RGPD) | Faible | Élevé | RLS Supabase, auth sécurisée, anonymisation | ✅ Mitigé |
| Défaillance technique | Moyenne | Élevé | Supabase HA, logs détaillés, error handling | ✅ Mitigé |
| Coût API TecAlliance | Moyenne | Moyen | Cache agressif, recherche manuelle alternative | ✅ Mitigé |

---

## 10. Points d'attention pour le développement

### 10.1. Fonctionnalités à finaliser (Priorité haute)
1. **Notifications push** : Intégration Firebase Cloud Messaging
2. **Modification/suppression annonces** : CRUD complet pour les annonces
3. **Tests automatiques** : Augmenter la couverture de tests
4. **Documentation technique** : Finaliser la documentation API

### 10.2. Améliorations UX prioritaires
1. **Onboarding** : Tutoriel interactif pour nouveaux utilisateurs
2. **Feedback visuel** : Améliorer les indicateurs de chargement
3. **Gestion erreurs** : Messages d'erreur plus explicites
4. **Performance** : Optimiser le temps de démarrage de l'app

### 10.3. Préparation au lancement
1. **ASO** : Optimisation des descriptions App/Play Store
2. **Assets marketing** : Screenshots, vidéos de démo
3. **Support** : Mise en place du système de support client
4. **Analytics** : Intégration complète des analytics

## 11. Annexes

### 11.1. Stack technique détaillée

#### Frontend (Flutter)
- **State Management** : Riverpod 2.4
- **Navigation** : GoRouter 14.0
- **HTTP Client** : Dio + Retrofit
- **Local Storage** : SharedPreferences
- **Images** : image_picker, flutter_svg
- **Géolocalisation** : geolocator, geocoding

#### Backend (Supabase)
- **Database** : PostgreSQL avec RLS
- **Realtime** : WebSockets pour chat
- **Auth** : JWT avec refresh tokens
- **Storage** : Stockage images avec CDN
- **Functions** : Edge Functions (si besoin)

### 11.2. Glossaire
- **VIN** : Vehicle Identification Number
- **API** : Application Programming Interface
- **MVP** : Minimum Viable Product
- **KPI** : Key Performance Indicator
- **ASO** : App Store Optimization
- **RLS** : Row Level Security (Supabase)
- **JWT** : JSON Web Token
- **PartRequest** : Demande de pièce par un particulier
- **SellerResponse** : Réponse d'un vendeur à une demande

### 11.3. Contacts
- Chef de projet : Yannko
- Développeur Flutter : [En cours]
- Support technique : [email@domain.com]

---

*Document version 1.0 - Date : 2025*