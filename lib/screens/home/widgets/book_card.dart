import 'package:flutter/material.dart';
import 'package:libraryapp/models/borrowed_books.dart';
import 'package:libraryapp/screens/home/widgets/attribute_chip.dart';
import 'package:libraryapp/widgets/book_cover_placeholder.dart';

class BookCard extends StatelessWidget {
  final BorrowedBooks book;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            book.cover_i != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    'https://covers.openlibrary.org/b/id/${book.cover_i}-M.jpg',
                    height: 130,
                    width: 90,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (ctx, err, _) => Container(
                          height: 130,
                          width: 90,
                          color: Colors.grey[500],
                          child: const Icon(Icons.broken_image),
                        ),
                  ),
                )
                : BookCoverPlaceholder(height: 130, width: 90),

            const SizedBox(width: 20),

            Expanded(
              child: SizedBox(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book details at the top
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title ?? 'Unknown Title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          book.author ?? 'Unknown Author',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),

                        // Book details row
                      ],
                    ),

                    Column(
                      spacing: 10,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AttributeChip(
                              attribute: book.rating ?? 'N/A',
                              icon: Icons.star,
                            ),
                            AttributeChip(
                              attribute: book.pages ?? 'N/A',
                              icon: Icons.pages,
                            ),
                            AttributeChip(
                              attribute: book.publishYear ?? 'N/A',
                              icon: Icons.publish_rounded,
                            ),
                            AttributeChip(
                              attribute: book.timeLeftBeforeReturn(),
                              icon: Icons.access_time,
                            ),
                          ],
                        ),

                        LinearProgressIndicator(
                          minHeight: 5,
                          value: book.calculateReturnProgress(),
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
