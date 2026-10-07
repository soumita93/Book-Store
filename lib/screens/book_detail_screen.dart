import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_store.dart';
import '../services/book_api_service.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Book? _detail;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await BookApiService().fetchBookDetail(widget.book.key);
      // Merge authors from the search result (works endpoint doesn't inline them)
      setState(() {
        _detail = Book(
          key: detail.key,
          title: detail.title.isNotEmpty ? detail.title : widget.book.title,
          authors: widget.book.authors,
          coverId: detail.coverId ?? widget.book.coverId,
          firstPublishYear: widget.book.firstPublishYear,
          description: detail.description,
        );
        _loading = false;
      });
    } catch (_) {
      // Fallback: display data we already have
      setState(() {
        _detail = widget.book;
        _loading = false;
        _error = 'Could not load full details.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = _detail ?? widget.book;
    final store = context.watch<BookStore>();
    final inStore = store.contains(book.key);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, overflow: TextOverflow.ellipsis),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(inStore ? Icons.bookmark : Icons.bookmark_border),
            tooltip: inStore ? 'Remove from store' : 'Add to store',
            onPressed: () {
              if (inStore) {
                context.read<BookStore>().removeBook(book.key);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('"${book.title}" removed from your store.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                context.read<BookStore>().addBook(book);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${book.title}" added to your store.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover + basic info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CoverImage(coverUrl: book.coverUrl, size: 120),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge,
                            ),
                            if (book.authors.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                book.authors.join(', '),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                              ),
                            ],
                            if (book.firstPublishYear != null) ...[
                              const SizedBox(height: 8),
                              _InfoChip(
                                  label:
                                      'First published ${book.firstPublishYear}'),
                            ],
                            const SizedBox(height: 8),
                            _InfoChip(
                              label: inStore ? 'In your store' : 'Not in store',
                              color: inStore ? Colors.green : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Description
                  if (book.description != null &&
                      book.description!.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(book.description!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ] else ...[
                    Text(
                      'No description available.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ],
              ),
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
        child: const Icon(Icons.book, size: 48),
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
        child: const Icon(Icons.book, size: 48),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color? color;
  const _InfoChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
            fontSize: 12,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
