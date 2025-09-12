# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Pièces d'Occasion" is a Flutter mobile application for used car parts sales. Built with Clean Architecture, Riverpod state management, and Supabase backend. Designed to support 100,000+ users with optimal performance.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app in debug mode
- `flutter run --release` - Run the app in release mode
- `flutter hot-reload` - Apply code changes without restarting (press 'r' in terminal)
- `flutter hot-restart` - Restart the app (press 'R' in terminal)

### Code Generation
- `dart run build_runner build` - Generate code (freezed, json_serializable, riverpod)
- `dart run build_runner build --delete-conflicting-outputs` - Regenerate all code
- `dart run build_runner watch` - Watch and regenerate code on changes

### Testing and Quality
- `flutter test` - Run all tests
- `flutter test test/src/core/services/` - Run service tests only
- `flutter test test/src/features/` - Run feature tests only
- `flutter analyze` - Run static analysis (linting)
- `dart format .` - Format all Dart code
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Automated Testing Strategy
- **Unit Tests**: All services and controllers must have comprehensive tests
- **Widget Tests**: Critical UI components should have interaction tests
- **Integration Tests**: End-to-end user flows for core features
- **Test Coverage**: Aim for >80% coverage on business logic
- **CI/CD**: Tests run automatically on code changes

### Build Commands
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web app

## Architecture

### Clean Architecture Structure
```
lib/src/
├── core/                    # Shared core functionality
│   ├── constants/          # App constants and configuration
│   ├── theme/             # Design system and theming
│   ├── network/           # Network configuration (Dio, Supabase)
│   ├── errors/            # Custom failure classes
│   ├── navigation/        # GoRouter configuration
│   └── providers/         # Core Riverpod providers
├── features/              # Feature-based modules
│   ├── auth/             # Authentication feature
│   │   ├── data/         # Data layer (models, repositories, datasources)
│   │   ├── domain/       # Domain layer (entities, repositories, use cases)
│   │   └── presentation/ # Presentation layer (pages, widgets, controllers)
│   └── parts/            # Car parts feature (similar structure)
└── shared/               # Shared UI components
    └── presentation/     # Reusable widgets
```

### Key Technologies
- **State Management**: Riverpod with providers and state notifiers
- **Backend**: Supabase for database, auth, and real-time features  
- **Navigation**: GoRouter with declarative routing
- **Networking**: Dio HTTP client with interceptors
- **Architecture**: Clean Architecture with clear separation of concerns

### Design System
- **Primary Color**: #007AFF (iOS blue)
- **Theme**: iOS-inspired design with modern Material components
- **Typography**: System fonts with consistent hierarchy
- **Components**: Reusable, accessible UI components

### State Management Patterns
- Use `StateNotifierProvider` for complex state logic
- Use `Provider` for dependency injection
- Use `FutureProvider` for async data fetching
- Follow Riverpod best practices from Code with Andrea

### Error Handling
- Custom `Failure` classes for different error types
- `Either<Failure, Success>` pattern for error handling
- Centralized error management with user-friendly messages

## Important Notes

- **Configuration**: Update Supabase URL and keys in `app_constants.dart`
- **Code Generation**: Run build_runner after adding @freezed or @JsonSerializable annotations
- **Navigation**: Use `context.go()` for navigation, avoid `Navigator.push`
- **Async**: Always handle loading/error states in UI
- **Testing**: Write tests for use cases, repositories, and controllers
- **App Launch**: NEVER use `flutter run` commands - only the user should launch the app

## Development Guidelines

### Code Style
- Follow Flutter/Dart style guide
- Use const constructors where possible
- Prefer composition over inheritance
- Write descriptive variable and function names

### Performance
- Use const widgets to prevent unnecessary rebuilds
- Implement proper disposal of controllers and streams
- Use Riverpod's caching for expensive operations
- Optimize images and assets for mobile

### Security
- Never commit API keys or sensitive data
- Use environment variables for configuration
- Implement proper input validation
- Follow Supabase security best practices

See `PROGRESS.md` for current development status and next steps.

## Claude Code Instructions

### Communication Rules
- **Language**: Always communicate ONLY in French
- **Role**: Act as a Senior Developer with expertise in Flutter, Dart, and Clean Architecture
- **Tone**: Professional, concise, and technical

### Git Workflow

#### Stratégie de Branches (Git Flow)
- **main**: Code en production uniquement
- **dev** (ou **develop**): Branche de développement et d'intégration
- **feature/**: Nouvelles fonctionnalités (ex: feature/messaging-system)
- **bugfix/**: Corrections de bugs non critiques (ex: bugfix/chat-scroll-issue)
- **hotfix/**: Corrections urgentes en production (ex: hotfix/security-patch)
- **release/**: Préparation des nouvelles versions

#### Règles de Création de Branches
- **TOUJOURS** créer une nouvelle branche pour TOUT nouveau travail
- **JAMAIS** commit directement sur main ou dev
- Nommage en anglais: `feature/[feature-name]` (minuscules, séparés par tirets)
- Création automatique des branches selon le type de travail:
  - `feature/` pour nouvelles fonctionnalités
  - `bugfix/` pour corrections de bugs
  - `hotfix/` pour corrections urgentes
- Workflow: feature → dev → main
- Hotfix: hotfix → main ET dev

#### Opérations Git Automatiques
- **Création de Branches**: Création et checkout automatique des branches
- **Commits**: Messages en FRANÇAIS (ex: "ajout: système de messagerie")
- **Push**: Push automatique vers la branche distante
- **Pull Requests**: Créer PR vers developpement quand terminé
- **Auteur**: Tous les commits signés "William Le Gall"
- **AUCUNE Référence Claude**: Jamais "Claude", "AI", "Assistant" dans les commits

#### Format des Messages de Commit (en français)
- **ajout:** Nouvelle fonctionnalité
- **correction:** Correction de bug
- **refactorisation:** Refactoring du code
- **docs:** Documentation
- **style:** Formatage, points-virgules manquants, etc.
- **test:** Ajout de tests
- **tâche:** Maintenance, configuration

### Development Behavior
- Act proactively as a senior developer would
- Make architectural decisions based on best practices
- Optimize code for production without being asked
- Anticipate potential issues and address them preemptively
- Focus on performance, scalability, and maintainability