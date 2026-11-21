import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../providers/auth_notifier.dart';
import '../utils/snack_bar_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final user = FirebaseAuth.instance.currentUser;
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.email}',
              style: const TextStyle(fontSize: 18),
            ),

            SizedBox(height: screenWidth * 0.05),

            ElevatedButton(
              onPressed: authNotifier.isLoading
                  ? null
                  : () async {
                      try {
                        await context.read<AuthNotifier>().signOut();
                      } on FirebaseAuthException {
                        if (!context.mounted) return;
                        SnackBarHelper.show(
                          context,
                          'Logout gagal. Silakan coba lagi.',
                        );
                      }
                    },
              child: authNotifier.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
