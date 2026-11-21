# pertemuan6

A Flutter application with Firebase Authentication.

## Menjalankan aplikasi

Jalankan perintah dari folder utama proyek (folder yang berisi `pubspec.yaml`).

Android menggunakan konfigurasi `android/app/google-services.json` yang sudah ada:

```powershell
flutter run -d <id-perangkat-android>
```

Untuk Chrome, Firebase memerlukan konfigurasi aplikasi **Web** dari proyek yang sama.
Buka Firebase Console → Project settings → Your apps → Web. Jika belum ada,
tambahkan aplikasi Web dan salin objek `firebaseConfig`.

Salin `firebase.web.example.json` menjadi `firebase.web.json`, lalu isi nilai
sesuai konfigurasi tersebut:

| Nilai pada firebaseConfig | Nama pada firebase.web.json |
| --- | --- |
| apiKey | FIREBASE_WEB_API_KEY |
| appId (mengandung `:web:`) | FIREBASE_WEB_APP_ID |
| messagingSenderId | FIREBASE_WEB_MESSAGING_SENDER_ID |
| projectId | FIREBASE_WEB_PROJECT_ID |
| authDomain | FIREBASE_WEB_AUTH_DOMAIN |
| storageBucket | FIREBASE_WEB_STORAGE_BUCKET |

```powershell
flutter run -d chrome --dart-define-from-file=firebase.web.json
```

Di Android Studio, masukkan `--dart-define-from-file=firebase.web.json` ke
Additional run args pada konfigurasi Run `main.dart`, lalu Stop dan Run ulang.
Perubahan konfigurasi build tidak diterapkan melalui Hot Reload.

Aktifkan provider Email/Password pada Firebase Authentication untuk menggunakan
formulir login dan pendaftaran. Jika inisialisasi gagal, aplikasi menampilkan
pesan dan tombol coba lagi; detail error tersedia pada konsol debug.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
