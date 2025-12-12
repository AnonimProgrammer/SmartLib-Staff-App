import 'package:flutter/material.dart';
import 'package:smartlib_staff_app/data/model/borrowing.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_book_repository.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_borrowing_repository.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_member_repository.dart';
import 'package:smartlib_staff_app/ui/components/borrow_book_form.dart';
import 'package:smartlib_staff_app/ui/components/return_book_form.dart';

class BorrowReturnScreen extends StatefulWidget {
  const BorrowReturnScreen({super.key});

  @override
  State<BorrowReturnScreen> createState() => _BorrowReturnScreenState();
}

class _BorrowReturnScreenState extends State<BorrowReturnScreen> {
  bool _isBorrowMode = true;

  final MockBorrowingRepository _borrowingRepo = MockBorrowingRepository();
  final MockMemberRepository _memberRepo = MockMemberRepository();
  final MockBookRepository _bookRepo = MockBookRepository();

  bool _dueSoonOnly = false;
  late Future<List<Borrowing>> _futureBorrowings;

  @override
  void initState() {
    super.initState();
    _futureBorrowings = _loadBorrowings();
  }

  Future<List<Borrowing>> _loadBorrowings() {
    return _borrowingRepo.getActiveBorrowings(dueSoonOnly: _dueSoonOnly);
  }

  void refreshBorrowings() {
    setState(() {
      _futureBorrowings = _loadBorrowings();
    });
  }

  TransactionStatus _statusFromBorrowing(Borrowing b) {
    final now = DateTime.now();
    if (b.dueDate.isBefore(now)) return TransactionStatus.overdue;
    final diff = b.dueDate.difference(now).inDays;
    if (diff <= 3) return TransactionStatus.dueSoon;
    return TransactionStatus.active;
  }

  Future<String> _resolveMemberName(int memberId) async {
    final members = await _memberRepo.getAllMembers();
    final m = members.where((x) => x.memberId == memberId).firstOrNull;
    if (m == null) return "Unknown Member";
    return "${m.firstName} ${m.lastName}";
  }

  Future<String> _resolveBookTitle(int bookId) async {
    final books = await _bookRepo.getAllBooks();
    final b = books.where((x) => x.bookId == bookId).firstOrNull;
    return b?.title ?? "Unknown Book";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrow / Return Management')),
      body: Row(
        children: [
          // Left Panel - Mode Selection and Form
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mode Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEBE9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            label: 'Borrow Book',
                            icon: Icons.library_books,
                            isSelected: _isBorrowMode,
                            onTap: () => setState(() => _isBorrowMode = true),
                          ),
                        ),
                        Expanded(
                          child: _ModeButton(
                            label: 'Return Book',
                            icon: Icons.assignment_return,
                            isSelected: !_isBorrowMode,
                            onTap: () => setState(() => _isBorrowMode = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Content
                  Expanded(
                    child: _isBorrowMode
                        ? BorrowBookForm(onChanged: refreshBorrowings)
                        : ReturnBookForm(onChanged: refreshBorrowings),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),

          // Right Panel - Active Transactions
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: !_dueSoonOnly,
                            onSelected: (value) {
                              setState(() {
                                _dueSoonOnly = false;
                                _futureBorrowings = _loadBorrowings();
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Due Soon'),
                            selected: _dueSoonOnly,
                            onSelected: (value) {
                              setState(() {
                                _dueSoonOnly = true;
                                _futureBorrowings = _loadBorrowings();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Borrowing>>(
                      future: _futureBorrowings,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final borrowings = snapshot.data ?? [];

                        if (borrowings.isEmpty) {
                          return const Center(
                            child: Text('No active transactions'),
                          );
                        }

                        return ListView.separated(
                          itemCount: borrowings.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final b = borrowings[index];
                            final status = _statusFromBorrowing(b);

                            return FutureBuilder<List<String>>(
                              future: Future.wait([
                                _resolveMemberName(b.memberId),
                                _resolveBookTitle(b.copyId),
                              ]),
                              builder: (context, snap) {
                                if (!snap.hasData) {
                                  return const Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(30),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  );
                                }

                                final memberName = snap.data![0];
                                final bookTitle = snap.data![1];

                                return _TransactionCard(
                                  memberName: memberName,
                                  memberId: "M${b.memberId}",
                                  bookTitle: bookTitle,
                                  borrowDate: b.borrowDate,
                                  dueDate: b.dueDate,
                                  status: status,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3E2723) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF6D4C41),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF6D4C41),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

enum TransactionStatus { active, dueSoon, overdue }

class _TransactionCard extends StatelessWidget {
  final String memberName;
  final String memberId;
  final String bookTitle;
  final DateTime borrowDate;
  final DateTime dueDate;
  final TransactionStatus status;

  const _TransactionCard({
    required this.memberName,
    required this.memberId,
    required this.bookTitle,
    required this.borrowDate,
    required this.dueDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (status) {
      case TransactionStatus.active:
        statusColor = Colors.blue;
        statusText = 'Active';
        break;
      case TransactionStatus.dueSoon:
        statusColor = Colors.orange;
        statusText = 'Due Soon';
        break;
      case TransactionStatus.overdue:
        statusColor = Colors.red;
        statusText = 'Overdue';
        break;
    }

    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    final daysText = daysUntilDue < 0
        ? '${-daysUntilDue} days overdue'
        : 'Due in $daysUntilDue days';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$memberName • $memberId',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  daysText,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
