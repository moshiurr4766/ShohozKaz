// import 'package:flutter/material.dart';
// import 'package:bkash/bkash.dart';

// class PayWithBkash extends StatefulWidget {
//   final String amount;
//   final String invoiceId;
//   final void Function(String trxId) onSuccess;

//   const PayWithBkash({
//     super.key,
//     required this.amount,
//     required this.invoiceId,
//     required this.onSuccess,
//   });

//   @override
//   State<PayWithBkash> createState() => _PayWithBkashState();
// }

// class _PayWithBkashState extends State<PayWithBkash> {
//   late final Bkash _bkash;
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();

//     _bkash = Bkash(
//       bkashCredentials: BkashCredentials(
        // username: '01923311458',
        // password: 'An1_A2B<B+U',
        // appKey: 'TE6qdG43nBFqXOqYFvmjAeHZtc',
        // appSecret: '0cJxlGoVk2xfbZvT1slluQQipUX4tE3n4JhftBhtRJvufKD0rE64',
//         isSandbox: false, 
//       ),
//       logResponse: true,
//     );
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _pay();
//     });
//   }

//   String _cleanAmount(String raw) {
//     return raw.replaceAll(RegExp(r'[^0-9]'), '');
//   }

//   Future<void> _pay() async {
//     if (_loading) return;

//     setState(() => _loading = true);

//     try {
//       final response = await _bkash.pay(
//         context: context,
//         amount: double.parse(_cleanAmount(widget.amount)),
//         merchantInvoiceNumber: widget.invoiceId,
//       );

//       // SUCCESS
//       widget.onSuccess(response.trxId);
//     } on BkashFailure catch (e) {
//       _showError(e.message);
//     } catch (_) {
//       _showError("Unexpected error occurred");
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   // SIMPLE REDIRECT UI
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:bkash/bkash.dart';

class PayWithBkash extends StatefulWidget {
  final String amount;
  final String invoiceId;
  final void Function(String trxId) onSuccess;

  const PayWithBkash({
    super.key,
    required this.amount,
    required this.invoiceId,
    required this.onSuccess,
  });

  @override
  State<PayWithBkash> createState() => _PayWithBkashState();
}

class _PayWithBkashState extends State<PayWithBkash> {
  late final Bkash _bkash;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _bkash = Bkash(
      bkashCredentials: BkashCredentials(
        username: 'username',
        password: 'password',
        appKey: 'apikey',
        appSecret: 'secretKey',
        isSandbox: false, // true for sandbox
      ),
      logResponse: true,
    );

    // AUTO START PAYMENT AFTER FIRST FRAME
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pay();
    });
  }

  String _cleanAmount(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _pay() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final response = await _bkash.pay(
        context: context,
        amount: double.parse(_cleanAmount(widget.amount)),
        merchantInvoiceNumber: widget.invoiceId,
      );

      // PAYMENT SUCCESS
      widget.onSuccess(response.trxId);

    } on BkashFailure {
      //  USER CANCELLED → JUST GO BACK
      if (mounted) {
        Navigator.pop(context, false);
      }

    } catch (_) {
      //  ANY ERROR → GO BACK SILENTLY
      if (mounted) {
        Navigator.pop(context, false);
      }

    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // prevent accidental back while loading
        return !_loading;
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
