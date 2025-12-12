import 'package:flutter/material.dart';

class OverdueManagementScreen extends StatefulWidget {
  const OverdueManagementScreen({super.key});

  @override
  State<OverdueManagementScreen> createState() =>
      _OverdueManagementScreenState();
}

class _OverdueManagementScreenState extends State<OverdueManagementScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overdue & Fines Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: () => _showBulkNotificationDialog(context),
            tooltip: 'Send Bulk Notifications',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
            tooltip: 'Export Report',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Overdue',
                    value: '23',
                    color: const Color(0xFFD32F2F),
                    icon: Icons.warning_amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Total Fines',
                    value: '\$1,245',
                    color: const Color(0xFFF57C00),
                    icon: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Unpaid Fines',
                    value: '\$890',
                    color: const Color(0xFF8E24AA),
                    icon: Icons.credit_card,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Notified Today',
                    value: '12',
                    color: const Color(0xFF1976D2),
                    icon: Icons.notifications,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Overdue')),
                    DropdownMenuItem(value: '1-7', child: Text('1-7 days')),
                    DropdownMenuItem(value: '8-14', child: Text('8-14 days')),
                    DropdownMenuItem(value: '15+', child: Text('15+ days')),
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

          // Overdue List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OverdueCard(
                  memberName: 'Alice Johnson',
                  memberId: 'M1000',
                  email: 'alice.j@email.com',
                  phone: '+1 234 567 8900',
                  bookTitle: 'The Catcher in the Rye',
                  daysOverdue: 5,
                  fine: 25.0,
                  lastNotified: DateTime.now().subtract(
                    const Duration(days: 2),
                  ),
                  onNotify: () => _sendNotification(context, 'Alice Johnson'),
                  onMarkFine: () => _markFine(context),
                  onWaiveFine: () => _waiveFine(context),
                ),
                const SizedBox(height: 12),
                _OverdueCard(
                  memberName: 'Michael Brown',
                  memberId: 'M1001',
                  email: 'michael.b@email.com',
                  phone: '+1 234 567 8901',
                  bookTitle: 'Brave New World',
                  daysOverdue: 3,
                  fine: 15.0,
                  lastNotified: DateTime.now().subtract(
                    const Duration(days: 1),
                  ),
                  onNotify: () => _sendNotification(context, 'Michael Brown'),
                  onMarkFine: () => _markFine(context),
                  onWaiveFine: () => _waiveFine(context),
                ),
                const SizedBox(height: 12),
                _OverdueCard(
                  memberName: 'Sarah Davis',
                  memberId: 'M1002',
                  email: 'sarah.d@email.com',
                  phone: '+1 234 567 8902',
                  bookTitle: 'The Hobbit',
                  daysOverdue: 8,
                  fine: 40.0,
                  lastNotified: DateTime.now().subtract(
                    const Duration(days: 5),
                  ),
                  onNotify: () => _sendNotification(context, 'Sarah Davis'),
                  onMarkFine: () => _markFine(context),
                  onWaiveFine: () => _waiveFine(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendNotification(BuildContext context, String memberName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send overdue notification to $memberName?'),
            const SizedBox(height: 16),
            const Text('Select notification method:'),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Email'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('SMS'),
              value: true,
              onChanged: (value) {},
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification sent successfully')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _markFine(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Fine as Paid'),
        content: const Text('Confirm that this fine has been paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fine marked as paid')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _waiveFine(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Waive Fine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to waive this fine?'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Enter reason for waiving',
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
              ).showSnackBar(const SnackBar(content: Text('Fine waived')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Waive'),
          ),
        ],
      ),
    );
  }

  void _showBulkNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Bulk Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send notifications to all overdue members?'),
            const SizedBox(height: 16),
            Text(
              '23 members will be notified',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Email'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('SMS'),
              value: true,
              onChanged: (value) {},
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bulk notifications sent')),
              );
            },
            child: const Text('Send All'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverdueCard extends StatelessWidget {
  final String memberName;
  final String memberId;
  final String email;
  final String phone;
  final String bookTitle;
  final int daysOverdue;
  final double fine;
  final DateTime lastNotified;
  final VoidCallback onNotify;
  final VoidCallback onMarkFine;
  final VoidCallback onWaiveFine;

  const _OverdueCard({
    required this.memberName,
    required this.memberId,
    required this.email,
    required this.phone,
    required this.bookTitle,
    required this.daysOverdue,
    required this.fine,
    required this.lastNotified,
    required this.onNotify,
    required this.onMarkFine,
    required this.onWaiveFine,
  });

  @override
  Widget build(BuildContext context) {
    final daysSinceNotified = DateTime.now().difference(lastNotified).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber,
                    color: Color(0xFFD32F2F),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memberName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(memberId, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$daysOverdue days overdue',
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.book,
                        size: 18,
                        color: Color(0xFF6D4C41),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              bookTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Fine Amount',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${fine.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              email,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.notifications, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Last notified $daysSinceNotified days ago',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onWaiveFine,
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  label: const Text('Waive'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onMarkFine,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Mark Paid'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onNotify,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Notify'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
