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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBhI0V7T49Va3sVzFBw_n-fQF1U80tTQyA',
    appId: '1:60437951731:web:4e5744395f7c2b5716b386',
    messagingSenderId: '60437951731',
    projectId: 'esp32fproject',
    authDomain: 'esp32fproject.firebaseapp.com',
    databaseURL: 'https://esp32fproject-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'esp32fproject.appspot.com',
    measurementId: 'G-1K2C6S3MMG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA63hEYI2tFvcVRE-oWLbTSfQbU0Tqu_BI',
    appId: '1:60437951731:android:b79e0bf0179661a916b386',
    messagingSenderId: '60437951731',
    projectId: 'esp32fproject',
    databaseURL: 'https://esp32fproject-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'esp32fproject.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAFqzF7u1EhOBcysRoaUm7cjJAvjpz29WM',
    appId: '1:60437951731:ios:1998f55391ba88a216b386',
    messagingSenderId: '60437951731',
    projectId: 'esp32fproject',
    databaseURL: 'https://esp32fproject-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'esp32fproject.appspot.com',
    iosClientId: '60437951731-p2gjpk6m1kdvctiu3006gmjvpp3k4u3t.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutteresp32',
  );
}
