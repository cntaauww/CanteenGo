import 'package:flutter_test/flutter_test.dart';
import 'package:canteen_go/main.dart';

void main() {
  testWidgets('CanteenGo menampilkan halaman pilih kantin', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CanteenGoApp());

    expect(find.text('CanteenGo'), findsOneWidget);
    expect(find.text('Pilih Kantin'), findsOneWidget);
    expect(find.text('Kantin 1'), findsOneWidget);
    expect(find.text('Kantin 2'), findsOneWidget);
    expect(find.text('Kantin 3'), findsOneWidget);
  });
}
