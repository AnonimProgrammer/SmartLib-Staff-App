class Borrowing {
  final int borrowId;
  final int memberId;
  final int copyId;
  final DateTime borrowDate;
  final DateTime? returnDate;
  final DateTime dueDate;
  final bool isOverdue;

  Borrowing({
    required this.borrowId,
    required this.memberId,
    required this.copyId,
    required this.borrowDate,
    this.returnDate,
    required this.dueDate,
    required this.isOverdue,
  });

  factory Borrowing.fromMap(Map<String, dynamic> map) {
    return Borrowing(
      borrowId: map['borrow_id'],
      memberId: map['member_id'],
      copyId: map['copy_id'],
      borrowDate: DateTime.parse(map['borrow_date']),
      returnDate: map['return_date'] != null
          ? DateTime.parse(map['return_date'])
          : null,
      dueDate: DateTime.parse(map['due_date']),
      isOverdue: map['is_overdue'] ?? false,
    );
  }
}
