// File generated manually to support Windows and avoid dotenv issues.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Para simplificar tu desarrollo en Windows y evitar problemas con .env,
    // usaremos la misma configuración de Web para todas las plataformas por ahora.
    // Firebase Core en Windows es compatible con estas llaves.
    return _firebaseOptions;
  }

  static const FirebaseOptions _firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBmXVvYz3ljZWF4NCk_2wFCMBsEfLBdg1w',
    appId: '1:15915064363:web:affee488454a62d5fbde6e',
    messagingSenderId: '15915064363',
    projectId: 'tag-ok',
    authDomain: 'tag-ok.firebaseapp.com',
    storageBucket: 'tag-ok.firebasestorage.app',
    measurementId: 'G-22KGS61ZSB',
  );
}
