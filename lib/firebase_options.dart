// lib/firebase_options.dart
//
// ⚠️  CONFIGURATION FIREBASE — À COMPLÉTER
// =========================================
// Projet Firebase : educclass-dev
// ID du projet    : educclass-dev-f0673
// Numéro          : 217694014497
//
// ÉTAPES POUR FINALISER :
//   1. dart pub global activate flutterfire_cli
//   2. firebase login
//   3. flutterfire configure --project=educclass-dev-f0673
//      (ce fichier sera alors regénéré automatiquement avec les vraies clés)
//
// OU remplissez manuellement les TODO ci-dessous depuis :
//   Android : Firebase Console → Paramètres → google-services.json
//   iOS     : Firebase Console → Paramètres → GoogleService-Info.plist
// =========================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web non supporté pour l\'instant');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions non configuré pour: $defaultTargetPlatform',
        );
    }
  }

  // ⬇️ TODO : valeurs depuis google-services.json (Android)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO_ANDROID_API_KEY',
    appId: 'TODO_ANDROID_APP_ID',
    messagingSenderId: '217694014497',
    projectId: 'educclass-dev-f0673',
    storageBucket: 'educclass-dev-f0673.firebasestorage.app',
  );

  // ⬇️ TODO : valeurs depuis GoogleService-Info.plist (iOS)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO_IOS_API_KEY',
    appId: 'TODO_IOS_APP_ID',
    messagingSenderId: '217694014497',
    projectId: 'educclass-dev-f0673',
    storageBucket: 'educclass-dev-f0673.firebasestorage.app',
    iosBundleId: 'com.example.educclass',
  );
}
