import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:book_store/providers/book_store.dart';
import 'package:book_store/screens/book_list_screen.dart';

void main() {
  testWidgets('Book store renders empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BookStore(),
        child: const MaterialApp(home: BookListScreen()),
      ),
    );

    expect(find.text('My Book Store'), findsOneWidget);
    expect(find.text('Your store is empty.'), findsOneWidget);
  });
}
