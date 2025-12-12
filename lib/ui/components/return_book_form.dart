import 'package:flutter/material.dart';
import 'package:smartlib_staff_app/data/model/book.dart';
import 'package:smartlib_staff_app/data/model/borrowing.dart';
import 'package:smartlib_staff_app/data/model/member.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_book_repository.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_borrowing_repository.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_member_repository.dart';
import 'package:smartlib_staff_app/ui/screens/borrow_return_screen.dart';

class ReturnBookForm extends StatefulWidget {
  final VoidCallback? onChanged;
  const ReturnBookForm({super.key, this.onChanged});

  @override
  State<ReturnBookForm> createState() => _ReturnBookFormState();
}

class _ReturnBookFormState extends State<ReturnBookForm> {
  final _formKey = GlobalKey<FormState>();
  final _bookIdController = TextEditingController();

  final MockBorrowingRepository _borrowingRepo = MockBorrowingRepository();
  final MockMemberRepository _memberRepo = MockMemberRepository();
  final MockBookRepository _bookRepo = MockBookRepository();

  bool _bookVerified = false;

  Borrowing? _borrowing;
  Member? _member;
  Book? _book;

  bool _isOverdue = false;
  double _fine = 0.0;

  // ------------------------- VERIFY LOGIC -----------------------------
  Future<void> _verify() async {
    // run validation
    if (!_formKey.currentState!.validate()) return;

    // reset old state
    setState(() {
      _bookVerified = false;
      _borrowing = null;
      _member = null;
      _book = null;
      _fine = 0;
      _isOverdue = false;
    });

    final raw = _bookIdController.text.trim();
    final idNum = int.parse(raw.substring(1)); // remove B

    final borrowing = await _borrowingRepo.findActiveBorrowingByBookId(idNum);

    if (borrowing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active borrowing for this book')),
      );
      return;
    }

    final members = await _memberRepo.getAllMembers();
    final books = await _bookRepo.getAllBooks();

    T? safeFirstWhere<T>(List<T> list, bool Function(T) test) {
      for (var m in list) {
        if (test(m)) return m;
      }
      return null;
    }

    final m = safeFirstWhere(members, (x) => x.memberId == borrowing.memberId);
    final b = safeFirstWhere(books, (x) => x.bookId == borrowing.copyId);

    if (m == null || b == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Member or Book not found')),
      );
      return;
    }

    final now = DateTime.now();
    final overdueDays = now.isAfter(borrowing.dueDate)
        ? now.difference(borrowing.dueDate).inDays
        : 0;

    setState(() {
      _borrowing = borrowing;
      _member = m;
      _book = b;
      _isOverdue = overdueDays > 0;
      _fine = overdueDays * 0.5;
      _bookVerified = true;
    });
  }

  // --------------------------- UI -----------------------------------
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const Text(
            'Scan or Enter Book ID',
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
                    hintText: 'Example: B1 or B10',
                    prefixIcon: Icon(Icons.book),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Book ID required";
                    }
                    if (!RegExp(r'^B\d+$').hasMatch(value.trim())) {
                      return "Format must be: B1 or B10";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(onPressed: _verify, child: const Text('Verify')),
            ],
          ),

          if (_bookVerified &&
              _borrowing != null &&
              _member != null &&
              _book != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBCAAA4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Return Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  InfoRow(label: 'Book', value: _book!.title),

                  InfoRow(
                    label: 'Member',
                    value:
                        '${_member!.firstName} ${_member!.lastName} (M${_member!.memberId})',
                  ),

                  InfoRow(
                    label: 'Borrowed',
                    value:
                        '${DateTime.now().difference(_borrowing!.borrowDate).inDays} days ago',
                  ),

                  InfoRow(
                    label: 'Due Date',
                    value: _borrowing!.dueDate.toString().split(' ').first,
                  ),

                  const SizedBox(height: 16),

                  if (!_isOverdue) _buildOnTimeBox() else _buildOverdueBox(),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _borrowingRepo.markReturned(_borrowing!.borrowId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book returned successfully')),
                  );

                  widget.onChanged?.call();

                  setState(() {
                    _bookVerified = false;
                    _borrowing = null;
                    _member = null;
                    _book = null;
                  });
                  _bookIdController.clear();
                },
                icon: const Icon(Icons.check),
                label: const Text('Complete Return'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ----------------------- Widgets ---------------------
  Widget _buildOnTimeBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Returned on time – No fine',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Color(0xFFD32F2F)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Overdue return – Fine: \$${_fine.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
