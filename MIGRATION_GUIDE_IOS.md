# GUIDE DE MIGRATION VERS IOS NATIVE

Ce guide fournit des exemples concrets de conversion des composants Material vers Cupertino pour l'application Yannko Pièce d'Occasion.

---

## TABLE DES MATIÈRES

1. [Setup Initial](#1-setup-initial)
2. [Migration App Root](#2-migration-app-root)
3. [Navigation](#3-navigation)
4. [Formulaires](#4-formulaires)
5. [Dialogs & Modals](#5-dialogs--modals)
6. [Listes & Cartes](#6-listes--cartes)
7. [Feedback Utilisateur](#7-feedback-utilisateur)
8. [Widgets Réutilisables](#8-widgets-réutilisables)
9. [Exemples par Fichier](#9-exemples-par-fichier)

---

## 1. SETUP INITIAL

### 1.1 Ajouter les imports Cupertino partout

```dart
// Ajouter en haut de CHAQUE fichier:
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // Pour HapticFeedback
```

### 1.2 Créer les helpers iOS

**Créer**: `lib/src/core/utils/haptic_helper.dart`
```dart
import 'package:flutter/services.dart';

/// Helper centralisé pour le Haptic Feedback iOS
class HapticHelper {
  /// Tap léger - Sélections, navigation, switches
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Tap moyen - Boutons, actions normales
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Tap fort - Actions destructives, suppressions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection - Navigation tabs, pickers
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Success notification
  static void success() {
    HapticFeedback.lightImpact();
    Future.delayed(Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Error notification
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Vibration pour pull-to-refresh
  static void refresh() {
    HapticFeedback.mediumImpact();
  }
}
```

### 1.3 Créer le theme iOS

**Créer**: `lib/src/core/theme/ios_theme.dart`
```dart
import 'package:flutter/cupertino.dart';

class IOSTheme {
  // Couleurs adaptatives pour light/dark mode
  static const primaryBlue = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF007AFF),
    darkColor: Color(0xFF0A84FF),
  );

  static const systemBackground = CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: Color(0xFF000000),
  );

  static const secondarySystemBackground = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF2F2F7),
    darkColor: Color(0xFF1C1C1E),
  );

  static const tertiarySystemBackground = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF2C2C2E),
  );

  static const label = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF000000),
    darkColor: Color(0xFFFFFFFF),
  );

  static const secondaryLabel = CupertinoDynamicColor.withBrightness(
    color: Color(0x993C3C43),
    darkColor: Color(0x99EBEBF5),
  );

  static const separator = CupertinoDynamicColor.withBrightness(
    color: Color(0x4D3C3C43),
    darkColor: Color(0x4D545458),
  );

  // Typographie SF Pro
  static const TextStyle largeTitle = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
  );

  static const TextStyle title1 = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
  );

  static const TextStyle title3 = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  static const TextStyle body = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
  );

  static const TextStyle callout = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
  );

  static const TextStyle subheadline = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
  );

  static const TextStyle footnote = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
  );

  static const TextStyle caption1 = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.06,
  );

  // Thème Cupertino
  static CupertinoThemeData get lightTheme {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: systemBackground,
      barBackgroundColor: systemBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: body,
        primaryColor: label,
      ),
    );
  }

  static CupertinoThemeData get darkTheme {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: systemBackground,
      barBackgroundColor: systemBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: body.copyWith(color: CupertinoColors.white),
        primaryColor: label,
      ),
    );
  }
}
```

---

## 2. MIGRATION APP ROOT

### 2.1 Remplacer MaterialApp par CupertinoApp

**Fichier**: `lib/main.dart` (ligne 159-165)

**AVANT**:
```dart
return MaterialApp.router(
  title: 'Pièces d\'Occasion',
  theme: AppTheme.lightTheme,
  routerConfig: router,
  debugShowCheckedModeBanner: false,
);
```

**APRÈS**:
```dart
return CupertinoApp.router(
  title: 'Pièces d\'Occasion',
  theme: IOSTheme.lightTheme,
  routerConfig: router,
  debugShowCheckedModeBanner: false,
  localizationsDelegates: [
    DefaultCupertinoLocalizations.delegate,
    // Autres delegates si nécessaire
  ],
);
```

---

## 3. NAVIGATION

### 3.1 Bottom Tab Bar iOS

**Fichier**: `lib/src/shared/presentation/widgets/main_wrapper.dart`

**AVANT** (ligne 60-122):
```dart
return AuthWrapper(
  child: Scaffold(
    body: widget.child,
    bottomNavigationBar: Container(
      decoration: BoxDecoration(/* ... */),
      child: SafeArea(
        child: Container(
          height: 56,
          child: Row(
            children: [
              _buildNavItem(/* ... */),
              // ...
            ],
          ),
        ),
      ),
    ),
  ),
);
```

**APRÈS**:
```dart
return AuthWrapper(
  child: CupertinoTabScaffold(
    tabBar: CupertinoTabBar(
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      border: Border(
        top: BorderSide(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          activeIcon: Icon(CupertinoIcons.home_fill),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.doc_text),
          activeIcon: Icon(CupertinoIcons.doc_text_fill),
          label: 'Demandes',
        ),
        BottomNavigationBarItem(
          icon: _buildMessagesIcon(),
          activeIcon: _buildMessagesIcon(active: true),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.building_2_filled),
          activeIcon: Icon(CupertinoIcons.building_2_filled),
          label: 'Vendeur',
        ),
      ],
      onTap: (index) {
        HapticHelper.selection();
        _onTabSelected(index);
      },
    ),
    tabBuilder: (context, index) {
      return CupertinoTabView(
        builder: (context) => _getPageForIndex(index),
      );
    },
  ),
);

Widget _buildMessagesIcon({bool active = false}) {
  final hasUnread = ref.watch(particulierConversationsControllerProvider).unreadCount > 0;

  return Stack(
    clipBehavior: Clip.none,
    children: [
      Icon(active ? CupertinoIcons.chat_bubble_fill : CupertinoIcons.chat_bubble),
      if (hasUnread)
        Positioned(
          right: -6,
          top: -3,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: CupertinoColors.systemRed,
              shape: BoxShape.circle,
            ),
          ),
        ),
    ],
  );
}

Widget _getPageForIndex(int index) {
  switch (index) {
    case 0: return HomePage();
    case 1: return RequestsPage();
    case 2: return ConversationsListPage();
    case 3: return BecomeSellerPage();
    default: return HomePage();
  }
}

void _onTabSelected(int index) {
  final routes = ['/home', '/requests', '/conversations', '/become-seller'];
  context.go(routes[index]);
}
```

### 3.2 Navigation Bar (Header)

**Fichier**: `lib/src/shared/presentation/widgets/app_header.dart`

**AVANT** (ligne 155-210):
```dart
Widget _buildTitleHeader(BuildContext context) {
  return Row(
    children: [
      if (widget.showBackButton)
        GestureDetector(
          onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
      // ...
    ],
  );
}
```

**APRÈS**:
```dart
// Remplacer le header custom par CupertinoNavigationBar
// Dans la page qui utilise AppHeader:

@override
Widget build(BuildContext context) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      border: null,
      leading: widget.showBackButton
        ? CupertinoNavigationBarBackButton(
            onPressed: () {
              HapticHelper.light();
              widget.onBackPressed?.call() ?? Navigator.of(context).pop();
            },
          )
        : null,
      middle: widget.title != null
        ? Text(
            widget.title!,
            style: IOSTheme.headline,
          )
        : _buildProfileSection(),
      trailing: widget.actions != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.actions!,
          )
        : _buildMenuButton(),
    ),
    child: SafeArea(
      child: widget.child,
    ),
  );
}

Widget _buildProfileSection() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildAvatar(),
      SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bienvenue', style: IOSTheme.caption1),
          Text('Utilisateur', style: IOSTheme.callout),
        ],
      ),
    ],
  );
}
```

---

## 4. FORMULAIRES

### 4.1 TextField iOS

**Fichier**: `lib/src/features/auth/presentation/pages/seller_login_page.dart` (ligne 302-347)

**AVANT**:
```dart
TextFormField(
  controller: controller,
  obscureText: obscureText,
  style: GoogleFonts.inter(fontSize: 16 * scale),
  decoration: InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: _fieldBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12 * scale),
      borderSide: BorderSide(color: _borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12 * scale),
      borderSide: BorderSide(color: _primaryBlue, width: 2),
    ),
  ),
)
```

**APRÈS**:
```dart
CupertinoTextField(
  controller: controller,
  obscureText: obscureText,
  placeholder: hintText,
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: CupertinoColors.systemGrey6.resolveFrom(context),
    borderRadius: BorderRadius.circular(10),
  ),
  style: IOSTheme.body,
  placeholderStyle: IOSTheme.body.copyWith(
    color: CupertinoColors.placeholderText,
  ),
  onTap: () => HapticHelper.light(),
  suffix: suffixIcon != null
    ? Padding(
        padding: EdgeInsets.only(right: 8),
        child: suffixIcon,
      )
    : null,
)
```

### 4.2 Boutons iOS

**Fichier**: `lib/src/features/auth/presentation/pages/seller_login_page.dart` (ligne 215-248)

**AVANT**:
```dart
ElevatedButton(
  onPressed: authState.isLoading ? null : _handleLogin,
  style: ElevatedButton.styleFrom(
    backgroundColor: _primaryBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16 * s),
    ),
  ),
  child: authState.isLoading
    ? CircularProgressIndicator()
    : Text('Se connecter'),
)
```

**APRÈS**:
```dart
CupertinoButton.filled(
  onPressed: authState.isLoading ? null : () {
    HapticHelper.medium();
    _handleLogin();
  },
  borderRadius: BorderRadius.circular(10),
  padding: EdgeInsets.symmetric(vertical: 16),
  child: authState.isLoading
    ? CupertinoActivityIndicator(color: CupertinoColors.white)
    : Text(
        'Se connecter',
        style: IOSTheme.headline.copyWith(color: CupertinoColors.white),
      ),
)
```

### 4.3 TextButton iOS

**AVANT**:
```dart
TextButton(
  onPressed: () => context.push('/seller/register'),
  child: Text('Créer un compte'),
)
```

**APRÈS**:
```dart
CupertinoButton(
  padding: EdgeInsets.zero,
  onPressed: () {
    HapticHelper.light();
    context.push('/seller/register');
  },
  child: Text(
    'Créer un compte',
    style: IOSTheme.callout.copyWith(
      color: IOSTheme.primaryBlue,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

---

## 5. DIALOGS & MODALS

### 5.1 Alert Dialog iOS

**AVANT**:
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirmation'),
    content: Text('Êtes-vous sûr de vouloir continuer ?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Annuler'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          _confirm();
        },
        child: Text('OK'),
      ),
    ],
  ),
);
```

**APRÈS**:
```dart
showCupertinoDialog(
  context: context,
  builder: (context) => CupertinoAlertDialog(
    title: Text(
      'Confirmation',
      style: IOSTheme.headline,
    ),
    content: Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        'Êtes-vous sûr de vouloir continuer ?',
        style: IOSTheme.subheadline,
      ),
    ),
    actions: [
      CupertinoDialogAction(
        isDefaultAction: false,
        onPressed: () {
          HapticHelper.light();
          Navigator.pop(context);
        },
        child: Text('Annuler'),
      ),
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          HapticHelper.medium();
          Navigator.pop(context);
          _confirm();
        },
        child: Text('OK'),
      ),
    ],
  ),
);
```

### 5.2 Action Sheet iOS

**AVANT**:
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Column(
    children: [
      ListTile(
        title: Text('Option 1'),
        onTap: () => _option1(),
      ),
      ListTile(
        title: Text('Option 2'),
        onTap: () => _option2(),
      ),
    ],
  ),
);
```

**APRÈS**:
```dart
showCupertinoModalPopup(
  context: context,
  builder: (context) => CupertinoActionSheet(
    title: Text(
      'Choisissez une option',
      style: IOSTheme.subheadline,
    ),
    message: Text(
      'Description supplémentaire si nécessaire',
      style: IOSTheme.caption1,
    ),
    actions: [
      CupertinoActionSheetAction(
        onPressed: () {
          HapticHelper.light();
          Navigator.pop(context);
          _option1();
        },
        child: Text('Option 1'),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          HapticHelper.light();
          Navigator.pop(context);
          _option2();
        },
        child: Text('Option 2'),
      ),
      CupertinoActionSheetAction(
        isDestructiveAction: true,
        onPressed: () {
          HapticHelper.heavy();
          Navigator.pop(context);
          _deleteAction();
        },
        child: Text('Supprimer'),
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      isDefaultAction: true,
      onPressed: () {
        HapticHelper.light();
        Navigator.pop(context);
      },
      child: Text('Annuler'),
    ),
  ),
);
```

### 5.3 Modal Full Screen iOS

**AVANT**:
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => _InfoPage(),
  ),
);
```

**APRÈS**:
```dart
Navigator.of(context).push(
  CupertinoPageRoute(
    builder: (context) => _InfoPage(),
    fullscreenDialog: true, // Important pour modal fullscreen
  ),
);
```

---

## 6. LISTES & CARTES

### 6.1 ListTile iOS

**Fichier**: `lib/src/features/parts/presentation/pages/particulier/home_page.dart` (ligne 842-854)

**AVANT**:
```dart
ListTile(
  dense: true,
  title: Text(suggestion),
  onTap: () => _selectSuggestion(suggestion),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
)
```

**APRÈS**:
```dart
CupertinoListTile(
  title: Text(
    suggestion,
    style: IOSTheme.body,
  ),
  onTap: () {
    HapticHelper.light();
    _selectSuggestion(suggestion);
  },
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
)
```

### 6.2 Card iOS avec Tap Animation

**Fichier**: `lib/src/features/parts/presentation/pages/particulier/home_page.dart` (ligne 949-1015)

**AVANT**:
```dart
Material(
  color: selected ? _bgSelected : Colors.white,
  borderRadius: BorderRadius.circular(_radius),
  child: InkWell(
    borderRadius: BorderRadius.circular(_radius),
    onTap: onTap,
    child: Container(/* ... */),
  ),
)
```

**APRÈS**:
```dart
class IOSTapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool selected;

  const IOSTapCard({
    required this.child,
    required this.onTap,
    this.selected = false,
  });

  @override
  State<IOSTapCard> createState() => _IOSTapCardState();
}

class _IOSTapCardState extends State<IOSTapCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticHelper.light();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.selected
              ? CupertinoColors.systemBlue.withOpacity(0.1)
              : CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.selected
                ? CupertinoColors.systemBlue
                : CupertinoColors.separator.resolveFrom(context),
              width: widget.selected ? 2 : 0.5,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Utilisation:
IOSTapCard(
  selected: selected,
  onTap: onTap,
  child: Column(/* contenu */),
)
```

### 6.3 Liste avec Séparateurs iOS

**AVANT**:
```dart
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.grey200),
  itemBuilder: (context, index) => ListTile(/* ... */),
)
```

**APRÈS**:
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Column(
      children: [
        CupertinoListTile(/* ... */),
        if (index < items.length - 1)
          Container(
            height: 0.5,
            margin: EdgeInsets.only(left: 16),
            color: CupertinoColors.separator.resolveFrom(context),
          ),
      ],
    );
  },
)
```

---

## 7. FEEDBACK UTILISATEUR

### 7.1 Toast iOS (Notification temporaire)

**Créer**: `lib/src/core/services/ios_toast_service.dart`

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../utils/haptic_helper.dart';
import '../theme/ios_theme.dart';

class IOSToastService {
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _IOSToast(
        message: message,
        icon: icon ?? (isError ? CupertinoIcons.xmark_circle_fill : CupertinoIcons.checkmark_circle_fill),
        backgroundColor: backgroundColor ?? (isError
          ? CupertinoColors.systemRed
          : CupertinoColors.systemGreen),
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Haptic feedback
    if (isError) {
      HapticHelper.error();
    } else {
      HapticHelper.success();
    }

    // Auto-dismiss
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void success(BuildContext context, String message) {
    show(context, message, isError: false);
  }

  static void error(BuildContext context, String message) {
    show(context, message, isError: true);
  }
}

class _IOSToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onDismiss;

  const _IOSToast({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.onDismiss,
  });

  @override
  State<_IOSToast> createState() => _IOSToastState();
}

class _IOSToastState extends State<_IOSToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: CupertinoColors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: IOSTheme.callout.copyWith(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Utilisation:
IOSToastService.success(context, 'Demande créée avec succès');
IOSToastService.error(context, 'Une erreur est survenue');
```

### 7.2 Loading Indicator iOS

**AVANT**:
```dart
CircularProgressIndicator(
  strokeWidth: 2,
  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
)
```

**APRÈS**:
```dart
CupertinoActivityIndicator(
  radius: 10,
  color: CupertinoColors.white,
)
```

### 7.3 Pull-to-Refresh iOS

**AVANT**:
```dart
RefreshIndicator(
  onRefresh: _refreshData,
  child: ListView(/* ... */),
)
```

**APRÈS**:
```dart
CustomScrollView(
  physics: BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  ),
  slivers: [
    CupertinoSliverRefreshControl(
      onRefresh: () async {
        HapticHelper.refresh();
        await _refreshData();
      },
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => /* item */,
        childCount: items.length,
      ),
    ),
  ],
)
```

---

## 8. WIDGETS RÉUTILISABLES

### 8.1 IOSButton

**Créer**: `lib/src/shared/presentation/widgets/ios_button.dart`

```dart
import 'package:flutter/cupertino.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../core/theme/ios_theme.dart';

enum IOSButtonType { filled, plain }
enum IOSButtonSize { large, medium, small }

class IOSButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IOSButtonType type;
  final IOSButtonSize size;
  final bool isDestructive;
  final bool isLoading;
  final IconData? icon;

  const IOSButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = IOSButtonType.filled,
    this.size = IOSButtonSize.large,
    this.isDestructive = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final padding = _getPadding();
    final textStyle = _getTextStyle();
    final color = isDestructive
      ? CupertinoColors.systemRed
      : IOSTheme.primaryBlue;

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          CupertinoActivityIndicator(
            color: type == IOSButtonType.filled ? CupertinoColors.white : color,
          )
        else ...[
          if (icon != null) ...[
            Icon(
              icon,
              size: _getIconSize(),
              color: type == IOSButtonType.filled ? CupertinoColors.white : color,
            ),
            SizedBox(width: 8),
          ],
          Text(
            text,
            style: textStyle.copyWith(
              color: type == IOSButtonType.filled ? CupertinoColors.white : color,
            ),
          ),
        ],
      ],
    );

    if (type == IOSButtonType.filled) {
      return CupertinoButton.filled(
        onPressed: isLoading ? null : () {
          HapticHelper.medium();
          onPressed?.call();
        },
        padding: padding,
        borderRadius: BorderRadius.circular(10),
        disabledColor: color.withOpacity(0.5),
        child: child,
      );
    }

    return CupertinoButton(
      onPressed: isLoading ? null : () {
        HapticHelper.light();
        onPressed?.call();
      },
      padding: padding,
      child: child,
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case IOSButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case IOSButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case IOSButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case IOSButtonSize.large:
        return IOSTheme.headline;
      case IOSButtonSize.medium:
        return IOSTheme.callout.copyWith(fontWeight: FontWeight.w600);
      case IOSButtonSize.small:
        return IOSTheme.subheadline.copyWith(fontWeight: FontWeight.w600);
    }
  }

  double _getIconSize() {
    switch (size) {
      case IOSButtonSize.large: return 20;
      case IOSButtonSize.medium: return 18;
      case IOSButtonSize.small: return 16;
    }
  }
}

// Utilisation:
IOSButton(
  text: 'Se connecter',
  icon: CupertinoIcons.arrow_right,
  onPressed: _handleLogin,
  isLoading: isLoading,
)

IOSButton(
  text: 'Annuler',
  type: IOSButtonType.plain,
  onPressed: () => Navigator.pop(context),
)

IOSButton(
  text: 'Supprimer',
  type: IOSButtonType.plain,
  isDestructive: true,
  onPressed: _delete,
)
```

### 8.2 IOSTextField

**Créer**: `lib/src/shared/presentation/widgets/ios_text_field.dart`

```dart
import 'package:flutter/cupertino.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../core/theme/ios_theme.dart';

class IOSTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final bool enabled;

  const IOSTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<IOSTextField> createState() => _IOSTextFieldState();
}

class _IOSTextFieldState extends State<IOSTextField> {
  String? _localError;

  @override
  Widget build(BuildContext context) {
    final displayError = widget.errorText ?? _localError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: IOSTheme.subheadline.copyWith(
              color: IOSTheme.label.resolveFrom(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
        ],
        CupertinoTextField(
          controller: widget.controller,
          placeholder: widget.placeholder,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          prefix: widget.prefix != null
            ? Padding(
                padding: EdgeInsets.only(left: 8),
                child: widget.prefix,
              )
            : null,
          suffix: widget.suffix != null
            ? Padding(
                padding: EdgeInsets.only(right: 8),
                child: widget.suffix,
              )
            : null,
          padding: EdgeInsets.all(16),
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          decoration: BoxDecoration(
            color: widget.enabled
              ? CupertinoColors.systemGrey6.resolveFrom(context)
              : CupertinoColors.systemGrey5.resolveFrom(context),
            borderRadius: BorderRadius.circular(10),
            border: displayError != null
              ? Border.all(
                  color: CupertinoColors.systemRed,
                  width: 1,
                )
              : null,
          ),
          onTap: () => HapticHelper.light(),
          onChanged: (value) {
            if (widget.validator != null) {
              setState(() {
                _localError = widget.validator!(value);
              });
            }
            widget.onChanged?.call(value);
          },
          onEditingComplete: widget.onEditingComplete,
          style: IOSTheme.body.copyWith(
            color: IOSTheme.label.resolveFrom(context),
          ),
          placeholderStyle: IOSTheme.body.copyWith(
            color: CupertinoColors.placeholderText,
          ),
        ),
        if (displayError != null) ...[
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_circle_fill,
                  size: 14,
                  color: CupertinoColors.systemRed,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    displayError,
                    style: IOSTheme.footnote.copyWith(
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// Utilisation:
IOSTextField(
  controller: _emailController,
  label: 'Email',
  placeholder: 'votre@email.com',
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre email';
    }
    if (!value.contains('@')) {
      return 'Email non valide';
    }
    return null;
  },
)
```

---

## 9. EXEMPLES PAR FICHIER

### 9.1 seller_login_page.dart

**Migration complète**:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/seller_auth_controller.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../../core/services/ios_toast_service.dart';
import '../../../../shared/presentation/widgets/ios_button.dart';
import '../../../../shared/presentation/widgets/ios_text_field.dart';

class SellerLoginPage extends ConsumerStatefulWidget {
  const SellerLoginPage({super.key});

  @override
  ConsumerState<SellerLoginPage> createState() => _SellerLoginPageState();
}

class _SellerLoginPageState extends ConsumerState<SellerLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email non valide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(sellerAuthControllerProvider);

    ref.listen<SellerAuthState>(sellerAuthControllerProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (seller) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/seller/home');
            }
          });
        },
        unauthenticated: () {},
        error: (message) {
          if (context.mounted) {
            IOSToastService.error(context, message);
          }
        },
      );
    });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        border: null,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            HapticHelper.light();
            context.pop();
          },
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),

              // Logo et titre
              Center(
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.building_2_filled,
                      color: IOSTheme.primaryBlue,
                      size: 80,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Espace Vendeur',
                      style: IOSTheme.largeTitle,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Connectez-vous à votre compte vendeur',
                      style: IOSTheme.subheadline.copyWith(
                        color: IOSTheme.secondaryLabel.resolveFrom(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 48),

              // Email
              IOSTextField(
                controller: _emailController,
                label: 'Email',
                placeholder: 'votre@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                prefix: Icon(
                  CupertinoIcons.mail,
                  color: IOSTheme.secondaryLabel.resolveFrom(context),
                ),
              ),

              SizedBox(height: 24),

              // Mot de passe
              IOSTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                placeholder: 'Votre mot de passe',
                obscureText: _obscurePassword,
                validator: _validatePassword,
                prefix: Icon(
                  CupertinoIcons.lock,
                  color: IOSTheme.secondaryLabel.resolveFrom(context),
                ),
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticHelper.light();
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Icon(
                    _obscurePassword
                      ? CupertinoIcons.eye_slash
                      : CupertinoIcons.eye,
                    color: IOSTheme.secondaryLabel.resolveFrom(context),
                    size: 20,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Mot de passe oublié
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticHelper.light();
                    context.push('/seller/forgot-password');
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: IOSTheme.callout.copyWith(
                      color: CupertinoColors.systemOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Bouton de connexion
              SizedBox(
                width: double.infinity,
                child: IOSButton(
                  text: 'Se connecter',
                  icon: CupertinoIcons.arrow_right,
                  onPressed: _handleLogin,
                  isLoading: authState.isLoading,
                ),
              ),

              SizedBox(height: 32),

              // Lien vers inscription
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nouveau vendeur ? ',
                      style: IOSTheme.callout.copyWith(
                        color: IOSTheme.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () {
                        HapticHelper.light();
                        context.push('/seller/register');
                      },
                      child: Text(
                        'Créer un compte',
                        style: IOSTheme.callout.copyWith(
                          color: IOSTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    // Validation locale
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);

    if (emailError != null || passwordError != null) {
      HapticHelper.error();
      IOSToastService.error(
        context,
        'Veuillez corriger les erreurs',
      );
      return;
    }

    final authController = ref.read(sellerAuthControllerProvider.notifier);

    await authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}
```

### 9.2 home_page.dart - Extraits clés

**Scaffold → CupertinoPageScaffold**:
```dart
@override
Widget build(BuildContext context) {
  return CupertinoPageScaffold(
    backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
    child: CustomScrollView(
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(child: const AppHeader()),

        // Contenu
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  'Quel type de pièce recherchez-vous ?',
                  style: IOSTheme.title2,
                ),
                SizedBox(height: 20),

                // Cartes de sélection
                Row(
                  children: [
                    Expanded(
                      child: IOSTapCard(
                        selected: _selectedType == 'engine',
                        onTap: () => setState(() => _selectedType = 'engine'),
                        child: _buildTypeCardContent(
                          icon: CupertinoIcons.gear_alt_fill,
                          title: 'Pièces moteur',
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: IOSTapCard(
                        selected: _selectedType == 'body',
                        onTap: () => setState(() => _selectedType = 'body'),
                        child: _buildTypeCardContent(
                          icon: CupertinoIcons.car_fill,
                          title: 'Pièces carrosserie\n/ intérieures',
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28),

                // Widget de recherche
                if (!_isManualMode) LicensePlateInput(/* ... */),

                // Champs manuels
                if (_isManualMode) ..._buildManualFields(),

                // Section description
                if (_canContinue()) ..._buildDescriptionSection(),

                // Bouton continuer
                if (!_showDescription) ...[
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: IOSButton(
                      text: 'Continuer',
                      onPressed: _canContinue() ? _continueToDescription : null,
                    ),
                  ),
                ],

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

## CONCLUSION

Ce guide fournit tous les exemples nécessaires pour migrer l'application vers iOS native. Chaque conversion suit les mêmes principes:

1. **Remplacer Material par Cupertino**
2. **Ajouter HapticFeedback**
3. **Utiliser SF Pro Text/Display**
4. **Respecter les specs iOS** (10pt border radius, couleurs système, etc.)
5. **Implémenter les animations iOS** (scale au tap, bouncing scroll)

**Ordre de priorité**:
1. HapticHelper partout (impact immédiat)
2. Navigation (AppBar → CupertinoNavigationBar)
3. Formulaires (TextField → CupertinoTextField, boutons)
4. Dialogs & Modals
5. Listes & Cartes
6. Polish final (animations, typographie, dark mode)

**Estimation**: 15-20 jours avec cette documentation complète.
