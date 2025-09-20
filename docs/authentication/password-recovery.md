# 🔑 Documentation Système de Récupération de Mot de Passe

## Vue d'ensemble

Le système de récupération de mot de passe permet aux vendeurs de réinitialiser leur accès en cas d'oubli. Utilise le système de récupération intégré de **Supabase Auth** avec envoi d'email automatisé.

## 🎯 Fonctionnalités

- **Réinitialisation par email** : Lien sécurisé envoyé automatiquement
- **Token temporaire** : Validité limitée dans le temps
- **Interface intuitive** : Formulaire simple et guidé
- **Sécurité renforcée** : Validation multi-niveaux

## 🔄 Flux de Récupération

### Processus Complet

```mermaid
graph TD
    A[Page Connexion] --> B[Lien "Mot de passe oublié"]
    B --> C[Page Récupération]
    C --> D[Saisie Email]
    D --> E[Validation Email]
    E --> F{Email Valide?}
    F -->|Non| G[Afficher Erreur]
    F -->|Oui| H[Envoyer Email Reset]
    H --> I[Email Reçu]
    I --> J[Clic Lien Reset]
    J --> K[Page Nouveau MDP]
    K --> L[Saisie Nouveau MDP]
    L --> M[Mise à jour]
    M --> N[Connexion Auto]
    G --> D
```

## 📱 Implémentation Frontend

### Page Mot de Passe Oublié

```dart
// seller_forgot_password_page.dart
class SellerForgotPasswordPage extends ConsumerStatefulWidget {
  @override
  _SellerForgotPasswordPageState createState() => _SellerForgotPasswordPageState();
}

class _SellerForgotPasswordPageState extends ConsumerState<SellerForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Récupération de mot de passe')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Instruction
            Text('Entrez votre email pour recevoir un lien de réinitialisation'),

            // Champ Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'votre@email.com',
              ),
            ),

            // Bouton Envoyer
            ElevatedButton(
              onPressed: _handlePasswordReset,
              child: Text('Envoyer le lien'),
            ),
          ],
        ),
      ),
    );
  }

  // Gestionnaire d'envoi
  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState!.validate()) {
      await ref
        .read(sellerAuthControllerProvider.notifier)
        .forgotPassword(_emailController.text.trim());
    }
  }
}
```

## 🔧 Implémentation Backend

### Controller

```dart
// seller_auth_controller.dart
Future<void> forgotPassword(String email) async {
  state = const SellerAuthState.loading();

  final params = SellerForgotPasswordParams(email: email);
  final result = await _sellerForgotPassword(params);

  result.fold(
    (failure) => state = SellerAuthState.error(_mapFailureToMessage(failure)),
    (_) {
      // Succès - retour à l'état non authentifié
      state = const SellerAuthState.unauthenticated();
      // Message de succès peut être affiché via notification
    },
  );
}
```

### Use Case

```dart
// seller_forgot_password.dart
class SellerForgotPassword implements UseCase<void, SellerForgotPasswordParams> {
  final SellerAuthRepository repository;

  SellerForgotPassword(this.repository);

  @override
  Future<Either<Failure, void>> call(SellerForgotPasswordParams params) async {
    // Validation email
    if (!_isValidEmail(params.email)) {
      return Left(ValidationFailure('Email invalide'));
    }

    // Appel repository
    return await repository.forgotPassword(params.email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class SellerForgotPasswordParams extends Equatable {
  final String email;

  const SellerForgotPasswordParams({required this.email});

  @override
  List<Object> get props => [email];
}
```

### Repository Implementation

```dart
// seller_auth_repository_impl.dart
@override
Future<Either<Failure, void>> forgotPassword(String email) async {
  try {
    await _remoteDataSource.sendPasswordResetEmail(email);
    return const Right(null);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on NetworkException {
    return Left(NetworkFailure('Vérifiez votre connexion internet'));
  }
}
```

### Data Source

```dart
// seller_auth_remote_datasource.dart
Future<void> sendPasswordResetEmail(String email) async {
  try {
    // Configuration du redirect URL
    final redirectTo = '${AppConstants.appUrl}/reset-password';

    // Envoi email via Supabase
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  } catch (e) {
    throw ServerException('Impossible d\'envoyer l\'email de réinitialisation');
  }
}
```

## 📧 Configuration Email

### Template Email Supabase

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    .container {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
    }
    .header {
      text-align: center;
      padding: 20px 0;
    }
    .button {
      display: inline-block;
      padding: 12px 24px;
      background-color: #007AFF;
      color: white;
      text-decoration: none;
      border-radius: 8px;
      margin: 20px 0;
    }
    .footer {
      margin-top: 40px;
      padding-top: 20px;
      border-top: 1px solid #e0e0e0;
      font-size: 12px;
      color: #666;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Réinitialisation de mot de passe</h1>
    </div>

    <p>Bonjour,</p>

    <p>Vous avez demandé à réinitialiser votre mot de passe pour votre compte vendeur sur Pièces d'Occasion.</p>

    <p>Cliquez sur le bouton ci-dessous pour créer un nouveau mot de passe :</p>

    <div style="text-align: center;">
      <a href="{{ .ConfirmationURL }}" class="button">Réinitialiser mon mot de passe</a>
    </div>

    <p><small>Ce lien expirera dans 1 heure.</small></p>

    <p>Si vous n'avez pas demandé cette réinitialisation, vous pouvez ignorer cet email.</p>

    <div class="footer">
      <p>© 2024 Pièces d'Occasion - Tous droits réservés</p>
      <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
    </div>
  </div>
</body>
</html>
```

## 🔐 Sécurité

### Mesures de Protection

1. **Rate Limiting**
   ```dart
   // Configuration Supabase
   - Max 5 tentatives par heure par IP
   - Max 3 tentatives par email par heure
   ```

2. **Token Temporaire**
   ```dart
   // Durée de validité
   - Token valide : 1 heure
   - Usage unique
   - Révocation après utilisation
   ```

3. **Validation Email**
   ```dart
   // Vérifications
   - Format email valide
   - Email existe dans la base
   - Compte non bloqué
   ```

4. **Audit Trail**
   ```dart
   // Logs de sécurité
   - Tentative de reset
   - IP source
   - Timestamp
   - Succès/Échec
   ```

## 🔄 Flux de Réinitialisation

### Page Reset Password (après clic sur lien)

```dart
class ResetPasswordPage extends ConsumerStatefulWidget {
  final String token; // Récupéré depuis l'URL

  const ResetPasswordPage({required this.token});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _handlePasswordUpdate() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Mise à jour via Supabase
        await supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );

        // Redirection vers login
        context.go('/seller/login');

        // Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mot de passe réinitialisé avec succès')),
        );
      } catch (e) {
        // Gestion erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la réinitialisation')),
        );
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Minimum 6 caractères';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Doit contenir au moins un chiffre';
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
}
```

## 📊 Gestion des États

### États du Processus

| État | Description | Action UI |
|------|-------------|-----------|
| `Initial` | Formulaire vide | Afficher formulaire |
| `Loading` | Envoi en cours | Spinner + désactiver bouton |
| `Success` | Email envoyé | Message succès + redirection |
| `Error` | Échec envoi | Message erreur + retry |

### Messages Utilisateur

```dart
class PasswordResetMessages {
  static const emailSent = 'Un email de réinitialisation a été envoyé';
  static const emailNotFound = 'Aucun compte associé à cet email';
  static const tooManyAttempts = 'Trop de tentatives, réessayez plus tard';
  static const networkError = 'Vérifiez votre connexion internet';
  static const resetSuccess = 'Mot de passe réinitialisé avec succès';
  static const tokenExpired = 'Le lien a expiré, demandez-en un nouveau';
}
```

## 🧪 Tests

### Test Envoi Email

```dart
test('should send password reset email successfully', () async {
  // Arrange
  const email = 'test@example.com';
  when(mockSupabase.auth.resetPasswordForEmail(email))
    .thenAnswer((_) async => {});

  // Act
  final result = await useCase(SellerForgotPasswordParams(email: email));

  // Assert
  expect(result.isRight(), true);
  verify(mockSupabase.auth.resetPasswordForEmail(email)).called(1);
});
```

### Test Validation Email

```dart
test('should return ValidationFailure for invalid email', () async {
  // Arrange
  const invalidEmail = 'not-an-email';

  // Act
  final result = await useCase(SellerForgotPasswordParams(email: invalidEmail));

  // Assert
  expect(result.isLeft(), true);
  result.fold(
    (failure) => expect(failure, isA<ValidationFailure>()),
    (_) => fail('Should have failed'),
  );
});
```

## 📋 Checklist Implementation

- [x] Page formulaire email
- [x] Validation email côté client
- [x] Use case forgot password
- [x] Repository implementation
- [x] Intégration Supabase
- [x] Template email personnalisé
- [x] Page reset password
- [x] Validation nouveau mot de passe
- [x] Rate limiting
- [x] Gestion erreurs
- [x] Tests unitaires
- [x] Tests d'intégration

## 🔧 Configuration Supabase

### Auth Settings

```javascript
// supabase/config.toml
[auth]
site_url = "https://votre-app.com"
redirect_urls = ["https://votre-app.com/reset-password"]

[auth.email]
enable_signup = true
enable_confirmations = true
template.reset_password = "./email-templates/reset-password.html"

[auth.rate_limits]
email_reset_password.max_requests = 5
email_reset_password.time_window = 3600
```

## 📝 Notes Importantes

1. **Sécurité** : Ne jamais logger les tokens de reset
2. **UX** : Toujours afficher un message de succès même si l'email n'existe pas
3. **Performance** : Implémenter un délai artificiel pour éviter l'énumération
4. **Mobile** : Deep linking pour ouvrir l'app depuis l'email
5. **Monitoring** : Surveiller les tentatives abusives