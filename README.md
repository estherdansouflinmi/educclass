# EduClass — Classe Virtuelle Flutter

Application mobile Flutter de gestion de classes virtuelles, inspirée de Google Classroom.

## Stack technique

| Couche | Technologie |
|---|---|
| Mobile | Flutter 3 + Dart 3 |
| State management | Riverpod 2 (AsyncNotifier) |
| Navigation | GoRouter |
| Models | Freezed + json_serializable |
| Auth | Firebase Auth (email + Google) |
| Database | Cloud Firestore |
| Fichiers | Firebase Storage |
| Notifications | Firebase Cloud Messaging |
| Monitoring | Firebase Crashlytics |

## Prérequis

- Flutter SDK ≥ 3.5.0
- Dart SDK ≥ 3.5.0
- Compte Firebase avec projets `educclass-dev` et `educclass-prod`
- FlutterFire CLI : `dart pub global activate flutterfire_cli`

## Installation

### 1. Cloner et installer les dépendances

```bash
git clone <repo-url>
cd educclass
flutter pub get
```

### 2. Configurer Firebase

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurer le projet Firebase
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID

# Cela va générer automatiquement lib/firebase_options.dart
```

### 3. Générer le code Freezed

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configurer les règles Firebase

Dans la console Firebase, déployer :
- `firestore.rules` → Règles Firestore
- `storage.rules` → Règles Storage

```bash
# Avec Firebase CLI
firebase deploy --only firestore:rules
firebase deploy --only storage
```

### 5. Activer les méthodes d'authentification

Dans la console Firebase → Authentication → Sign-in method :
- Email/Mot de passe ✅
- Google ✅

### 6. Créer les index Firestore

Dans Firebase Console → Firestore → Index :

| Collection | Champs | Ordre |
|---|---|---|
| `classrooms/{id}/assignments` | `deadline` | ASC |
| `classrooms/{id}/submissions/{id}/submissions` | `submittedAt` | DESC |
| `classrooms/{id}/resources` | `createdAt` | DESC |
| `notifications` | `userId`, `createdAt` | DESC |

### 7. Lancer l'application

```bash
flutter run
```

## Structure du projet

```
lib/
  main.dart                  # Point d'entrée
  firebase_options.dart      # Config Firebase (généré)
  core/
    constants/               # Couleurs, chaînes, dimensions
    theme/                   # Thème Material 3
    router/                  # GoRouter + guards auth
    providers/               # Providers Firebase
    utils/                   # Utilitaires (dates, fichiers, validation)
    widgets/                 # Composants partagés (AppButton, AppTextField, etc.)
  features/
    auth/                    # Connexion, inscription, splash
    classroom/               # Créer/rejoindre/lister les classes
    resources/               # Ressources pédagogiques (PDF, liens)
    assignments/             # Devoirs + soumissions
    comments/                # Commentaires contextualisés
    notifications/           # Notifications push FCM
```

## Rôles utilisateur

| Rôle | Capabilities |
|---|---|
| **Enseignant** | Créer des classes, publier des ressources, créer des devoirs, voir les rendus, ajouter du feedback |
| **Étudiant** | Rejoindre des classes, consulter les ressources, soumettre des devoirs |

## Modèle de données Firestore

```
users/{uid}
classrooms/{classroomId}
  members/{userId}
  resources/{resourceId}
    comments/{commentId}
  assignments/{assignmentId}
    submissions/{userId}
    comments/{commentId}
notifications/{notificationId}
```

## Cloud Functions (à déployer)

Créez un projet `functions/` avec les triggers suivants :

```typescript
// Trigger: nouveau devoir → notification FCM aux étudiants
exports.onAssignmentCreate = functions.firestore
  .document('classrooms/{classroomId}/assignments/{assignmentId}')
  .onCreate(async (snap, context) => { /* ... */ });

// Trigger: nouvelle ressource → notification FCM aux étudiants
exports.onResourceCreate = functions.firestore
  .document('classrooms/{classroomId}/resources/{resourceId}')
  .onCreate(async (snap, context) => { /* ... */ });

// Trigger: nouveau rendu → notification FCM à l'enseignant
exports.onSubmissionCreate = functions.firestore
  .document('classrooms/{classroomId}/assignments/{assignmentId}/submissions/{studentId}')
  .onCreate(async (snap, context) => { /* ... */ });
```

## Commandes utiles

```bash
# Générer le code (freezed, json_serializable, riverpod_generator)
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer en mode watch (développement)
flutter pub run build_runner watch --delete-conflicting-outputs

# Build Android release
flutter build apk --release

# Build iOS release
flutter build ios --release

# Analyser le code
flutter analyze

# Lancer les tests
flutter test
```

## Variables d'environnement Firebase

TODO: Remplir `lib/firebase_options.dart` avec vos vraies clés après `flutterfire configure`.

Les valeurs nécessaires sont dans :
- Android : `android/app/google-services.json`
- iOS : `ios/Runner/GoogleService-Info.plist`

## Contribution

1. `git checkout -b feature/nom-de-la-feature`
2. Implémenter la feature
3. `flutter test` + `flutter analyze`
4. Pull Request

---

Développé avec Flutter + Firebase
