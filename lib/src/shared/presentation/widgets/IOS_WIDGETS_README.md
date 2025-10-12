# Composants iOS Réutilisables

Documentation complète des composants iOS pour l'application Pièces d'Occasion.

## Table des matières

1. [HapticHelper](#haptichelper)
2. [IOSAppBar](#iosappbar)
3. [IOSBottomNavigation](#iosbottomnavigation)
4. [Installation](#installation)
5. [Exemples d'utilisation](#exemples-dutilisation)
6. [Best Practices](#best-practices)

---

## HapticHelper

### Description
Classe utilitaire pour gérer tous les retours haptiques iOS de manière cohérente.

### Fichier
`lib/src/core/utils/haptic_helper.dart`

### Méthodes disponibles

#### `HapticHelper.light()`
**Usage:** Sélections légères, tap dans une liste
**Intensité:** ●○○
**Exemple:**
```dart
onTap: () {
  HapticHelper.light();
  // Sélection d'un item
}
```

#### `HapticHelper.medium()`
**Usage:** Actions importantes, boutons principaux
**Intensité:** ●●○
**Exemple:**
```dart
onPressed: () {
  HapticHelper.medium();
  // Validation d'un formulaire
}
```

#### `HapticHelper.heavy()`
**Usage:** Actions critiques, suppression
**Intensité:** ●●●
**Exemple:**
```dart
onPressed: () {
  HapticHelper.heavy();
  // Suppression définitive
}
```

#### `HapticHelper.selection()`
**Usage:** Changements de sélection continus (slider, picker)
**Intensité:** ●○○ (rapide)
**Exemple:**
```dart
onChanged: (value) {
  HapticHelper.selection();
  // Déplacement d'un slider
}
```

#### `HapticHelper.vibrate()`
**Usage:** Erreurs, alertes importantes
**Intensité:** ●●● (long)
**Exemple:**
```dart
if (error) {
  HapticHelper.vibrate();
  // Afficher message d'erreur
}
```

#### `HapticHelper.success()`
**Usage:** Validation réussie, action complétée
**Exemple:**
```dart
HapticHelper.success();
showSnackBar('Pièce ajoutée avec succès');
```

#### `HapticHelper.navigation()`
**Usage:** Changement de page, navigation
**Exemple:**
```dart
HapticHelper.navigation();
context.go('/profile');
```

### Guide de sélection

| Action | Méthode | Raison |
|--------|---------|--------|
| Tap sur item de liste | `light()` | Interaction légère |
| Bouton principal | `medium()` | Action importante |
| Suppression | `heavy()` | Action irréversible |
| Slider change | `selection()` | Feedback continu |
| Erreur de formulaire | `vibrate()` | Alerte utilisateur |
| Validation réussie | `success()` | Confirmation positive |
| Navigation | `navigation()` | Changement de contexte |

---

## IOSAppBar

### Description
AppBar iOS natif réutilisable avec design system cohérent.

### Fichier
`lib/src/shared/presentation/widgets/ios_app_bar.dart`

### Features
- Hauteur iOS standard (44px)
- Bouton retour avec chevron iOS
- Haptic feedback automatique
- Trailing actions optionnelles
- Border bottom subtile iOS
- Support automatique du bouton retour

### Paramètres

| Paramètre | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `title` | `String` | ✅ | - | Titre de l'AppBar (centré) |
| `leading` | `Widget?` | ❌ | null | Widget personnalisé à gauche |
| `trailing` | `List<Widget>?` | ❌ | null | Actions à droite |
| `backgroundColor` | `Color?` | ❌ | `AppTheme.white` | Couleur de fond |
| `automaticallyImplyLeading` | `bool` | ❌ | `true` | Affiche le bouton retour auto |
| `onBackPressed` | `VoidCallback?` | ❌ | null | Callback personnalisé pour retour |
| `titleStyle` | `TextStyle?` | ❌ | iOS standard | Style du titre |
| `padding` | `EdgeInsetsGeometry?` | ❌ | `horizontal: 8` | Padding de l'AppBar |
| `showBorder` | `bool` | ❌ | `true` | Afficher la border bottom |

### Exemples d'utilisation

#### AppBar simple
```dart
IOSAppBar(
  title: 'Mes Pièces',
)
```

#### AppBar avec actions
```dart
IOSAppBar(
  title: 'Recherche',
  trailing: [
    CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticHelper.light();
        // Action
      },
      child: Icon(CupertinoIcons.search),
    ),
  ],
)
```

#### AppBar avec bouton retour personnalisé
```dart
IOSAppBar(
  title: 'Détails',
  onBackPressed: () {
    // Logic personnalisée avant de retourner
    if (hasUnsavedChanges) {
      showDialog(...);
    } else {
      context.pop();
    }
  },
)
```

#### AppBar sans border
```dart
IOSAppBar(
  title: 'Clean Look',
  showBorder: false,
)
```

### IOSLargeAppBar (Variante)

AppBar avec large title iOS qui collapse au scroll.

**Hauteur:** 96px (44px nav + 52px large title)

```dart
IOSLargeAppBar(
  title: 'Pièces',
  trailing: [
    CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {},
      child: Icon(CupertinoIcons.add),
    ),
  ],
)
```

---

## IOSBottomNavigation

### Description
Bottom Navigation Bar iOS natif avec support pour mode particulier et vendeur.

### Fichier
`lib/src/shared/presentation/widgets/ios_bottom_navigation.dart`

### Features
- CupertinoTabBar natif iOS
- Hauteur iOS standard (50px + safe area)
- Icônes Cupertino
- Haptic feedback sur sélection
- Badge pour messages non lus
- Items différents pour particulier vs vendeur
- Border top subtile iOS
- Animations natives iOS

### Paramètres

| Paramètre | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `currentIndex` | `int` | ✅ | - | Index de l'onglet sélectionné |
| `onTap` | `Function(int)` | ✅ | - | Callback lors du tap |
| `unreadMessagesCount` | `int?` | ❌ | null | Nombre de messages non lus |
| `isSellerMode` | `bool` | ❌ | `false` | Mode vendeur ou particulier |
| `backgroundColor` | `Color?` | ❌ | `AppTheme.white` | Couleur de fond |
| `activeColor` | `Color?` | ❌ | `AppTheme.primaryBlue` | Couleur item actif |
| `inactiveColor` | `Color?` | ❌ | `AppTheme.gray` | Couleur item inactif |

### Mode Particulier (Acheteur)

**4 onglets:**
1. **Recherche** - `CupertinoIcons.search`
2. **Favoris** - `CupertinoIcons.heart`
3. **Messages** - `CupertinoIcons.chat_bubble_2` (avec badge)
4. **Profil** - `CupertinoIcons.person`

```dart
IOSBottomNavigation(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() => _selectedIndex = index);
    // Navigation
    final route = NavigationRoutes.getBuyerRoute(index);
    context.go(route);
  },
  unreadMessagesCount: 5,
  isSellerMode: false,
)
```

### Mode Vendeur

**5 onglets:**
1. **Annonces** - `CupertinoIcons.square_grid_2x2`
2. **Ajouter** - `CupertinoIcons.add_circled`
3. **Messages** - `CupertinoIcons.chat_bubble_2` (avec badge)
4. **Stats** - `CupertinoIcons.chart_bar`
5. **Profil** - `CupertinoIcons.person`

```dart
IOSBottomNavigation(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() => _selectedIndex = index);
    // Navigation
    final route = NavigationRoutes.getSellerRoute(index);
    context.go(route);
  },
  unreadMessagesCount: 3,
  isSellerMode: true,
)
```

### Extension NavigationRoutes

Utilitaire pour mapper les index aux routes Go Router.

```dart
// Obtenir la route pour l'index (acheteur)
final route = NavigationRoutes.getBuyerRoute(0); // '/search'

// Obtenir la route pour l'index (vendeur)
final route = NavigationRoutes.getSellerRoute(1); // '/seller/add'

// Obtenir l'index depuis la route
final index = NavigationRoutes.getIndexFromRoute(
  '/messages',
  isSellerMode: false,
); // 2
```

### Badge de notification

Le badge s'affiche automatiquement sur l'onglet Messages quand `unreadMessagesCount > 0`.

**Caractéristiques:**
- Cercle rouge iOS natif
- Border blanc de 1.5px
- Affiche jusqu'à 99+
- Position: top-right de l'icône

---

## Installation

### 1. Importer le barrel file

```dart
import 'package:cente_pice/src/shared/presentation/widgets/ios_widgets.dart';
```

Cela importe automatiquement:
- `IOSAppBar`
- `IOSBottomNavigation`
- `HapticHelper`

### 2. Ou importer individuellement

```dart
import 'package:cente_pice/src/core/utils/haptic_helper.dart';
import 'package:cente_pice/src/shared/presentation/widgets/ios_app_bar.dart';
import 'package:cente_pice/src/shared/presentation/widgets/ios_bottom_navigation.dart';
```

---

## Exemples d'utilisation

### Page complète avec tous les composants

```dart
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IOSAppBar(
        title: 'Pièces d\'Occasion',
        trailing: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticHelper.light();
              // Action de recherche
            },
            child: const Icon(CupertinoIcons.search),
          ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: IOSBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        unreadMessagesCount: 5,
      ),
    );
  }

  Widget _buildContent() {
    // Votre contenu
    return Center(
      child: Text('Tab $_currentIndex'),
    );
  }
}
```

### Intégration avec Go Router

```dart
// Dans votre configuration GoRouter
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        // Déterminer l'index depuis la route
        final currentIndex = NavigationRoutes.getIndexFromRoute(
          state.uri.path,
          isSellerMode: false,
        );

        return Scaffold(
          body: child,
          bottomNavigationBar: IOSBottomNavigation(
            currentIndex: currentIndex,
            onTap: (index) {
              final route = NavigationRoutes.getBuyerRoute(index);
              context.go(route);
            },
            unreadMessagesCount: ref.watch(unreadMessagesProvider),
          ),
        );
      },
      routes: [
        GoRoute(path: '/search', builder: (context, state) => SearchPage()),
        GoRoute(path: '/favorites', builder: (context, state) => FavoritesPage()),
        GoRoute(path: '/messages', builder: (context, state) => MessagesPage()),
        GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
      ],
    ),
  ],
);
```

---

## Best Practices

### Haptic Feedback

✅ **À FAIRE:**
- Utiliser `light()` pour les interactions fréquentes
- Utiliser `medium()` pour les actions importantes
- Utiliser `heavy()` pour les actions critiques
- Appeler le haptic AVANT l'action visuelle

❌ **À ÉVITER:**
- Haptic sur chaque scroll ou animation
- Haptic trop fréquent (< 100ms d'intervalle)
- Haptic sur des actions passives

### IOSAppBar

✅ **À FAIRE:**
- Garder le titre court (max 20 caractères)
- Limiter les trailing actions à 2-3 maximum
- Utiliser des icônes Cupertino
- Respecter la hauteur de 44px

❌ **À ÉVITER:**
- Texte trop long dans le titre
- Trop d'actions dans trailing
- Icônes Material dans une AppBar iOS
- Modifier la hauteur par défaut

### IOSBottomNavigation

✅ **À FAIRE:**
- Maintenir 4-5 onglets maximum
- Utiliser des icônes reconnaissables
- Labels courts et descriptifs
- Badge uniquement pour les notifications importantes

❌ **À ÉVITER:**
- Plus de 5 onglets
- Icônes ambiguës ou personnalisées
- Onglets avec des noms trop longs
- Badge sur plusieurs onglets

### Performance

✅ **À FAIRE:**
- Utiliser `const` constructors quand possible
- Éviter les rebuilds inutiles avec keys
- Mettre en cache les badges

```dart
// Bon
const IOSAppBar(title: 'Fixed Title')

// Avec state
IOSBottomNavigation(
  key: ValueKey('nav_$isSellerMode'),
  currentIndex: _index,
  onTap: _handleTap,
)
```

### Accessibilité

✅ **À FAIRE:**
- Toutes les actions doivent avoir des labels
- Contraste suffisant (WCAG AA)
- Taille minimale de tap: 44x44px

```dart
CupertinoButton(
  padding: EdgeInsets.zero,
  onPressed: () {},
  child: Semantics(
    label: 'Rechercher des pièces',
    child: Icon(CupertinoIcons.search),
  ),
)
```

---

## Conformité iOS

Ces composants respectent:
- **Human Interface Guidelines** d'Apple
- **Hauteurs standard**: 44px AppBar, 50px TabBar
- **Icônes**: CupertinoIcons natifs
- **Animations**: Timing curves iOS
- **Haptics**: Patterns iOS standards
- **Safe Area**: Gestion automatique
- **Border**: 0.5px avec opacity 0.2

---

## Support et Questions

Pour toute question ou amélioration:
1. Vérifier cette documentation
2. Consulter `ios_widgets_example.dart`
3. Vérifier les commentaires dans le code source
4. Contacter l'équipe de développement

---

## Changelog

### v1.0.0 (2025-10-07)
- Création de `HapticHelper`
- Création de `IOSAppBar`
- Création de `IOSBottomNavigation`
- Documentation complète
- Fichier d'exemple

---

**Développé pour Pièces d'Occasion**
Design System iOS - Version 1.0.0
