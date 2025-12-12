import 'package:smartlib_staff_app/data/model/enum/book_status.dart';

class BookCopy {
  final int copyId;
  final int bookId;
  final BookStatus status;
  final int? borrowerId;
  final DateTime? dueDate;
  final int? reservationId;

  BookCopy({
    required this.copyId,
    required this.bookId,
    required this.status,
    this.borrowerId,
    this.dueDate,
    this.reservationId,
  });

  factory BookCopy.fromMap(Map<String, dynamic> map) {
    return BookCopy(
      copyId: map['copy_id'],
      bookId: map['book_id'],
      status: BookStatus.fromString(map['status']),
      borrowerId: map['borrower_id'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      reservationId: map['reservation_id'],
    );
  }
}
