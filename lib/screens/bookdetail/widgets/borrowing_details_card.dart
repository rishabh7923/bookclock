import 'package:flutter/material.dart';
import 'package:libraryapp/models/borrowed_books.dart';

class BorrowingDetailsCard extends StatelessWidget {
  final BorrowedBooks book;
  final double totalFine;
  final String Function(DateTime?) formatDate;

  const BorrowingDetailsCard({
    super.key,
    required this.book,
    required this.totalFine,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final progress = book.calculateReturnProgress();
    final progressValue = (progress is double) ? progress : 0.0;

    return Column(
      children: [
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateInfo(
                          Icons.person,
                          'Borrowed From',
                          '${book.borrowerName ?? 'N/A'}',
                        ),
                         _buildDateInfo(
                          Icons.calendar_today,
                          'Borrowed At',
                          formatDate(book.borrowedDate),
                          crossAxisAlignment: CrossAxisAlignment.end
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 0.1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateInfo(
                          Icons.event,
                          'Due On',
                          formatDate(book.dueDate),
                        ),
                        _buildDateInfo(
                          Icons.currency_rupee,
                          'Total Fine',
                          '\₹ ${totalFine.toStringAsFixed(2)}' + ' (${book.finePerDay?.toStringAsFixed(2)}/day)',
                          crossAxisAlignment: CrossAxisAlignment.end,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              if (book.returnDate == null &&
                  book.dueDate != null &&
                  DateTime.now().isBefore(book.dueDate!))
                _buildProgressBar(progressValue),
            ],
          ),
        ),
        if (book.returnDate == null &&
            book.dueDate != null &&
            DateTime.now().isBefore(book.dueDate!))
          _buildTimeLeftIndicator(),
      ],
    );
  }


  Widget _buildDateInfo(IconData icon, String label, String value, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progressValue) {
    return LinearProgressIndicator(
      value: progressValue.clamp(0.0, 1.0),
      minHeight: 8,
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation<Color>(
        progressValue > 0.8
            ? Colors.red
            : progressValue > 0.5
            ? Colors.orange
            : Colors.green,
      ),
    );
  }

  Widget _buildTimeLeftIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.schedule, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            book.timeLeftBeforeReturn(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
