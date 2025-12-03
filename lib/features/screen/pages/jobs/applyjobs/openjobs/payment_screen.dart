
import 'package:flutter/material.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/openjobs/bkash_payment.dart';
//import 'package:bkash/bkash.dart';

class PaymentScreen extends StatefulWidget {
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
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  //final Bkash _bkash = Bkash(logResponse: true);

  final bool _loading = false;
  String? _paymentResult;

  String cleanAmount(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9]'), '');
  }

  //   Future<void> _startBkashPayment() async {
  //     setState(() {
  //       _loading = true;
  //       _paymentResult = null;
  //     });

  //     try {
  //       final response = await _bkash.pay(
  //         context: context,
  //         amount: double.parse(cleanAmount(widget.amount)),
  //         merchantInvoiceNumber: widget.jobOrderId,
  //       );

  //       setState(() {
  //         _paymentResult =
  //             """
  // ✔ Payment Successful
  // Transaction ID: ${response.trxId}
  // Payment ID: ${response.paymentId}
  // Customer: ${response.customerMsisdn}
  // """;
  //       });

  //       Navigator.pop(context, true);
  //     } on BkashFailure catch (e) {
  //       setState(() {
  //         _paymentResult = " Payment failed: ${e.message}";
  //       });
  //     } catch (e) {
  //       setState(() {
  //         _paymentResult = "⚠ Error: $e";
  //       });
  //     } finally {
  //       setState(() => _loading = false);
  //     }
  //   }

  //  SUCCESS HANDLER FOR NAGAD & ROCKET
  void showSuccessPopup(String method) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Check Icon
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 70,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "$method Payment Successful!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Your payment has been processed securely.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close popup
                      Navigator.pop(
                        context,
                        true,
                      ); // Return true to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Summary",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  infoRow("Order ID", widget.jobOrderId),
                  const SizedBox(height: 8),
                  infoRow("Recipient", widget.posterEmail),
                  const SizedBox(height: 8),

                  infoRow(
                    "Amount",
                    "৳ ${cleanAmount(widget.amount)}",
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            if (_paymentResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _paymentResult!.contains("✔")
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _paymentResult!,
                  style: TextStyle(
                    color: _paymentResult!.contains("✔")
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

            const Spacer(),

            //  Payment Options
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FakeBkashCheckout(
                              amount: cleanAmount(widget.amount),
                            ),
                          ),
                        );

                        if (result == true) {
                          Navigator.pop(context, true); // Payment success
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2136E),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              "Pay with bKash",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nagad
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => showSuccessPopup("Nagad"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4E00),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Pay with Nagad",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Rocket
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => showSuccessPopup("Rocket"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A1EA1),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Pay with Rocket",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String title, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
