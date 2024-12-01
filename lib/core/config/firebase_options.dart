import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyDk52BKLhV0w4ZTaXK_wdxnjlGPYChJ1N0',
    appId: '1:938846057267:web:22bc22af4689ddbdee4446',
    messagingSenderId: '938846057267',
    projectId: 'bohurupicms',
    authDomain: 'bohurupicms.firebaseapp.com',
    storageBucket: 'bohurupicms.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDk52BKLhV0w4ZTaXK_wdxnjlGPYChJ1N0',
    appId: '1:938846057267:android:22bc22af4689ddbdee4446',
    messagingSenderId: '938846057267',
    projectId: 'bohurupicms',
    storageBucket: 'bohurupicms.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDk52BKLhV0w4ZTaXK_wdxnjlGPYChJ1N0',
    appId: '1:938846057267:ios:22bc22af4689ddbdee4446',
    messagingSenderId: '938846057267',
    projectId: 'bohurupicms',
    storageBucket: 'bohurupicms.firebasestorage.app',
    iosBundleId: 'com.bohurupi.cms',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDk52BKLhV0w4ZTaXK_wdxnjlGPYChJ1N0',
    appId: '1:938846057267:web:22bc22af4689ddbdee4446',
    messagingSenderId: '938846057267',
    projectId: 'bohurupicms',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDk52BKLhV0w4ZTaXK_wdxnjlGPYChJ1N0',
    appId: '1:938846057267:ios:22bc22af4689ddbdee4446',
    messagingSenderId: '938846057267',
    projectId: 'bohurupicms',
    storageBucket: 'bohurupicms.firebasestorage.app',
    iosBundleId: 'com.bohurupi.cms',
  );
}
