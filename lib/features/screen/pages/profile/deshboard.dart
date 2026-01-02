
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<DocumentSnapshot>? _walletSub;

  int walletBalance = 0;
  int totalEarning = 0;
  List<int> monthlyEarnings = List.filled(6, 0);

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final user = _auth.currentUser;
    if (user == null) return;

    _listenWallet(user.uid);
    _loadMonthlyEarnings(user.uid);
  }

  ///HELPERS 

  int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) {
      return int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }

  /// WALLET 

  void _listenWallet(String uid) {
    _walletSub = _db
        .collection('earningWallet')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      final data = doc.data();
      if (data == null || !mounted) return;

      setState(() {
        walletBalance = _parseInt(data['currentBalance']);
        totalEarning = _parseInt(data['totalEarning']);
      });
    });
  }

  /// MONTHLY EARNINGS 
  Future<void> _loadMonthlyEarnings(String uid) async {
    final now = DateTime.now();
    final temp = List<int>.filled(6, 0);

    final snap = await _db
        .collection('completedJobs')
        .where('posterId', isEqualTo: uid)
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final salary = _parseInt(data['salary']);
      final ts = data['completedAt'];

      if (ts is! Timestamp) continue;
      final date = ts.toDate();

      final diff =
          (now.year - date.year) * 12 + (now.month - date.month);

      if (diff >= 0 && diff < 6) {
        temp[5 - diff] += salary;
      }
    }

    if (!mounted) return;
    setState(() => monthlyEarnings = temp);
  }

  @override
  void dispose() {
    _walletSub?.cancel();
    super.dispose();
  }

  /// UI 

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login first")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'Dashboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Iconsax.notification),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// TOP CARDS
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _dashboardCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet Balance',
                    value: '৳$walletBalance',
                    subtitle: 'Available balance',
                    width: width,
                  ),
                  _dashboardCard(
                    icon: Icons.trending_up,
                    title: 'Total Earning',
                    value: '৳$totalEarning',
                    subtitle: 'Lifetime earning',
                    width: width,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          /// BAR CHART
          _sectionCard(
            title: 'Earnings Overview',
            subtitle: 'Last 6 months',
            child: SizedBox(height: 220, child: _buildBarChart()),
          ),

          const SizedBox(height: 20),

          /// GROWTH TIPS
          _sectionCard(
            title: 'Tips for More Growth',
            subtitle: 'Increase your earnings faster',
            child: _growthTips(),
          ),
        ],
      ),
    );
  }

  ///  COMPONENTS 

  Widget _dashboardCard({
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(icon, color: color.primary),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: color.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  ///  BAR CHART 

  Widget _buildBarChart() {
    if (monthlyEarnings.every((e) => e == 0)) {
      return const Center(child: Text("No earnings yet"));
    }

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final color = Theme.of(context).colorScheme;
    final maxValue =
        monthlyEarnings.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxValue * 1.2,
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxValue / 4,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxValue / 4,
              reservedSize: 40,
              getTitlesWidget: (v, _) =>
                  Text("৳${v.toInt()}", style: const TextStyle(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) =>
                  Text(months[v.toInt()], style: const TextStyle(fontSize: 11)),
            ),
          ),
        ),
        barGroups: monthlyEarnings.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                width: 14,
                borderRadius: BorderRadius.circular(6),
                color: color.primary,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// GROWTH TIPS

  Widget _growthTips() {
    return Column(
      children: const [
        _TipTile(
          icon: Icons.star,
          title: "Complete jobs on time",
          subtitle: "Faster completion increases client trust and ratings.",
        ),
        _TipTile(
          icon: Icons.thumb_up,
          title: "Maintain high ratings",
          subtitle: "Better ratings help you get more job requests.",
        ),
        _TipTile(
          icon: Icons.trending_up,
          title: "Accept high-value jobs",
          subtitle: "Choose jobs with better payouts to grow faster.",
        ),
      ],
    );
  }
}

/// TIP TILE 

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TipTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.primary.withOpacity(0.1),
        child: Icon(icon, color: color.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }
}
