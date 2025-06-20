import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:projectzazah/main.dart';
import 'package:projectzazah/theme_notifier.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the app and wrap it in ChangeNotifierProvider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const SmartCartApp(isLoggedIn: false), // misal belum login
      ),
    );

    // Ini hanya berlaku jika halaman login menampilkan angka 0,
    // dan kamu punya widget counter (seperti app default).
    // Jika tidak, kamu harus menyesuaikan test ini.

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
