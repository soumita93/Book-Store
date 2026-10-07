import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_store.dart';
import '../services/book_api_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _controller = TextEditingController();
  final _service = BookApiService();

  List<Book> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });
    try {
      final results = await _service.searchBooks(query);
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Search failed. Please check your connection.';
        _loading = false;
      });
    }
  }

  void _addBook(Book book) {
    final added = context.read<BookStore>().addBook(book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '"${book.title}" added to your store.'
              : '"${book.title}" is already in your store.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Books'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Search by title, author…',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : _search,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text('Enter a search term to find books.'),
      );
    }
    return Consumer<BookStore>(
      builder: (context, store, _) {
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: _results.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final book = _results[index];
            final alreadyAdded = store.contains(book.key);
            return ListTile(
              leading: _CoverImage(coverUrl: book.coverUrl, size: 48),
              title: Text(book.title,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                book.authors.isNotEmpty
                    ? book.authors.join(', ')
                    : 'Unknown author',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: alreadyAdded
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add to store',
                      onPressed: () => _addBook(book),
                    ),
            );
          },
        );
      },
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
