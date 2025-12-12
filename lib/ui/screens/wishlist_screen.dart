import 'package:flutter/material.dart';

// WISHLIST SCREEN
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Wishlist Requests')),
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
                    DropdownMenuItem(value: 'All', child: Text('All Requests')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'Acquired',
                      child: Text('Acquired'),
                    ),
                    DropdownMenuItem(
                      value: 'Rejected',
                      child: Text('Rejected'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _WishlistCard(
                  memberName: 'Alice Johnson',
                  memberId: 'M1000',
                  bookTitle: 'The Silent Patient',
                  author: 'Alex Michaelides',
                  requestDate: DateTime.now().subtract(const Duration(days: 5)),
                  status: WishlistStatus.pending,
                  notes: 'Popular psychological thriller',
                  onAcquire: () => _markAsAcquired(context),
                  onReject: () => _rejectRequest(context),
                ),
                const SizedBox(height: 12),
                _WishlistCard(
                  memberName: 'Michael Brown',
                  memberId: 'M1001',
                  bookTitle: 'Educated',
                  author: 'Tara Westover',
                  requestDate: DateTime.now().subtract(
                    const Duration(days: 12),
                  ),
                  status: WishlistStatus.pending,
                  notes: 'Memoir - requested by multiple members',
                  onAcquire: () => _markAsAcquired(context),
                  onReject: () => _rejectRequest(context),
                ),
                const SizedBox(height: 12),
                _WishlistCard(
                  memberName: 'Sarah Davis',
                  memberId: 'M1002',
                  bookTitle: 'Atomic Habits',
                  author: 'James Clear',
                  requestDate: DateTime.now().subtract(
                    const Duration(days: 20),
                  ),
                  status: WishlistStatus.acquired,
                  notes: 'Self-help book',
                  onAcquire: () {},
                  onReject: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _markAsAcquired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Acquired'),
        content: const Text(
          'Has this book been acquired and added to the library?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Book marked as acquired')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _rejectRequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to reject this wishlist request?',
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Enter reason (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Request rejected')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

enum WishlistStatus { pending, acquired, rejected }

class _WishlistCard extends StatelessWidget {
  final String memberName;
  final String memberId;
  final String bookTitle;
  final String author;
  final DateTime requestDate;
  final WishlistStatus status;
  final String notes;
  final VoidCallback onAcquire;
  final VoidCallback onReject;

  const _WishlistCard({
    required this.memberName,
    required this.memberId,
    required this.bookTitle,
    required this.author,
    required this.requestDate,
    required this.status,
    required this.notes,
    required this.onAcquire,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (status) {
      case WishlistStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case WishlistStatus.acquired:
        statusColor = Colors.green;
        statusText = 'Acquired';
        break;
      case WishlistStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
    }

    final daysAgo = DateTime.now().difference(requestDate).inDays;

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
                      Text(
                        'by $author',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Requested by: $memberName ($memberId)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text('$daysAgo days ago'),
                    ],
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notes,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (status == WishlistStatus.pending) ...[
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
                    onPressed: onAcquire,
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as Acquired'),
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
