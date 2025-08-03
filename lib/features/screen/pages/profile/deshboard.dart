import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color.onSurface,
            ),
          ),
        ),
        toolbarHeight: 60,
        actions: [
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Iconsax.notification),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _dashboardCard(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet Balance',
                    value: '৳12,345.67',
                    subtitle: '+20.1% from last month',
                    width: cardWidth,
                  ),
                  _dashboardCard(
                    context,
                    icon: Icons.work_outline,
                    title: 'Active Jobs',
                    value: '+5',
                    subtitle: '+1 since last week',
                    width: cardWidth,
                  ),
                  _dashboardCard(
                    context,
                    icon: Icons.star_border,
                    title: 'Your Rating',
                    value: '4.8 ⭐',
                    subtitle: 'Based on 24 reviews',
                    width: cardWidth,
                  ),
                  _dashboardCard(
                    context,
                    icon: Icons.military_tech_outlined,
                    title: 'Worker Level',
                    value: 'Silver',
                    subtitle: '3 jobs away from Gold',
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _sectionCard(
            context,
            title: 'Earnings Overview',
            subtitle: 'Your earnings over the last 6 months.',
            child: SizedBox(height: 200, child: _buildBarChart(context)),
          ),
          const SizedBox(height: 20),
          _sectionCard(
            context,
            title: 'Recent Activity',
            subtitle: 'You have successfully completed 3 jobs this week.',
            child: Column(
              children: const [
                ActivityTile('Shahidul Islam', 'Plumbing for kitchen sink', '৳1,999.00'),
                ActivityTile('Anisul Khan', 'Electrical wiring for new office', '৳3,900.00'),
                ActivityTile('Fatima Rahman', 'House cleaning (weekly)', '৳2,999.00'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionCard(
            context,
            title: 'Daily Skill Tip',
            subtitle: 'Always double-check your electrical connections for safety.',
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Safety first! Before starting any electrical work, make sure the main power is turned off at the circuit breaker. '
                'Use a voltage tester to confirm there is no live current. This simple step can prevent serious injuries.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required double width,
  }) {
    final color = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Card(
        color: color.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(icon, size: 20, color: color.primary),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 14, color: color.onSurface)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: color.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final color = Theme.of(context).colorScheme;

    return Card(
      color: color.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color.onSurface)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 13, color: color.onSurfaceVariant)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final barGroups = [1000, 15500, 18000, 22000, 13000, 26000]
        .asMap()
        .entries
        .map(
          (entry) => BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                width: 18,
                borderRadius: BorderRadius.circular(4),
                color: color.primary,
              ),
            ],
          ),
        )
        .toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 42)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value.toInt() < 0 || value.toInt() >= months.length) return const SizedBox.shrink();
                return Text(months[value.toInt()], style: TextStyle(fontSize: 10, color: color.onSurface));
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final String name;
  final String task;
  final String amount;

  const ActivityTile(this.name, this.task, this.amount, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.primary.withOpacity(0.1),
        child: Icon(Icons.person, color: color.primary),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: color.onSurface)),
      subtitle: Text(task, style: TextStyle(color: color.onSurfaceVariant)),
      trailing: Text(
        '+$amount',
        style: TextStyle(fontWeight: FontWeight.bold, color: color.onSurface),
      ),
    );
  }
}
