import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_store.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Book Store'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add a book',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddBookScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<BookStore>(
        builder: (context, store, _) {
          final books = store.books;
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Your store is empty.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first book'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddBookScreen()),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: books.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final book = books[index];
              return _BookTile(book: book);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBookScreen()),
        ),
        icon: const Icon(Icons.search),
        label: const Text('Search & Add'),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final Book book;
  const _BookTile({required this.book});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _CoverImage(coverUrl: book.coverUrl, size: 48),
      title: Text(book.title,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown author',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (book.firstPublishYear != null)
            Text(
              '${book.firstPublishYear}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remove from store',
            onPressed: () =>
                context.read<BookStore>().removeBook(book.key),
          ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => BookDetailScreen(book: book)),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String coverUrl;
  final double size;
  const _CoverImage({required this.coverUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    if (coverUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.book, size: 28),
      );
    }
    return Image.network(
      coverUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.book, size: 28),
      ),
    );
  }
}
