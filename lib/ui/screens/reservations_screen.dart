import 'package:flutter/material.dart';
import 'package:smartlib_staff_app/data/model/book.dart' show Book;
import 'package:smartlib_staff_app/data/model/member.dart';
import 'package:smartlib_staff_app/data/model/reservation.dart';

import 'package:smartlib_staff_app/data/repo/mock/mock_reservation_repository.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_member_repository.dart';
import 'package:smartlib_staff_app/data/repo/mock/mock_book_repository.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  String _selectedFilter = 'Pending';

  final MockReservationRepository _repo = MockReservationRepository();
  final MockMemberRepository _memberRepo = MockMemberRepository();
  final MockBookRepository _bookRepo = MockBookRepository();

  late Future<List<Reservation>> _futureReservations;

  @override
  void initState() {
    super.initState();
    _futureReservations = _loadReservations();
  }

  ReservationStatus? _statusFilterFromLabel(String label) {
    switch (label) {
      case 'Pending':
        return ReservationStatus.pending;
      case 'Approved':
        return ReservationStatus.approved;
      case 'Fulfilled':
        return ReservationStatus.fulfilled;
      case 'Expired':
        return ReservationStatus.expired;
      default:
        return null;
    }
  }

  Future<List<Reservation>> _loadReservations() {
    return _repo.getReservations(
      statusFilter: _statusFilterFromLabel(_selectedFilter),
    );
  }

  Future<String> _resolveMemberName(String memberId) async {
    final members = await _memberRepo.getAllMembers();
    final m = members.firstWhere(
      (x) => x.memberId.toString() == memberId.substring(1),
      orElse: () => Member(
        memberId: 0,
        firstName: "Unknown",
        lastName: "Member",
        email: "",
        phone: "",
        registrationDate: DateTime.now(),
        outstandingFines: 0,
      ),
    );
    return "${m.firstName} ${m.lastName}";
  }

  Future<String> _resolveBookTitle(String bookId) async {
    final books = await _bookRepo.getAllBooks();
    final b = books.firstWhere(
      (x) => x.bookId.toString() == bookId.substring(1),
      orElse: () => Book(
        bookId: 0,
        title: "Unknown Book",
        author: "",
        genre: null,
        language: null,
        totalCopies: 0,
        availableCopies: 0,
        shelfRow: 0,
        shelfCabinet: 0,
        shelfNumber: 0,
      ),
    );
    return b.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservation Management')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: const [
                    DropdownMenuItem(
                      value: 'Pending',
                      child: Text('Pending Approval'),
                    ),
                    DropdownMenuItem(
                      value: 'Approved',
                      child: Text('Approved'),
                    ),
                    DropdownMenuItem(
                      value: 'Fulfilled',
                      child: Text('Fulfilled'),
                    ),
                    DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                      _futureReservations = _loadReservations();
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Reservation>>(
              future: _futureReservations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading reservations',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }

                final reservations = snapshot.data ?? [];

                if (reservations.isEmpty) {
                  return const Center(child: Text('No reservations found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reservations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final r = reservations[index];

                    return FutureBuilder<List<String>>(
                      future: Future.wait([
                        _resolveMemberName(r.memberId),
                        _resolveBookTitle(r.bookId),
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }
                        final memberName = snapshot.data![0];
                        final bookTitle = snapshot.data![1];

                        return _ReservationCard(
                          memberName: memberName,
                          memberId: r.memberId,
                          bookTitle: bookTitle,
                          reservationDate: r.reservationDate,
                          expiryDate: r.expiryDate,
                          status: r.status,
                          onApprove: () => _approveReservation(context, r),
                          onReject: () => _rejectReservation(context, r),
                          onFulfill: () => _fulfillReservation(context, r),
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
    );
  }

  void _approveReservation(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Reservation'),
        content: const Text(
          'Approve this reservation? The member will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _repo.updateStatus(
                reservation.id,
                ReservationStatus.approved,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reservation approved')),
                );
                setState(() {
                  _futureReservations = _loadReservations();
                });
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectReservation(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Reservation'),
        content: const Text(
          'Are you sure you want to reject this reservation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _repo.updateStatus(
                reservation.id,
                ReservationStatus.cancelled,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reservation rejected')),
                );
                setState(() {
                  _futureReservations = _loadReservations();
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _fulfillReservation(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fulfill Reservation'),
        content: const Text(
          'Mark this reservation as fulfilled? The member has picked up the book.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _repo.updateStatus(
                reservation.id,
                ReservationStatus.fulfilled,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reservation fulfilled')),
                );
                setState(() {
                  _futureReservations = _loadReservations();
                });
              }
            },
            child: const Text('Fulfill'),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final String memberName;
  final String memberId;
  final String bookTitle;
  final DateTime reservationDate;
  final DateTime expiryDate;
  final ReservationStatus status;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onFulfill;

  const _ReservationCard({
    required this.memberName,
    required this.memberId,
    required this.bookTitle,
    required this.reservationDate,
    required this.expiryDate,
    required this.status,
    required this.onApprove,
    required this.onReject,
    required this.onFulfill,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (status) {
      case ReservationStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case ReservationStatus.approved:
        statusColor = Colors.blue;
        statusText = 'Approved';
        break;
      case ReservationStatus.fulfilled:
        statusColor = Colors.green;
        statusText = 'Fulfilled';
        break;
      case ReservationStatus.expired:
        statusColor = Colors.red;
        statusText = 'Expired';
        break;

      case ReservationStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    final hoursUntilExpiry = expiryDate.difference(DateTime.now()).inHours;
    final expiryText = hoursUntilExpiry < 24
        ? 'Expires in $hoursUntilExpiry hours'
        : 'Expires in ${(hoursUntilExpiry / 24).floor()} days';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$memberName • $memberId',
                        style: TextStyle(color: Colors.grey[600]),
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  expiryText,
                  style: TextStyle(
                    color: hoursUntilExpiry < 24
                        ? Colors.orange
                        : Colors.grey[700],
                    fontWeight: hoursUntilExpiry < 24
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (status == ReservationStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ],
              ),
            ] else if (status == ReservationStatus.approved) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: onFulfill,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark as Fulfilled'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
