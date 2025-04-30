import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:libraryapp/models/borrowed_books.dart';
import 'package:libraryapp/models/open_library_item.dart';
import 'package:libraryapp/services/openlibrary.dart';
import 'package:libraryapp/widgets/book_cover_placeholder.dart';

class AddBookScreen extends StatefulWidget {
  final String upc;

  const AddBookScreen({super.key, required this.upc});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final borrowedBooksBox = Hive.box<BorrowedBooks>('borrowedBooks');

  // Make bookDetails nullable
  OpenLibraryItem? bookDetails;
  bool isLoading = true;

  // Create persistent controllers
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final returnDateController = TextEditingController();
  final defaultReturnDate = DateTime.now().add(const Duration(days: 28));

  @override
  void initState() {
    super.initState();
    extractBookDetailsFromUPC();
  }

  void extractBookDetailsFromUPC() async {
    try {
      // Set loading state
      setState(() {
        isLoading = true;
      });

      // Fetch book details
      bookDetails = await Openlibrary.search(widget.upc);

      if (bookDetails != null) {
        setState(() {
          titleController.text = bookDetails!.title;
          authorController.text = bookDetails!.author;
          returnDateController.text =
              '${defaultReturnDate.day}/${defaultReturnDate.month}/${defaultReturnDate.year}';

          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching book details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Main content in a scrollable container
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Book cover and details
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                bookDetails?.cover_i != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        'https://covers.openlibrary.org/b/id/${bookDetails!.cover_i}-M.jpg',
                                        height: 150,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : BookCoverPlaceholder(
                                      height: 150,
                                      width: 100,
                                    ),
                                const SizedBox(width: 16),

                                Expanded(
                                  child: SizedBox(
                                    height: 150,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextField(
                                          controller: titleController,
                                          decoration: const InputDecoration(
                                            labelText: 'Title',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: authorController,
                                          decoration: const InputDecoration(
                                            labelText: 'Author',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            TextField(
                              controller: returnDateController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Return Date',
                                border: OutlineInputBorder(),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: defaultReturnDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    returnDateController.text =
                                        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Note',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Button fixed at bottom
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed:
                          bookDetails == null
                              ? null
                              : () async {
                                // Parse the return date from controller text
                                final dateParts = returnDateController.text.split('/');
                                final day = int.parse(dateParts[0]);
                                final month = int.parse(dateParts[1]);
                                final year = int.parse(dateParts[2]);
                                final returnDate = DateTime(year, month, day);
                                
                                await borrowedBooksBox.add(
                                  BorrowedBooks(
                                    upc: widget.upc,
                                    title: titleController.text,
                                    author: authorController.text,
                                    rating: bookDetails?.rating ?? '0',
                                    cover_i: bookDetails?.cover_i.toString(),
                                    pages: bookDetails?.pages ?? '0',
                                    publishYear:
                                        bookDetails?.publishYear ?? 'N/A',
                                    borrowedDate: DateTime.now(),
                                    returnDate: returnDate,
                                  ),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Book added successfully'),
                                  ),
                                );

                                Navigator.pop(context);
                              },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Add Book'),
                    ),
                  ),
                ],
              ),
    );
  }
}
