import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:libraryapp/models/borrowed_books.dart';
import 'package:libraryapp/screens/home/widgets/calendar_heatmap.dart';
import 'package:libraryapp/screens/home/widgets/compact_book_card.dart';
import 'package:libraryapp/screens/home/widgets/due_this_week_card.dart';
import 'package:libraryapp/screens/scan/scan_screen.dart';
import 'package:libraryapp/screens/bookdetail/book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final borrowedBooksBox = Hive.box<BorrowedBooks>('borrowedBooks');
  final PageController _dueController = PageController(viewportFraction: 0.92);

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
      ),

      body: ValueListenableBuilder(
        valueListenable: borrowedBooksBox.listenable(),
        builder: (context, box, _) {
          // Build proper key-value pairs for non-returned books
          final bookEntries =
              box.keys
                  .map((key) {
                    final book = box.get(key);
                    return {'key': key, 'book': book};
                  })
                  .where(
                    (entry) =>
                        entry['book'] != null &&
                        (entry['book'] as BorrowedBooks).returnDate == null,
                  )
                  .toList();

          final books =
              bookEntries
                  .map((entry) => entry['book'] as BorrowedBooks)
                  .toList();

          // Calculate statistics
          final now = DateTime.now();

          final booksReturningThisWeek =
              books.where((book) {
                if (book.dueDate == null) return false;
                final daysUntilReturn = book.dueDate!.difference(now).inDays;
                return daysUntilReturn >= 0 && daysUntilReturn <= 7;
              }).toList();

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No books borrowed yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan a book to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ScanScreen()),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D4E37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Greeting Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hello, Rishabh Yadav',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('👋', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Good to have you back!',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              // Due This Week Section (with overdue alert)
              SliverToBoxAdapter(
                child: DueThisWeekSection(
                  bookEntries: bookEntries,
                  booksReturningThisWeek: booksReturningThisWeek,
                  parentContext: context,
                ),
              ),
              // Calendar Heatmap Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CalendarHeatmap(books: books),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade200,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Borrowed',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade200,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //All Overdue Books Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: _buildSectionHeader('Overdue Books'),
                ),
              ),

              // Overdue Books Horizontal List
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        bookEntries.where((entry) {
                          final book = entry['book'] as BorrowedBooks;
                          if (book.dueDate == null) return false;
                          return book.dueDate!.isBefore(DateTime.now());
                        }).length,
                    itemBuilder: (context, index) {
                      final overdueEntries =
                          bookEntries.where((entry) {
                            final book = entry['book'] as BorrowedBooks;
                            if (book.dueDate == null) return false;
                            return book.dueDate!.isBefore(DateTime.now());
                          }).toList();
                      final entry = overdueEntries[index];
                      final book = entry['book'] as BorrowedBooks;
                      final key = entry['key'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: CompactBookCard(
                          book: book,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BookDetailScreen(
                                      book: book,
                                      bookKey: key,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // All Books Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: _buildSectionHeader('Recently Added'),
                ),
              ),

              // Recently Added Books Horizontal List
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Builder(
                    builder: (context) {
                      // Show most recently added entries first by reversing the list
                      final recentEntries = List.from(bookEntries.reversed);
                      final displayCount =
                          recentEntries.length > 5 ? 5 : recentEntries.length;

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayCount,
                        itemBuilder: (context, index) {
                          final entry = recentEntries[index];
                          final book = entry['book'] as BorrowedBooks;
                          final key = entry['key'];

                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: CompactBookCard(
                              book: book,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => BookDetailScreen(
                                          book: book,
                                          bookKey: key,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}
