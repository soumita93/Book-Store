import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/book_store.dart';
import 'screens/book_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BookStore(),
      child: const BookStoreApp(),
    ),
  );
}

class BookStoreApp extends StatelessWidget {
  const BookStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BookListScreen(),
    );
  }
}
