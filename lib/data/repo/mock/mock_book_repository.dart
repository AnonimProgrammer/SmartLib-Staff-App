import 'dart:async';
import 'package:smartlib_staff_app/data/model/book.dart';
import 'package:smartlib_staff_app/data/model/enum/genre.dart';
import 'package:smartlib_staff_app/data/model/enum/language.dart';

class MockBookRepository {
  static final MockBookRepository _instance = MockBookRepository._internal();
  factory MockBookRepository() => _instance;

  MockBookRepository._internal();

  final List<Book> _books = [
    Book(
      bookId: 1,
      title: "The Great Gatsby",
      author: "F. Scott Fitzgerald",
      genre: Genre.fiction,
      language: Language.english,
      totalCopies: 5,
      availableCopies: 3,
      shelfRow: 1,
      shelfCabinet: 5,
      shelfNumber: 10,
    ),
    Book(
      bookId: 2,
      title: "1984",
      author: "George Orwell",
      genre: Genre.scifi,
      language: Language.english,
      totalCopies: 4,
      availableCopies: 0,
      shelfRow: 2,
      shelfCabinet: 3,
      shelfNumber: 15,
    ),
    Book(
      bookId: 3,
      title: "To Kill a Mockingbird",
      author: "Harper Lee",
      genre: Genre.fiction,
      language: Language.english,
      totalCopies: 6,
      availableCopies: 4,
      shelfRow: 1,
      shelfCabinet: 8,
      shelfNumber: 5,
    ),
    Book(
      bookId: 4,
      title: "Pride and Prejudice",
      author: "Jane Austen",
      genre: Genre.romance,
      language: Language.english,
      totalCopies: 3,
      availableCopies: 2,
      shelfRow: 3,
      shelfCabinet: 2,
      shelfNumber: 12,
    ),
  ];

  Future<List<Book>> getAllBooks({String? search, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    Iterable<Book> result = _books;

    // search
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      result = result.where(
        (b) =>
            b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q) ||
            (b.genre?.toString().toLowerCase().contains(q) ?? false),
      );
    }

    // filter
    if (status == "Available") {
      // Only books where all copies are free
      result = result.where((b) => b.availableCopies == b.totalCopies);
    } else if (status == "Reserved") {
      // Some taken, some free
      result = result.where(
        (b) => b.availableCopies < b.totalCopies && b.availableCopies > 0,
      );
    } else if (status == "Taken") {
      // All copies taken
      result = result.where((b) => b.availableCopies == 0);
    }

    return result.toList();
  }

  Future<void> addBook(Book book) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _books.add(book);
  }

  Future<void> deleteBook(int bookId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _books.removeWhere((b) => b.bookId == bookId);
  }

  Future<void> updateBook(Book updated) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _books.indexWhere((b) => b.bookId == updated.bookId);
    if (index != -1) {
      _books[index] = updated;
    }
  }
}
