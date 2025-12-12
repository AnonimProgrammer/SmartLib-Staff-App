import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
            tooltip: 'Export All Reports',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Row(
              children: [
                const Text(
                  'Report Period:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Monthly', label: Text('Monthly')),
                    ButtonSegment(value: 'Quarterly', label: Text('Quarterly')),
                    ButtonSegment(value: 'Yearly', label: Text('Yearly')),
                  ],
                  selected: {_selectedPeriod},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedPeriod = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Report Cards
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _ReportCard(
                  title: 'Most Popular Books',
                  icon: Icons.trending_up,
                  color: const Color(0xFF3E2723),
                  onView: () => _showPopularBooksReport(context),
                  onExport: () {},
                ),
                _ReportCard(
                  title: 'Member Activity',
                  icon: Icons.people,
                  color: const Color(0xFF6D4C41),
                  onView: () {},
                  onExport: () {},
                ),
                _ReportCard(
                  title: 'Overdue Analysis',
                  icon: Icons.warning_amber,
                  color: const Color(0xFFD32F2F),
                  onView: () {},
                  onExport: () {},
                ),
                _ReportCard(
                  title: 'Revenue from Fines',
                  icon: Icons.attach_money,
                  color: const Color(0xFF388E3C),
                  onView: () {},
                  onExport: () {},
                ),
                _ReportCard(
                  title: 'Genre Distribution',
                  icon: Icons.pie_chart,
                  color: const Color(0xFF1976D2),
                  onView: () {},
                  onExport: () {},
                ),
                _ReportCard(
                  title: 'Circulation Statistics',
                  icon: Icons.swap_horiz,
                  color: const Color(0xFF8E24AA),
                  onView: () {},
                  onExport: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Stats Summary
            const Text(
              'Quick Statistics Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Total Books Borrowed This Month',
                      value: '456',
                      trend: '+12%',
                      isPositive: true,
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'New Members Registered',
                      value: '28',
                      trend: '+8%',
                      isPositive: true,
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'Average Books per Member',
                      value: '2.4',
                      trend: '-3%',
                      isPositive: false,
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'Return Rate (On Time)',
                      value: '87%',
                      trend: '+5%',
                      isPositive: true,
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'Total Fines Collected',
                      value: '\$1,245',
                      trend: '-15%',
                      isPositive: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopularBooksReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Most Popular Books - December 2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _PopularBookRow(rank: 1, title: 'The Great Gatsby', count: 45),
              _PopularBookRow(
                rank: 2,
                title: 'To Kill a Mockingbird',
                count: 38,
              ),
              _PopularBookRow(rank: 3, title: '1984', count: 35),
              _PopularBookRow(rank: 4, title: 'Pride and Prejudice', count: 32),
              _PopularBookRow(
                rank: 5,
                title: 'The Catcher in the Rye',
                count: 28,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Export Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onView;
  final VoidCallback onExport;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onView,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, size: 20),
                    onPressed: onExport,
                    tooltip: 'Export',
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onView, child: const Text('View Report')),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;

  const _StatRow({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 15)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isPositive
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFD32F2F),
                ),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularBookRow extends StatelessWidget {
  final int rank;
  final String title;
  final int count;

  const _PopularBookRow({
    required this.rank,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEBE9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count borrows',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
