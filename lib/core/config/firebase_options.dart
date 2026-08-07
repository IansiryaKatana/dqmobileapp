// File generated for Firebase project awesome-62ce1 (FlutterFire + manual iOS fix).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static const _placeholder = 'REPLACE_WITH_FLUTTERFIRE';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
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

  /// True when real FlutterFire / Firebase keys are present (not placeholders).
  static bool get isConfigured {
    FirebaseOptions opts;
    try {
      opts = currentPlatform;
    } catch (_) {
      return false;
    }
    return opts.apiKey.isNotEmpty &&
        !opts.apiKey.contains(_placeholder) &&
        opts.appId.isNotEmpty &&
        !opts.appId.contains(_placeholder) &&
        opts.messagingSenderId.isNotEmpty &&
        !opts.messagingSenderId.contains(_placeholder);
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAtcdl2MtJ0-xzw7A534HgMdbHEnZyumDE',
    appId: '1:930683610105:android:22a3f160792b42c29ed328',
    messagingSenderId: '930683610105',
    projectId: 'awesome-62ce1',
    databaseURL: 'https://awesome-62ce1.firebaseio.com',
    storageBucket: 'awesome-62ce1.firebasestorage.app',
  );

  /// iOS uses bundle id without underscore (Apple rejects `_` in bundle IDs).
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDK1NC-EvqRbGwSN6hjvWWDDOfNzBeHlBg',
    appId: '1:930683610105:ios:b357e89e9cf68d869ed328',
    messagingSenderId: '930683610105',
    projectId: 'awesome-62ce1',
    databaseURL: 'https://awesome-62ce1.firebaseio.com',
    storageBucket: 'awesome-62ce1.firebasestorage.app',
    iosBundleId: 'com.donatequran.donatequran',
  );
}
