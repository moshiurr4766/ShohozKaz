import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String jobOrderId;
  final String amount;
  final String posterEmail;

  const PaymentScreen({
    super.key,
    required this.jobOrderId,
    required this.amount,
    required this.posterEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: $jobOrderId', style: TextStyle(color: textColor)),
            const SizedBox(height: 6),
            Text('Pay to: $posterEmail', style: TextStyle(color: textColor)),
            const SizedBox(height: 6),
            Text('Amount: ৳ $amount',
                style: TextStyle(
                    color: textColor, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment flow not implemented.')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Proceed to Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
