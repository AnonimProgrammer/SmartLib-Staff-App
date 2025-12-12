import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh dashboard data
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards Row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Books',
                    value: '2,345',
                    icon: Icons.book,
                    color: const Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Active Members',
                    value: '487',
                    icon: Icons.people,
                    color: const Color(0xFF6D4C41),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Books Borrowed',
                    value: '156',
                    icon: Icons.library_books,
                    color: const Color(0xFF8D6E63),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Overdue Items',
                    value: '23',
                    icon: Icons.warning_amber,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity and Quick Actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Activity
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _ActivityItem(
                            icon: Icons.person_add,
                            title: 'New member registered',
                            subtitle: 'John Doe joined the library',
                            time: '5 minutes ago',
                          ),
                          const Divider(),
                          _ActivityItem(
                            icon: Icons.book,
                            title: 'Book borrowed',
                            subtitle: 'The Great Gatsby by Alice Smith',
                            time: '15 minutes ago',
                          ),
                          const Divider(),
                          _ActivityItem(
                            icon: Icons.assignment_return,
                            title: 'Book returned',
                            subtitle: '1984 by Bob Johnson',
                            time: '1 hour ago',
                          ),
                          const Divider(),
                          _ActivityItem(
                            icon: Icons.event_note,
                            title: 'New reservation',
                            subtitle: 'To Kill a Mockingbird by Sarah Williams',
                            time: '2 hours ago',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Quick Actions
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _QuickActionButton(
                            icon: Icons.add_circle_outline,
                            label: 'Add New Book',
                            onPressed: () {},
                          ),
                          const SizedBox(height: 12),
                          _QuickActionButton(
                            icon: Icons.person_add_outlined,
                            label: 'Register Member',
                            onPressed: () {},
                          ),
                          const SizedBox(height: 12),
                          _QuickActionButton(
                            icon: Icons.qr_code_scanner,
                            label: 'Scan Book',
                            onPressed: () {},
                          ),
                          const SizedBox(height: 12),
                          _QuickActionButton(
                            icon: Icons.notifications_outlined,
                            label: 'Send Notifications',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Popular Books and Overdue Members
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Popular Books
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Most Popular Books',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              Chip(
                                label: const Text('This Month'),
                                backgroundColor: const Color(0xFFEFEBE9),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _PopularBookItem(
                            rank: 1,
                            title: 'The Great Gatsby',
                            author: 'F. Scott Fitzgerald',
                            borrowCount: 45,
                          ),
                          const SizedBox(height: 12),
                          _PopularBookItem(
                            rank: 2,
                            title: 'To Kill a Mockingbird',
                            author: 'Harper Lee',
                            borrowCount: 38,
                          ),
                          const SizedBox(height: 12),
                          _PopularBookItem(
                            rank: 3,
                            title: '1984',
                            author: 'George Orwell',
                            borrowCount: 35,
                          ),
                          const SizedBox(height: 12),
                          _PopularBookItem(
                            rank: 4,
                            title: 'Pride and Prejudice',
                            author: 'Jane Austen',
                            borrowCount: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Overdue Members
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Overdue Members',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '23 Total',
                                  style: TextStyle(
                                    color: Color(0xFFD32F2F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _OverdueMemberItem(
                            name: 'Alice Johnson',
                            bookTitle: 'The Catcher in the Rye',
                            daysOverdue: 5,
                            fine: 25.0,
                          ),
                          const SizedBox(height: 12),
                          _OverdueMemberItem(
                            name: 'Michael Brown',
                            bookTitle: 'Brave New World',
                            daysOverdue: 3,
                            fine: 15.0,
                          ),
                          const SizedBox(height: 12),
                          _OverdueMemberItem(
                            name: 'Sarah Davis',
                            bookTitle: 'The Hobbit',
                            daysOverdue: 8,
                            fine: 40.0,
                          ),
                          const SizedBox(height: 12),
                          _OverdueMemberItem(
                            name: 'James Wilson',
                            bookTitle: 'Fahrenheit 451',
                            daysOverdue: 2,
                            fine: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEBE9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF3E2723), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        side: const BorderSide(color: Color(0xFF6D4C41)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3E2723)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3E2723),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularBookItem extends StatelessWidget {
  final int rank;
  final String title;
  final String author;
  final int borrowCount;

  const _PopularBookItem({
    required this.rank,
    required this.title,
    required this.author,
    required this.borrowCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF3E2723),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                author,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEBE9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$borrowCount borrows',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3E2723),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverdueMemberItem extends StatelessWidget {
  final String name;
  final String bookTitle;
  final int daysOverdue;
  final double fine;

  const _OverdueMemberItem({
    required this.name,
    required this.bookTitle,
    required this.daysOverdue,
    required this.fine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '$daysOverdue days',
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            bookTitle,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Fine: \$${fine.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
