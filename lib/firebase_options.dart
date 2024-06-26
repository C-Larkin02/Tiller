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
    apiKey: 'AIzaSyAQRS5ViDklAzI_fHkcfIR1ZPfE9A3-xDQ',
    appId: '1:670254836700:web:cb6c4c2b2f2b5a42737d19',
    messagingSenderId: '670254836700',
    projectId: 'fypfinanceapp-1df32',
    authDomain: 'fypfinanceapp-1df32.firebaseapp.com',
    storageBucket: 'fypfinanceapp-1df32.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCR0JUsJt0p9ShvM7u7-l9ImRx2fisyqPk',
    appId: '1:670254836700:android:74d28d3f7b000bdf737d19',
    messagingSenderId: '670254836700',
    projectId: 'fypfinanceapp-1df32',
    storageBucket: 'fypfinanceapp-1df32.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgcUrhABd78E4kvzqhJ-6OIBRkEmy4pgM',
    appId: '1:670254836700:ios:91823ae69cfb2215737d19',
    messagingSenderId: '670254836700',
    projectId: 'fypfinanceapp-1df32',
    storageBucket: 'fypfinanceapp-1df32.appspot.com',
    iosBundleId: 'com.example.protoProj',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCgcUrhABd78E4kvzqhJ-6OIBRkEmy4pgM',
    appId: '1:670254836700:ios:971d9ddc953caa26737d19',
    messagingSenderId: '670254836700',
    projectId: 'fypfinanceapp-1df32',
    storageBucket: 'fypfinanceapp-1df32.appspot.com',
    iosBundleId: 'com.example.protoProj.RunnerTests',
  );
}
