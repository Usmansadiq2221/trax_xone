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
    apiKey: 'AIzaSyB0nEExqx1PFqTg1XTb0q1gW68zDAMOlgI',
    appId: '1:337105194716:web:1b61c54bd3229fd2596e19',
    messagingSenderId: '337105194716',
    projectId: 'trax-xone-b5ce0',
    authDomain: 'trax-xone-b5ce0.firebaseapp.com',
    storageBucket: 'trax-xone-b5ce0.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyArfJBn-Lkd8jyflyob3Wb5oYNf80_2bXU',
    appId: '1:337105194716:android:44dd17891a5b6a46596e19',
    messagingSenderId: '337105194716',
    projectId: 'trax-xone-b5ce0',
    storageBucket: 'trax-xone-b5ce0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDg-wFrl-GC01DaokYtcKvz1tO4V9vUu7I',
    appId: '1:337105194716:ios:9126106251ae3506596e19',
    messagingSenderId: '337105194716',
    projectId: 'trax-xone-b5ce0',
    storageBucket: 'trax-xone-b5ce0.appspot.com',
    iosClientId: '337105194716-von5u093serfboh488okfrnuaing4agk.apps.googleusercontent.com',
    iosBundleId: 'com.devtwist.traxxone',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDg-wFrl-GC01DaokYtcKvz1tO4V9vUu7I',
    appId: '1:337105194716:ios:9126106251ae3506596e19',
    messagingSenderId: '337105194716',
    projectId: 'trax-xone-b5ce0',
    storageBucket: 'trax-xone-b5ce0.appspot.com',
    iosClientId: '337105194716-von5u093serfboh488okfrnuaing4agk.apps.googleusercontent.com',
    iosBundleId: 'com.devtwist.traxxone',
  );
}
