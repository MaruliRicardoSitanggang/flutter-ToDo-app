import 'package:pertemuan6/providers/auth_notifier.dart';
import 'package:pertemuan6/screens/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: kIsWeb ? FirebaseWebOptions.options : null,
  );
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, this.initializer});

  final Future<void> Function()? initializer;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future<void>.sync(widget.initializer ?? _initializeFirebase)
          .timeout(const Duration(seconds: 20));
    } catch (error, stackTrace) {
      debugPrint('Gagal memulai aplikasi: $error');
      debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return const MyApp();
        }

        final hasError =
            snapshot.connectionState == ConnectionState.done &&
            snapshot.hasError;
        final missingWebConfiguration =
            hasError && snapshot.error is UnsupportedError;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!hasError) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Menyiapkan aplikasi...'),
                    ] else ...[
                      const Icon(Icons.cloud_off, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        missingWebConfiguration
                            ? 'Versi browser belum dikonfigurasi. '
                                  'Silakan gunakan aplikasi Android.'
                            : 'Aplikasi belum dapat terhubung ke layanan login.',
                        textAlign: TextAlign.center,
                      ),
                      if (!missingWebConfiguration) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _initialization = _initialize();
                            });
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthNotifier(),
      child: const MaterialApp(
        home: AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
