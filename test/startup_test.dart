import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pertemuan6/main.dart';

void main() {
  testWidgets('Initialization failure replaces loading with a retry button', (
    tester,
  ) async {
    final initialization = Completer<void>();
    await tester.pumpWidget(
      AppBootstrap(initializer: () => initialization.future),
    );
    expect(find.text('Menyiapkan aplikasi...'), findsOneWidget);

    initialization.completeError(StateError('Connection failed'));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Retry starts a new initialization attempt', (tester) async {
    final attempts = <Completer<void>>[];
    await tester.pumpWidget(
      AppBootstrap(
        initializer: () {
          final attempt = Completer<void>();
          attempts.add(attempt);
          return attempt.future;
        },
      ),
    );
    attempts.first.completeError(StateError('Connection failed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba lagi'));
    await tester.pump();

    expect(attempts, hasLength(2));
    expect(find.text('Menyiapkan aplikasi...'), findsOneWidget);

    attempts.last.completeError(StateError('Still unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Initialization timeout stops indefinite loading', (
    tester,
  ) async {
    final initialization = Completer<void>();
    await tester.pumpWidget(
      AppBootstrap(initializer: () => initialization.future),
    );
    await tester.pump(const Duration(seconds: 21));
    await tester.pumpAndSettle();

    expect(find.text('Coba lagi'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    initialization.complete();
    await tester.pump();
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('Missing Web configuration shows a supported platform message', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppBootstrap(
        initializer: () async {
          throw UnsupportedError('Missing Firebase Web configuration');
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Versi browser belum dikonfigurasi. Silakan gunakan aplikasi Android.',
      ),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
