import 'package:flutter/material.dart';
import 'package:smartlib_staff_app/data/model/book.dart';
import 'package:smartlib_staff_app/data/model/member.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_book_repository.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_borrowing_repository.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_member_repository.dart';

class BorrowBookForm extends StatefulWidget {
  final VoidCallback? onChanged;
  const BorrowBookForm({super.key, this.onChanged});

  @override
  State<BorrowBookForm> createState() => _BorrowBookFormState();
}

class _BorrowBookFormState extends State<BorrowBookForm> {
  final _formKey = GlobalKey<FormState>();
  final _memberIdController = TextEditingController();
  final _bookIdController = TextEditingController();

  final MockMemberRepository _memberRepo = MockMemberRepository();
  final MockBookRepository _bookRepo = MockBookRepository();
  final MockBorrowingRepository _borrowingRepo = MockBorrowingRepository();

  bool _memberVerified = false;
  bool _bookVerified = false;
  Member? _member;
  Book? _book;
  int _activeBorrowCount = 0;

  bool get _canBorrow {
    if (!_memberVerified || !_bookVerified) return false;
    if (_member == null || _book == null) return false;
    if (_member!.outstandingFines > 0) return false;
    if (_activeBorrowCount >= 3) return false;
    return true;
  }

  T? safeFirstWhere<T>(List<T> list, bool Function(T) test) {
    for (var m in list) {
      if (test(m)) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const Text(
            'Member Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _memberIdController,
                  decoration: const InputDecoration(
                    labelText: 'Member ID',
                    hintText: 'Enter or scan member ID',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Member ID required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  setState(() {
                    _memberVerified = false;
                    _member = null;
                  });

                  final raw = _memberIdController.text.trim();
                  final memberId = int.parse(raw.substring(1));

                  final members = await _memberRepo.getAllMembers();
                  final m = safeFirstWhere(
                    members,
                    (x) => x.memberId == memberId,
                  );

                  if (m == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Member not found')),
                    );
                    return;
                  }

                  final active = await _borrowingRepo
                      .getActiveBorrowingsForMember(memberId);

                  setState(() {
                    _member = m;
                    _activeBorrowCount = active.length;
                    _memberVerified = true;
                  });
                },
                child: const Text('Verify'),
              ),
            ],
          ),
          if (_memberVerified && _member != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _canBorrow
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _canBorrow
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFD32F2F),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _canBorrow ? Icons.check_circle : Icons.error,
                        color: _canBorrow
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFD32F2F),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _canBorrow ? 'Member Verified' : 'Member Restricted',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _canBorrow
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${_member!.firstName} ${_member!.lastName}'),
                  Text('Current Books: $_activeBorrowCount / 10'),
                  Text(
                    'Outstanding Fines: \$${_member!.outstandingFines.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  if (_canBorrow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Can Borrow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const Text(
                      'Cannot borrow: unpaid fines or book limit reached.',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          const Text(
            'Book Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bookIdController,
                  decoration: const InputDecoration(
                    labelText: 'Book ID',
                    hintText: 'Enter or scan book ID',
                    prefixIcon: Icon(Icons.book),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Book ID required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() {
                    _bookVerified = false;
                    _book = null;
                  });

                  final raw = _bookIdController.text.trim();
                  // EMPTY CHECK
                  if (raw.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter Book ID')),
                    );
                    return;
                  }

                  if (!RegExp(r'^B\d+$').hasMatch(raw)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid format. Use: B1 or B10'),
                      ),
                    );
                    return;
                  }

                  final bookId = int.parse(raw.substring(1));

                  final books = await _bookRepo.getAllBooks();
                  final b = safeFirstWhere(books, (x) => x.bookId == bookId);

                  if (b == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book not found')),
                    );
                    return;
                  }
                  setState(() {
                    _book = b;
                    _bookVerified = true;
                  });
                },
                child: const Text('Verify'),
              ),
            ],
          ),
          if (_bookVerified && _book != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2196F3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle, color: Color(0xFF2196F3)),
                      SizedBox(width: 8),
                      Text(
                        'Book Found',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Title: ${_book!.title}'),
                  Text('Author: ${_book!.author}'),
                  Text(
                    'Location: R${_book!.shelfRow}-C${_book!.shelfCabinet}-S${_book!.shelfNumber}',
                  ),
                  Text(
                    'Available: ${_book!.availableCopies} / ${_book!.totalCopies} copies',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          const Text(
            'Loan Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Borrow Date',
                    hintText: DateTime.now().toString().split(' ')[0],
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    hintText: DateTime.now()
                        .add(const Duration(days: 14))
                        .toString()
                        .split(' ')[0],
                    prefixIcon: const Icon(Icons.event),
                  ),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _canBorrow
                  ? () async {
                      final memberId = _member!.memberId;
                      final bookId = _book!.bookId;

                      final created = await _borrowingRepo.createBorrowing(
                        memberId: memberId,
                        bookId: bookId,
                      );

                      if (created == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to borrow: limit reached or error',
                            ),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Book borrowed successfully'),
                        ),
                      );

                      widget.onChanged?.call();

                      setState(() {
                        _memberVerified = false;
                        _bookVerified = false;
                        _member = null;
                        _book = null;
                        _memberIdController.clear();
                        _bookIdController.clear();
                      });
                    }
                  : null,
              icon: const Icon(Icons.check),
              label: const Text('Complete Borrow'),
            ),
          ),
        ],
      ),
    );
  }
}
