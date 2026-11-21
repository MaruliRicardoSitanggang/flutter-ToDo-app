import 'package:firebase_core/firebase_core.dart';

class FirebaseWebOptions {
  static FirebaseOptions get options {
    // Android uses google-services.json. Web requires a registered Web app.
    const options = FirebaseOptions(
      apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
      appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
      messagingSenderId: String.fromEnvironment(
        'FIREBASE_WEB_MESSAGING_SENDER_ID',
      ),
      projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
      authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
      storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'),
    );

    if (options.apiKey.isEmpty ||
        !options.appId.contains(':web:') ||
        options.messagingSenderId.isEmpty ||
        options.projectId.isEmpty ||
        (options.authDomain?.isEmpty ?? true)) {
      throw UnsupportedError(
        'Firebase Web belum dikonfigurasi. Isi firebase.web.json dari '
        'Firebase Console, lalu jalankan dengan '
        '--dart-define-from-file=firebase.web.json (lihat README.md).',
      );
    }

    return options;
  }
}
