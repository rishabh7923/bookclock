import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:libraryapp/models/borrowed_books.dart';
import 'package:libraryapp/screens/home/widgets/book_card.dart';
import 'package:libraryapp/screens/scan/scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final borrowedBooksBox = Hive.box<BorrowedBooks>('borrowedBooks');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        shadowColor: Colors.black,
        toolbarHeight: 80,
        title: Row(
          children: [
            
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  Image.network(
                    'https://avatars.githubusercontent.com/u/57840201?v=4',
                  ).image,
            ),
            const SizedBox(width: 20), // Replace spacing parameter

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RISHABH YADAV',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5), // Replace spacing parameter
                ValueListenableBuilder(
                  valueListenable: borrowedBooksBox.listenable(),
                  builder: (context, Box box, _) {
                    return Text(
                      '${box.length} books borrowed',
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            color: Colors.black,
            iconSize: 30,
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanScreen()),
              );
            },
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: borrowedBooksBox.listenable(),
        builder: (context, box, _) {
          final books = box.values.toList();
          
          final keys = box.keys.toList(); // Get keys for deletion
            
          if (books.isEmpty) {
            return const Center(child: Text('No books borrowed'));
          }
            
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final key = keys[index]; // Use the key instead of index
            
              return Dismissible(
                // Use a more unique key based on book title or another unique identifier
                key: Key("book-$key"),
            
                // Only allow right-to-left swipe
                direction: DismissDirection.endToStart,
            
                // Background that shows when swiping
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red[100],
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
            
                // Handle the dismiss action
                onDismissed: (direction) {
                  // Store the book temporarily in case of undo
                  final deletedBook = book;
            
                  // Delete using key instead of index
                  box.delete(key);
            
                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${deletedBook.title} removed'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          // Add the book back using the same key
                          box.put(key, deletedBook);
                        },
                      ),
                    ),
                  );
                },
            
                // Confirm before deleting
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: Text(
                              "Are you sure you want to remove ${book.title}?",
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(
                                      context,
                                    ).pop(false),
                                child: const Text("CANCEL"),
                              ),
                              TextButton(
                                onPressed:
                                    () =>
                                        Navigator.of(context).pop(true),
                                child: const Text("DELETE"),
                              ),
                            ],
                          );
                        },
                      ) ??
                      false; // Default to false if dialog is dismissed
                },
            
                // Your Row widget
                child: BookCard(book: book, onTap: () {},)
              );
            },
          );
        },
      ),
    );
  }
}
