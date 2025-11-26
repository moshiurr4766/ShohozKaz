import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Custom colors
const Color softCoralBackground = Color(0xFFFFF1ED);
const Color vividOrangeText = Color(0xFFFF5A30);

class AppColors {
  static const Color button = Color(0xFFFE6D4E);
}

class MyWalletScreen extends StatelessWidget {
  final currencyFormat = NumberFormat.currency(locale: 'bn_BD', symbol: '৳');

  final List<Map<String, dynamic>> transactions = [
    {
      'description': 'Payment for plumbing job',
      'amount': 2500,
      'date': '2023-10-26',
      'status': 'Completed',
    },
    {
      'description': 'Withdrawal to bKash',
      'amount': -5000,
      'date': '2023-10-25',
      'status': 'Completed',
    },
    {
      'description': 'Funds added from Nagad',
      'amount': 10000,
      'date': '2023-10-24',
      'status': 'Completed',
    },
    {
      'description': 'Payment for cleaning task',
      'amount': -800,
      'date': '2023-10-22',
      'status': 'Completed',
    },
    {
      'description': 'Pending payment for electrical work',
      'amount': 3500,
      'date': '2023-10-27',
      'status': 'Pending',
    },
  ];

  final List<Map<String, String>> wallets = [
    {'name': 'bKash', 'icon': 'bK'},
    {'name': 'Nagad', 'icon': 'NG'},
    {'name': 'Rocket', 'icon': 'RK'},
  ];

  MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'My Wallet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        toolbarHeight: 60,
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildBalanceOverview(context, isDark),
            const SizedBox(height: 20),
            _buildTransactionHistory(context, isDark),
            const SizedBox(height: 20),
            _buildPaymentMethods(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceOverview(BuildContext context, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Balance Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildBalanceBox("Current Balance", currencyFormat.format(12084), AppColors.button, isDark),
                const SizedBox(width: 8),
                _buildBalanceBox("Pending Earnings", currencyFormat.format(3600), Colors.orange, isDark),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildBalanceBox("Last Transaction", "+ ৳2,500", Colors.green, isDark),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle),
                    label: const Text("Add Funds"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_downward, color: vividOrangeText),
                    label: const Text("Withdraw to bKash", style: TextStyle(color: vividOrangeText)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: vividOrangeText),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: softCoralBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: vividOrangeText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Transaction History →", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceBox(String title, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(flex: 3, child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Amount (৳)", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            ...transactions.map((tx) => _buildTransactionRowStyled(tx)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRowStyled(Map<String, dynamic> tx) {
    Color amountColor = tx['amount'] > 0 ? Colors.green : tx['amount'] < 0 ? Colors.red : Colors.black;
    Color statusBg = tx['status'] == 'Pending' ? Colors.grey.shade300 : Colors.deepPurple.shade100;
    Color statusText = tx['status'] == 'Pending' ? Colors.black87 : Colors.deepPurple;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(tx['description'], style: const TextStyle(fontSize: 11))),
          Expanded(
            flex: 2,
            child: Text(
              (tx['amount'] > 0 ? '' : '-') + currencyFormat.format(tx['amount'].abs()),
              style: TextStyle(color: amountColor, fontWeight: FontWeight.bold,fontSize: 11),
            ),
          ),
          Expanded(flex: 2, child: Text(tx['date'], style: const TextStyle(fontSize: 11))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tx['status'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize:8, fontWeight: FontWeight.w600, color: statusText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Payment Methods", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Connect your mobile wallets.", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
            const SizedBox(height: 16),
            ...wallets.map((wallet) => _buildWalletItem(wallet, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletItem(Map<String, String> wallet, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            child: Text(wallet['icon']!, style: const TextStyle(color: Colors.deepPurple)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(wallet['name']!, style: const TextStyle(fontWeight: FontWeight.w600))),
          OutlinedButton(
            onPressed: () {},
            child: const Text("Connect"),
          ),
        ],
      ),
    );
  }
}
