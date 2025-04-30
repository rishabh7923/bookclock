// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'borrowed_books.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BorrowedBooksAdapter extends TypeAdapter<BorrowedBooks> {
  @override
  final int typeId = 0;

  @override
  BorrowedBooks read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BorrowedBooks(
      upc: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      borrowedDate: fields[7] as DateTime?,
      returnDate: fields[8] as DateTime?,
      rating: fields[4] as String?,
      pages: fields[5] as String?,
      publishYear: fields[6] as String?,
      cover_i: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BorrowedBooks obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.upc)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.cover_i)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.pages)
      ..writeByte(6)
      ..write(obj.publishYear)
      ..writeByte(7)
      ..write(obj.borrowedDate)
      ..writeByte(8)
      ..write(obj.returnDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorrowedBooksAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
