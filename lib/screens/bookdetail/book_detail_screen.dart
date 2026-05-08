import 'dart:async';
import 'package:flutter/material.dart';
import 'package:libraryapp/models/borrowed_books.dart';
import 'package:libraryapp/screens/bookdetail/services/book_detail_service.dart';
import 'package:libraryapp/screens/bookdetail/widgets/book_info_card.dart';
import 'package:libraryapp/screens/bookdetail/widgets/borrowing_details_card.dart';
import 'package:libraryapp/screens/bookdetail/widgets/notes_card.dart';
import 'package:libraryapp/screens/bookdetail/widgets/return_date_card.dart';
import 'package:libraryapp/screens/updatebook/updatebook_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final BorrowedBooks book;
  final dynamic bookKey;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.bookKey,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _refreshState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final totalFine = BookDetailService.calculateTotalFine(book);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBookScreen(
                    existingBook: book,
                    bookKey: widget.bookKey,
                  ),
                ),
              );
              _refreshState();
            },
            tooltip: 'Edit Book',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            offset: const Offset(0, 50),
            onSelected: (value) async {
              if (value == 'delete') {
                await BookDetailService.deleteBook(
                  context: context,
                  book: book,
                  bookKey: widget.bookKey,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 12),
                    Text('Delete Book'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookInfoCard(
                book: book,
                onMarkAsReturned: () => BookDetailService.markAsReturned(
                  context: context,
                  book: book,
                  bookKey: widget.bookKey,
                  onSuccess: _refreshState,
                ),
                onMarkAsNotReturned: () => BookDetailService.markAsNotReturned(
                  context: context,
                  book: book,
                  bookKey: widget.bookKey,
                  onSuccess: _refreshState,
                ),
              ),
              const SizedBox(height: 16),
              BorrowingDetailsCard(
                book: book,
                totalFine: totalFine,
                formatDate: _formatDate,
              ),
              ReturnDateCard(
                returnDate: book.returnDate,
                formatDate: _formatDate,
              ),
              NotesCard(notes: book.notes),
            ],
          ),
        ),
      ),
    );
  }
}
