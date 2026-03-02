# Pointa Mobile - Memo Architecture (S1-S2)

## 1) But de ce memo

Ce document explique l'architecture mobile actuelle en version courte:

- quoi se trouve ou
- qui appelle qui
- ou interviennent `go_router` et `flutter_riverpod`
- comment on passera du mock vers le backend Django sans casser l'app

## 2) Vue rapide des couches

```text
main.dart
  -> ProviderScope (Riverpod)
  -> PointaApp
      -> MaterialApp.router
          -> appRouterProvider (go_router)
              -> LoginPage / HomePage / AttendancePage / HistoryPage / SummaryPage

LoginPage
  -> AuthController (Riverpod Notifier)
      -> AuthRepository (contrat domain)
          -> MockAuthRepository (data mock, remplaceable plus tard)
```

## 3) Arborescence utile

```text
lib/
  main.dart
  app/
    pointa_app.dart
    router/
      app_router.dart
  core/
    config/
      data_mode.dart
    theme/
      app_colors.dart
      app_radius.dart
      app_theme.dart
      app_spacing.dart
      app_typography.dart
    widgets/
      app_async_state.dart
      app_card.dart
      app_primary_button.dart
      app_text_field.dart
  features/
    auth/
      presentation/pages/login_page.dart
      application/auth_controller.dart
      application/auth_state.dart
      domain/repositories/auth_repository.dart
      domain/models/user_session.dart
      domain/exceptions/auth_exception.dart
      data/repositories/mock_auth_repository.dart
    home/
      presentation/pages/home_page.dart
    attendance/
      application/attendance_providers.dart
      presentation/pages/attendance_page.dart
      presentation/pages/history_page.dart
      presentation/pages/summary_page.dart
      presentation/widgets/attendance_record_tile.dart
      presentation/widgets/summary_metric_card.dart
      domain/models/attendance_record.dart
      domain/models/attendance_status.dart
      domain/models/attendance_summary.dart
      domain/repositories/attendance_repository.dart
      data/datasources/attendance_local_data_source.dart
      data/datasources/attendance_mock_data_source.dart
      data/datasources/attendance_remote_data_source.dart
      data/repositories/attendance_repository_impl.dart
```

## 4) Role de chaque dossier cle

- `app/`: composition globale de l'application.
  `pointa_app.dart` monte MaterialApp et injecte le router.
- `app/router/`: declaration des routes et regles de redirection.
- `core/`: briques transverses (theme, spacing, outils partages).
- `core/theme/`: tokens visuels globaux (couleurs, rayons, typo, theme Flutter).
- `core/widgets/`: composants UI reutilisables (carte, bouton, champ texte, etats async).
- `core/config/`: configuration transversale (ex: mode de source de donnees).
- `features/<feature>/presentation`: ecrans/widgets UI.
- `features/<feature>/application`: logique d'etat et cas d'usage.
- `features/<feature>/domain`: contrats metier (interfaces/modeles).
- `features/<feature>/data`: implementation technique (mock/API/local).

## 5) Ou intervient go_router

Fichier: `lib/app/router/app_router.dart`

Ce que `go_router` gere ici:

- declaration des routes (`/login`, `/home`, `/attendance`, `/attendance/history`, `/attendance/summary`)
- route initiale (`/login`)
- guard d'authentification:
  - non connecte + route protegee -> redirection vers `/login`
  - connecte + route `/login` -> redirection vers `/home`
- navigation explicite depuis les pages (`context.go(...)`)

## 6) Ou intervient Riverpod

Points d'entree:

- `main.dart`: `ProviderScope` active le conteneur de providers
- `auth_controller.dart`: provider d'etat `NotifierProvider<AuthController, AuthState>`
- `mock_auth_repository.dart`: provider de repository `authRepositoryProvider`

Ce que Riverpod apporte:

- etat global auth centralise (status, session, loading, erreur)
- injection propre des dependances (controller -> repository)
- remplacement simple du mock par une implementation API reelle

## 7) Cycle de connexion actuel (mock)

```text
Utilisateur saisit email+mot de passe dans LoginPage
  -> authController.signInWithEmail(...)
      -> MockAuthRepository.signInWithEmail(...)
      -> AuthState.status = authenticated
          -> app_router lit le nouvel etat
              -> redirection automatique vers /home
```

## 8) Comment on branchera le backend Django plus tard

On garde le contrat `AuthRepository` et on change seulement l'implementation:

- aujourd'hui: `MockAuthRepository`
- demain: `DjangoAuthRepository` (HTTP vers DRF)

Le reste reste stable:

- `LoginPage` ne change pas de logique metier
- `AuthController` garde le meme usage
- `go_router` continue de se baser sur `AuthState.status`

## 8.1) Strategie de donnees attendance (MOB-S2-01)

La feature attendance suit une abstraction source de donnees unique:

- `DataMode.mock`: donnees simulees pour avancer sans backend
- `DataMode.local`: donnees locales (cache/memoire)
- `DataMode.remote`: branchement backend Django (placeholder deja present)

Providers Riverpod cle:

- `attendanceRepositoryProvider`
- `attendanceHistoryProvider`
- `attendanceSummaryProvider`
- `attendanceStatusProvider`
- `refreshAttendanceReadModels(...)` (helper de refresh global)

Principe:

- l'UI consomme les providers
- le repository choisit la source selon `dataModeProvider`
- quand le backend est pret, on remplace la logique `remote` sans casser les pages
- les ecrans `AttendancePage` et `HistoryPage` lisent la meme source d'historique
- l'ecran `SummaryPage` consomme `attendanceSummaryProvider` pour le recap metier

## 8.2) Strategie UI des etats async (MOB-S2-04)

Les etats asynchrones sont unifies via `core/widgets/app_async_state.dart`:

- `AppLoadingState`: chargement standardise
- `AppErrorState`: message d'erreur + bouton `Reessayer`
- `AppEmptyState`: etat vide avec message explicite

Principe de retry:

- chaque ecran invalide le provider concerne via `ref.invalidate(...)`
- apres une action de pointage, `refreshAttendanceReadModels(ref)` rafraichit statut, historique et recap
- cette approche permet de tester les ecrans en mode mock sans attendre les endpoints backend

## 9) Regles de travail sur cette base

- toute nouvelle feature suit `presentation/application/domain/data`
- toute UI nouvelle passe par les composants `core/widgets` avant ajout d'un nouveau widget maison
- tout style visuel global passe par `core/theme` (pas de magic numbers disperses)
- tout ecran doit etre testable en mode mock avant integration API reelle
- toute integration endpoint est suivie d'un retest local + test manuel
- si endpoint backend bloque: ouvrir un ticket clair avec payload, attendu, observe

## 10) Fichiers techniques les plus critiques a connaitre

- `lib/main.dart`
- `lib/app/pointa_app.dart`
- `lib/app/router/app_router.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/widgets/app_async_state.dart`
- `lib/core/widgets/app_primary_button.dart`
- `lib/features/auth/application/auth_controller.dart`
- `lib/features/auth/data/repositories/mock_auth_repository.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/attendance/application/attendance_providers.dart`
- `lib/features/attendance/data/repositories/attendance_repository_impl.dart`
