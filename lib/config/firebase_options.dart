// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: '1:769326762437:web:7cfbb35f486cda1c2a23ac',
    messagingSenderId: '769326762437',
    projectId: 'list-mingle',
    authDomain: 'list-mingle.firebaseapp.com',
    databaseURL: String.fromEnvironment('FIREBASE_RTDB_URL'),
    storageBucket: 'list-mingle.appspot.com',
    measurementId: 'G-GVRS77L754',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: '1:769326762437:android:a0652d8dbc52de202a23ac',
    messagingSenderId: '769326762437',
    projectId: 'list-mingle',
    databaseURL: String.fromEnvironment('FIREBASE_RTDB_URL'),
    storageBucket: 'list-mingle.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_APPLE_API_KEY'),
    appId: '1:769326762437:ios:bbad599db402b9cc2a23ac',
    messagingSenderId: '769326762437',
    projectId: 'list-mingle',
    databaseURL: String.fromEnvironment('FIREBASE_RTDB_URL'),
    storageBucket: 'list-mingle.appspot.com',
    iosBundleId: 'dev.duddu.listMingle',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_APPLE_API_KEY'),
    appId: '1:769326762437:ios:50c362d570a96a862a23ac',
    messagingSenderId: '769326762437',
    projectId: 'list-mingle',
    databaseURL: String.fromEnvironment('FIREBASE_RTDB_URL'),
    storageBucket: 'list-mingle.appspot.com',
    iosBundleId: 'dev.duddu.listMingle.RunnerTests',
  );
}