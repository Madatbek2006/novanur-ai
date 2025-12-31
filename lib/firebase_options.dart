// import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
// import 'package:flutter/foundation.dart'
//     show defaultTargetPlatform, kIsWeb, TargetPlatform;
//
// class DefaultFirebaseOptions {
//   static FirebaseOptions get currentPlatform {
//     if (kIsWeb) {
//       throw UnsupportedError(
//         'DefaultFirebaseOptions have not been configured for web - '
//         'you can reconfigure this by running the FlutterFire CLI again.',
//       );
//     }
//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return android;
//       case TargetPlatform.iOS:
//         return ios;
//       case TargetPlatform.macOS:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for macos - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       case TargetPlatform.windows:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for windows - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       case TargetPlatform.linux:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for linux - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       default:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions are not supported for this platform.',
//         );
//     }
//   }
//
//   static const FirebaseOptions android = FirebaseOptions(
//     apiKey: 'AIzaSyDTNRDkzyjzhhCaL47DTTMGj32SiMx3sWU',
//     appId: '1:254267535567:android:b665831ef5bba08a1307ba',
//     messagingSenderId: '254267535567',
//     projectId: 'amsystem-f813a',
//     storageBucket: 'amsystem-f813a.firebasestorage.app',
//   );
//
//   static const FirebaseOptions ios = FirebaseOptions(
//     apiKey: 'AIzaSyDluXhLC37PvJBd4ilGTFt7Turf1uh64cA',
//     appId: '1:254267535567:ios:1777c1e9fa0d29ad1307ba',
//     messagingSenderId: '254267535567',
//     projectId: 'amsystem-f813a',
//     storageBucket: 'amsystem-f813a.firebasestorage.app',
//     iosBundleId: 'uz.nova.ai',
//   );
// }
