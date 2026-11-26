import 'package:flutter_test/flutter_test.dart';

import 'package:rentra/main.dart';

void main() {
  testWidgets('Menampilkan pesan error saat Supabase gagal', (tester) async {
    await tester.pumpWidget(const StartupErrorView(message: 'Koneksi gagal'));

    expect(find.text('Gagal menyiapkan Supabase'), findsOneWidget);
    expect(find.text('Koneksi gagal'), findsOneWidget);
  });
}
