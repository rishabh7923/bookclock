import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:libraryapp/models/borrowed_books.dart';

class BookDetailService {
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    Color? confirmButtonColor,
    Color? confirmTextColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: confirmButtonColor != null
                ? ElevatedButton.styleFrom(
                    backgroundColor: confirmButtonColor,
                    foregroundColor: confirmTextColor ?? Colors.white,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<void> markAsReturned({
    required BuildContext context,
    required BorrowedBooks book,
    required dynamic bookKey,
    required VoidCallback onSuccess,
  }) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Mark as Returned',
      message: 'Are you sure you want to mark "${book.title}" as returned?',
    );

    if (confirmed == true) {
      final borrowedBooksBox = Hive.box<BorrowedBooks>('borrowedBooks');
      book.returnDate = DateTime.now();
      await borrowedBooksBox.put(bookKey, book);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book marked as returned'),
            backgroundColor: Colors.green,
          ),
        );
        onSuccess();
      }
    }
  }

  static Future<void> markAsNotReturned({
    required BuildContext context,
    required BorrowedBooks book,
    required dynamic bookKey,
    required VoidCallback onSuccess,
  }) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Mark as Not Returned',
      message: 'Are you sure you want to mark "${book.title}" as not returned?',
    );

    if (confirmed == true) {
      final borrowedBooksBox = Hive.box<BorrowedBooks>('borrowedBooks');
      book.returnDate = null;
      await borrowedBooksBox.put(bookKey, book);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book marked as not returned'),
            backgroundColor: Colors.orange,
          ),
        );
        onSuccess();
      }
    }
  }

  static Future<void> deleteBook({
    required BuildContext context,
    required BorrowedBooks book,
    required dynamic bookKey,
  }) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Book',
      message: 'Are you sure you want to delete "${book.title}" from your library? This action cannot be undone.',
      confirmText: 'Delete',
      confirmButtonColor: Colors.red,
    );

    if (confirmed == true) {
      final borrowedBooksBox = Hive.box<BorrowedBooks>('borrowedBooks');
      await borrowedBooksBox.delete(bookKey);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static double calculateTotalFine(BorrowedBooks book) {
    if (book.borrowedDate == null || book.dueDate == null) return 0.0;
    final now = DateTime.now();
    if (now.isBefore(book.dueDate!)) return 0.0;
    final overdueDays = now.difference(book.dueDate!).inDays;
    return overdueDays * book.finePerDay;
  }
}
