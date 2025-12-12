import 'package:smartlib_staff_app/data/model/enum/genre.dart';
import 'package:smartlib_staff_app/data/model/enum/language.dart';

class Book {
  final int bookId;
  final String title;
  final String author;
  final Language? language;
  final Genre? genre;
  final int totalCopies;
  final int availableCopies;
  final int shelfRow;
  final int shelfCabinet;
  final int shelfNumber;

  Book({
    required this.bookId,
    required this.title,
    required this.author,
    this.language,
    this.genre,
    required this.totalCopies,
    required this.availableCopies,
    required this.shelfRow,
    required this.shelfCabinet,
    required this.shelfNumber,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      bookId: map['book_id'],
      title: map['title'],
      author: map['author'],
      language: map['language'] != null
          ? Language.fromString(map['language'])
          : null,
      genre: map['genre'] != null ? Genre.fromString(map['genre']) : null,
      totalCopies: map['total_copies'],
      availableCopies: map['available_copies'],
      shelfRow: map['shelf_row'],
      shelfCabinet: map['shelf_cabinet'],
      shelfNumber: map['shelf_number'],
    );
  }
}
