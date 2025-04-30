import 'package:flutter/material.dart';

class BookCoverPlaceholder extends StatelessWidget {
  final double height;
  final double width;

  const BookCoverPlaceholder({
    super.key,
    this.height = 150,
    this.width = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[300],
      ),
      height: height,
      width: width,
      child: const Icon(Icons.broken_image),
      
    );
  }
}