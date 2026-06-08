// File generated for Gozolt Driver App.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for Web on Driver App.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDridqV09-x8J8EdVSsrQElGsCbBWRJJcc',
    appId: '1:715853709143:android:d7f74c83a40fa245494812',
    messagingSenderId: '715853709143',
    projectId: 'numbers-9f9f6',
    storageBucket: 'numbers-9f9f6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVJHK90nlOgJMj6jL2t8gkBr3Fx-ZIoKI',
    appId: '1:715853709143:ios:f8a08140054757b5494812',
    messagingSenderId: '715853709143',
    projectId: 'numbers-9f9f6',
    storageBucket: 'numbers-9f9f6.firebasestorage.app',
    iosBundleId: 'com.gozolt.gozoltDriver',
  );
}
