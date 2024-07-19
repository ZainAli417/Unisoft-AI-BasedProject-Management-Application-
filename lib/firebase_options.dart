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
    apiKey: 'AIzaSyCdYUZQdiCl-AB2UH0RVLkZCHU4HX20dsw',
    appId: '1:139692801098:web:be067d95a9db5ae5fc3ab3',
    messagingSenderId: '139692801098',
    projectId: 'unisoft-tmp',
    authDomain: 'unisoft-tmp.firebaseapp.com',
    databaseURL: 'https://unisoft-tmp-default-rtdb.firebaseio.com',
    storageBucket: 'unisoft-tmp.appspot.com',
    measurementId: 'G-C45Q3HBMK3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmBQavT4adpoEvI3aEAVxDo5cQYbNLvn0',
    appId: '1:139692801098:android:57bb1f5c93776e15fc3ab3',
    messagingSenderId: '139692801098',
    projectId: 'unisoft-tmp',
    databaseURL: 'https://unisoft-tmp-default-rtdb.firebaseio.com',
    storageBucket: 'unisoft-tmp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCNGg1Q_6OaKLoVrj4aDKnZRbpPsVGd01w',
    appId: '1:139692801098:ios:f6f05d5ad305034bfc3ab3',
    messagingSenderId: '139692801098',
    projectId: 'unisoft-tmp',
    databaseURL: 'https://unisoft-tmp-default-rtdb.firebaseio.com',
    storageBucket: 'unisoft-tmp.appspot.com',
    androidClientId: '139692801098-47mmpljmhq4bc372q077a9t1mjcnvols.apps.googleusercontent.com',
    iosClientId: '139692801098-v6053jgsl2rp5qi0q7s86cm2hhpj39qk.apps.googleusercontent.com',
    iosBundleId: 'com.example.unisoft',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCNGg1Q_6OaKLoVrj4aDKnZRbpPsVGd01w',
    appId: '1:139692801098:ios:f6f05d5ad305034bfc3ab3',
    messagingSenderId: '139692801098',
    projectId: 'unisoft-tmp',
    databaseURL: 'https://unisoft-tmp-default-rtdb.firebaseio.com',
    storageBucket: 'unisoft-tmp.appspot.com',
    androidClientId: '139692801098-47mmpljmhq4bc372q077a9t1mjcnvols.apps.googleusercontent.com',
    iosClientId: '139692801098-v6053jgsl2rp5qi0q7s86cm2hhpj39qk.apps.googleusercontent.com',
    iosBundleId: 'com.example.unisoft',
  );
}
