import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB3aotG3uQD_nCXOh4UYeDTA3OVQeLgewA',
    appId: '1:163917481454:web:f50c07ad00f81fc35afaff',
    messagingSenderId: '163917481454',
    projectId: 'xuan-xue',
    authDomain: 'xuan-xue.firebaseapp.com',
    databaseURL: 'https://xuan-xue-default-rtdb.firebaseio.com',
    storageBucket: 'xuan-xue.firebasestorage.app',
    measurementId: 'G-CX4JZT7R8M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0DbXbUQ-TMrBCT4V58J0MExC4ck59ADI',
    appId: '1:163917481454:android:b40ccaeab1cfb5715afaff',
    messagingSenderId: '163917481454',
    projectId: 'xuan-xue',
    storageBucket: 'xuan-xue.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlELgARottn7xAqLCqQgVOMIQTaoNMx_8',
    appId: '1:163917481454:ios:8efb18f1b0b55adc5afaff',
    messagingSenderId: '163917481454',
    projectId: 'xuan-xue',
    storageBucket: 'xuan-xue.firebasestorage.app',
    iosBundleId: 'com.example.example',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDlELgARottn7xAqLCqQgVOMIQTaoNMx_8',
    appId: '1:163917481454:ios:8efb18f1b0b55adc5afaff',
    messagingSenderId: '163917481454',
    projectId: 'xuan-xue',
    storageBucket: 'xuan-xue.firebasestorage.app',
    iosBundleId: 'com.example.example',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB3aotG3uQD_nCXOh4UYeDTA3OVQeLgewA',
    appId: '1:163917481454:web:4cc01a569ac708475afaff',
    messagingSenderId: '163917481454',
    projectId: 'xuan-xue',
    authDomain: 'xuan-xue.firebaseapp.com',
    databaseURL: 'https://xuan-xue-default-rtdb.firebaseio.com',
    storageBucket: 'xuan-xue.firebasestorage.app',
    measurementId: 'G-CPYQHB5NFK',
  );
}

