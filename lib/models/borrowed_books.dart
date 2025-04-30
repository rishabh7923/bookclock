import 'package:hive_flutter/hive_flutter.dart';
part 'borrowed_books.g.dart';

@HiveType(typeId: 0)
class BorrowedBooks {
  @HiveField(0)
  String upc;

  @HiveField(1)
  String title;
  
  @HiveField(2)
  String author;
  
  @HiveField(3)
  String? cover_i;

  @HiveField(4)
  String? rating;
  
  @HiveField(5)
  String? pages;

  @HiveField(6)
  String? publishYear;

  @HiveField(7)
  DateTime? borrowedDate;
  
  @HiveField(8)
  DateTime? returnDate;

  BorrowedBooks({
    required this.upc,
    required this.title,
    required this.author,
    required this.borrowedDate,
    required this.returnDate,
    this.rating,
    this.pages,
    this.publishYear,
    this.cover_i,
  });

  String timeLeftBeforeReturn() {
    final now = DateTime.now();
    final difference = returnDate?.difference(now);
    if (difference == null) return "0D 0H";

    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    
    return "${days}D ${hours}H";
  }
}
