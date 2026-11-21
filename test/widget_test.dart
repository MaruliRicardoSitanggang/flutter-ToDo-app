import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pertemuan6/providers/auth_notifier.dart';
import 'package:pertemuan6/screens/sign_in_screen.dart';
import 'package:provider/provider.dart';

void main() {
  late _TestAuthNotifier auth;

  setUp(() {
    auth = _TestAuthNotifier();
  });

  tearDown(() {
    auth.dispose();
  });

  Future<void> showSignIn(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthNotifier>.value(
        value: auth,
        child: const MaterialApp(home: SignInScreen()),
      ),
    );
  }

  testWidgets('Login form shows email and password fields', (tester) async {
    await showSignIn(tester);

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    final passwordField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Password'),
    );
    expect(passwordField.obscureText, isTrue);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Belum punya akun? Sign Up'), findsOneWidget);
  });

  testWidgets('Login submits credentials and prevents duplicate requests', (
    tester,
  ) async {
    await showSignIn(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      '  user@example.com  ',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(auth.submittedEmail, 'user@example.com');
    expect(auth.submittedPassword, 'password123');
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    await tester.tap(find.byType(ElevatedButton));
    expect(auth.signInCalls, 1);

    auth.signInResult.complete(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(auth.isLoading, isFalse);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Failed login shows feedback and re-enables the button', (
    tester,
  ) async {
    await showSignIn(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    auth.signInResult.complete(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(auth.isLoading, isFalse);

    expect(
      find.text('Login gagal. Periksa email dan password.'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sign Up opens registration and Sign In returns to login', (
    tester,
  ) async {
    await showSignIn(tester);
    await tester.tap(find.text('Belum punya akun? Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Daftar'), findsOneWidget);

    await tester.tap(find.text('Sudah punya akun? Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsNothing);
  });

  testWidgets('Registration submits to signUp and shows failure feedback', (
    tester,
  ) async {
    await showSignIn(tester);
    await tester.tap(find.text('Belum punya akun? Sign Up'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      '  new@example.com  ',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'newPassword123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pump();

    expect(auth.signUpCalls, 1);
    expect(auth.signInCalls, 0);
    expect(auth.submittedEmail, 'new@example.com');
    expect(auth.submittedPassword, 'newPassword123');
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    auth.signUpResult.complete(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Sign Up'), findsOneWidget);
    expect(
      find.text('Pendaftaran gagal. Periksa email dan password.'),
      findsOneWidget,
    );
    expect(auth.isLoading, isFalse);
  });

  testWidgets('Successful registration closes the registration page', (
    tester,
  ) async {
    await showSignIn(tester);
    await tester.tap(find.text('Belum punya akun? Sign Up'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pump();

    auth.signUpResult.complete(true);
    await tester.pumpAndSettle();

    expect(find.text('Sign Up'), findsNothing);
    expect(find.text('Sign In'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

// Implements the notifier without constructing AuthService or FirebaseAuth.
class _TestAuthNotifier extends ChangeNotifier implements AuthNotifier {
  late final signInResult = Completer<bool>();
  late final signUpResult = Completer<bool>();
  bool _isLoading = false;
  String? submittedEmail;
  String? submittedPassword;
  int signInCalls = 0;
  int signUpCalls = 0;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<bool> signIn(String email, String password) async {
    submittedEmail = email;
    submittedPassword = password;
    signInCalls++;
    _isLoading = true;
    notifyListeners();
    try {
      return await signInResult.future;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<bool> signUp(String email, String password) async {
    submittedEmail = email;
    submittedPassword = password;
    signUpCalls++;
    _isLoading = true;
    notifyListeners();
    try {
      return await signUpResult.future;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> signOut() async {
    throw UnsupportedError('Sign-out is not used by these login tests.');
  }
}
