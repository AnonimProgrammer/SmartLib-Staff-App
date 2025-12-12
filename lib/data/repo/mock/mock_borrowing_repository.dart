import 'dart:async';

import 'package:smartlib_staff_app/data/model/borrowing.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_member_repository.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_book_repository.dart';

class MockBorrowingRepository {
  static final MockBorrowingRepository _instance =
      MockBorrowingRepository._internal();
  factory MockBorrowingRepository() => _instance;
  MockBorrowingRepository._internal();

  final MockMemberRepository _memberRepo = MockMemberRepository();
  final MockBookRepository _bookRepo = MockBookRepository();

  /// In-memory borrowings
  final List<Borrowing> _borrowings = [
    // Active
    Borrowing(
      borrowId: 1,
      memberId: 1000,
      copyId: 1, // using bookId as copyId in mock
      borrowDate: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().add(const Duration(days: 9)),
      isOverdue: false,
    ),
    // Due soon
    Borrowing(
      borrowId: 2,
      memberId: 1001,
      copyId: 2,
      borrowDate: DateTime.now().subtract(const Duration(days: 12)),
      dueDate: DateTime.now().add(const Duration(days: 2)),
      isOverdue: false,
    ),
    // Overdue
    Borrowing(
      borrowId: 3,
      memberId: 1002,
      copyId: 3,
      borrowDate: DateTime.now().subtract(const Duration(days: 20)),
      dueDate: DateTime.now().subtract(const Duration(days: 6)),
      isOverdue: true,
    ),
  ];

  Future<List<Borrowing>> getActiveBorrowings({
    bool dueSoonOnly = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final now = DateTime.now();
    Iterable<Borrowing> result = _borrowings.where((b) => b.returnDate == null);

    if (dueSoonOnly) {
      result = result.where((b) {
        final diff = b.dueDate.difference(now).inDays;
        return diff >= 0 && diff <= 3;
      });
    }

    return result.toList();
  }

  Future<List<Borrowing>> getActiveBorrowingsForMember(int memberId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _borrowings
        .where((b) => b.memberId == memberId && b.returnDate == null)
        .toList();
  }

  Future<Borrowing?> findActiveBorrowingByBookId(int bookId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _borrowings.firstWhere(
        (b) => b.copyId == bookId && b.returnDate == null,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Borrowing?> createBorrowing({
    required int memberId,
    required int bookId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Simple rule: member must exist, book must exist
    final members = await _memberRepo.getAllMembers();
    final books = await _bookRepo.getAllBooks();

    final member = members.where((m) => m.memberId == memberId).firstOrNull;
    final book = books.where((b) => b.bookId == bookId).firstOrNull;

    if (member == null || book == null) return null;

    final activeForMember = await getActiveBorrowingsForMember(memberId);
    // soft business rule: max 3 active at a time
    if (activeForMember.length >= 3) return null;

    // In real app we’d check copies; here we just allow if book exists
    final newBorrowId =
        (_borrowings
            .map((b) => b.borrowId)
            .fold<int>(0, (prev, next) => prev > next ? prev : next)) +
        1;

    final now = DateTime.now();
    final newBorrowing = Borrowing(
      borrowId: newBorrowId,
      memberId: memberId,
      copyId: bookId,
      borrowDate: now,
      dueDate: now.add(const Duration(days: 14)),
      isOverdue: false,
    );

    _borrowings.add(newBorrowing);
    return newBorrowing;
  }

  Future<void> markReturned(int borrowId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _borrowings.indexWhere((b) => b.borrowId == borrowId);
    if (index != -1) {
      final b = _borrowings[index];
      _borrowings[index] = Borrowing(
        borrowId: b.borrowId,
        memberId: b.memberId,
        copyId: b.copyId,
        borrowDate: b.borrowDate,
        returnDate: DateTime.now(),
        dueDate: b.dueDate,
        isOverdue: b.dueDate.isBefore(DateTime.now()),
      );
    }
  }
}

/// Tiny extension to avoid try/catch spam
extension FirstOrNullExt<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
