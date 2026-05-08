import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:libraryapp/models/borrowed_books.dart';
import 'package:libraryapp/widgets/book_cover_placeholder.dart';

class BookInfoCard extends StatelessWidget {
  final BorrowedBooks book;
  final VoidCallback onMarkAsReturned;
  final VoidCallback onMarkAsNotReturned;

  const BookInfoCard({
    super.key,
    required this.book,
    required this.onMarkAsReturned,
    required this.onMarkAsNotReturned,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookCover(),
                const SizedBox(width: 15),
                Expanded(child: _buildBookDetails(context)),
              ],
            ),
            const SizedBox(height: 12),
            _buildReturnToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          book.customImagePath != null
              ? Image.file(
                File(book.customImagePath!),
                height: 180,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const BookCoverPlaceholder(height: 180, width: 120),
              )
              : book.cover_i != null
              ? CachedNetworkImage(
                imageUrl:
                    'https://covers.openlibrary.org/b/id/${book.cover_i}-L.jpg',
                height: 180,
                width: 120,
                fit: BoxFit.cover,
                errorWidget:
                    (context, url, error) =>
                        const BookCoverPlaceholder(height: 180, width: 120),
              )
              : const BookCoverPlaceholder(height: 180, width: 120),
    );
  }

  Widget _buildBookDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          book.author,
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (book.rating != null) _buildRating(),
        const SizedBox(height: 12),
        if (book.pages != null)
          _buildInfoRow(Icons.menu_book, 'Pages: ${book.pages}'),
        if (book.publishYear != null)
          _buildInfoRow(Icons.calendar_today, 'Published: ${book.publishYear}'),
        if (book.upc.isNotEmpty)
          _buildInfoRow(Icons.qr_code, 'ISBN: ${book.upc}', flexible: true),
      ],
    );
  }

  Widget _buildRating() {
    final rating = double.tryParse(book.rating!) ?? 0.0;
    return Row(
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return const Icon(Icons.star, color: Colors.orange, size: 18);
          } else if (index < rating) {
            return const Icon(Icons.star_half, color: Colors.orange, size: 18);
          } else {
            return const Icon(
              Icons.star_border,
              color: Colors.orange,
              size: 18,
            );
          }
        }),
        const SizedBox(width: 6),
        Text(
          book.rating!,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool flexible = false}) {
    final content = Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        flexible
            ? Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
              ),
            )
            : Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
      ],
    );

    return Padding(padding: const EdgeInsets.only(bottom: 6.0), child: content);
  }

  Widget _buildReturnToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.book,
            label: 'Not Returned',
            isActive: book.returnDate == null,
            color: Colors.orange,
            onTap: book.returnDate != null ? onMarkAsNotReturned : null,
            isLeft: true,
          ),
          _buildToggleButton(
            icon: Icons.check,
            label: 'Returned',
            isActive: book.returnDate != null,
            color: Colors.green,
            onTap: book.returnDate == null ? onMarkAsReturned : null,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required MaterialColor color,
    required VoidCallback? onTap,
    required bool isLeft,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: isLeft ? const Radius.circular(7) : Radius.zero,
          bottomLeft: isLeft ? const Radius.circular(7) : Radius.zero,
          topRight: !isLeft ? const Radius.circular(7) : Radius.zero,
          bottomRight: !isLeft ? const Radius.circular(7) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? color.shade50 : Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? const Radius.circular(7) : Radius.zero,
              bottomLeft: isLeft ? const Radius.circular(7) : Radius.zero,
              topRight: !isLeft ? const Radius.circular(7) : Radius.zero,
              bottomRight: !isLeft ? const Radius.circular(7) : Radius.zero,
            ),
            border: isActive
                ? Border.all(color: color.shade300, width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? color.shade700 : Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? color.shade700 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
