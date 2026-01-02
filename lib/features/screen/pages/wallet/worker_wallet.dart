import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shohozkaz/core/constants.dart';

class WorkerTransactionHistory extends StatefulWidget {
  const WorkerTransactionHistory({super.key});

  @override
  State<WorkerTransactionHistory> createState() =>
      _WorkerTransactionHistoryState();
}

class _WorkerTransactionHistoryState extends State<WorkerTransactionHistory> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _syncInProgress = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> _completedJobsStream(String uid) {
    return _db
        .collection('completedJobs')
        .where('posterId', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _withdrawRequestsStream(
    String uid,
  ) {
    return _db
        .collection('withdrawRequests')
        .where('posterId', isEqualTo: uid)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _walletStream(String uid) {
    return _db.collection('earningWallet').doc(uid).snapshots();
  }

  int _parseMoney(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(
          value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
        ) ??
        0;
  }

  DateTime _safeDate(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime _startOfThisMonth(DateTime now) => DateTime(now.year, now.month, 1);

  DateTime _startOfLastMonth(DateTime now) {
    final firstThisMonth = DateTime(now.year, now.month, 1);
    return DateTime(firstThisMonth.year, firstThisMonth.month - 1, 1);
  }

  DateTime _endOfLastMonth(DateTime now) {
    final firstThisMonth = DateTime(now.year, now.month, 1);
    return firstThisMonth.subtract(const Duration(milliseconds: 1));
  }

  /// Auto-sync earningWallet from completedJobs sum
  /// Keeps totalWithdraw as-is (withdraw flow updates it),
  /// then recompute currentBalance = totalEarning - totalWithdraw.
  Future<void> _syncWalletFromCompletedJobs({
    required String uid,
    required String email,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> jobsDocs,
  }) async {
    if (_syncInProgress) return;
    _syncInProgress = true;

    try {
      final now = DateTime.now();
      final startThisMonth = _startOfThisMonth(now);
      final startLastMonth = _startOfLastMonth(now);
      final endLastMonth = _endOfLastMonth(now);

      int totalEarning = 0;
      int thisMonthEarning = 0;
      int lastMonthEarning = 0;

      for (final doc in jobsDocs) {
        final data = doc.data();
        final salary = _parseMoney(data['salary']);
        totalEarning += salary;

        final completedAt = _safeDate(data['completedAt']);
        if (!completedAt.isBefore(startThisMonth)) {
          thisMonthEarning += salary;
        }
        if (!completedAt.isBefore(startLastMonth) &&
            !completedAt.isAfter(endLastMonth)) {
          lastMonthEarning += salary;
        }
      }

      final walletRef = _db.collection('earningWallet').doc(uid);

      await _db.runTransaction((tx) async {
        final walletSnap = await tx.get(walletRef);
        final wallet = walletSnap.data();

        final totalWithdraw = _parseMoney(wallet?['totalWithdraw']);
        final currentBalance = totalEarning - totalWithdraw;

        // Prevent noisy writes: only update if changed
        final oldTotalEarning = _parseMoney(wallet?['totalEarning']);
        final oldThisMonth = _parseMoney(wallet?['thisMonthEarning']);
        final oldLastMonth = _parseMoney(wallet?['lastMonthEarning']);
        final oldBalance = _parseMoney(wallet?['currentBalance']);

        final changed =
            oldTotalEarning != totalEarning ||
            oldThisMonth != thisMonthEarning ||
            oldLastMonth != lastMonthEarning ||
            oldBalance != currentBalance;

        if (!walletSnap.exists) {
          tx.set(walletRef, {
            'posterId': uid,
            'posterEmail': email,
            'totalEarning': totalEarning,
            'thisMonthEarning': thisMonthEarning,
            'lastMonthEarning': lastMonthEarning,
            'totalWithdraw': 0,
            'currentBalance': totalEarning,
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else if (changed) {
          tx.set(walletRef, {
            'posterId': uid,
            'posterEmail': email,
            'totalEarning': totalEarning,
            'thisMonthEarning': thisMonthEarning,
            'lastMonthEarning': lastMonthEarning,
            'currentBalance': currentBalance,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> _createWithdrawRequest({
    required String uid,
    required String email,
    required int amount,
    required String method,
    required Map<String, dynamic> accountInfo,
  }) async {
    final walletRef = _db.collection('earningWallet').doc(uid);
    final requestRef = _db.collection('withdrawRequests').doc();

    await _db.runTransaction((tx) async {
      final walletSnap = await tx.get(walletRef);
      final wallet = walletSnap.data();

      if (walletSnap.exists != true) {
        throw Exception("Wallet not found. Please try again.");
      }

      final currentBalance = _parseMoney(wallet?['currentBalance']);
      final totalWithdraw = _parseMoney(wallet?['totalWithdraw']);

      if (amount <= 0) throw Exception("Invalid withdraw amount.");
      if (amount > currentBalance) {
        throw Exception("Insufficient balance.");
      }

      // 1) Create withdraw request
      tx.set(requestRef, {
        'requestId': requestRef.id,
        'posterId': uid,
        'posterEmail': email,
        'amount': amount,
        'method': method, // bkash/nagad/rocket/bank
        'accountInfo': accountInfo,
        'status': 'pending', // pending/cancel/paid
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2) Update wallet totals immediately
      tx.set(walletRef, {
        'totalWithdraw': totalWithdraw + amount,
        'currentBalance': currentBalance - amount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> _cancelWithdrawRequest({
    required String uid,
    required String requestId,
  }) async {
    final walletRef = _db.collection('earningWallet').doc(uid);
    final reqRef = _db.collection('withdrawRequests').doc(requestId);

    await _db.runTransaction((tx) async {
      final reqSnap = await tx.get(reqRef);
      final walletSnap = await tx.get(walletRef);

      if (!reqSnap.exists) throw Exception("Request not found.");
      if (!walletSnap.exists) throw Exception("Wallet not found.");

      final req = reqSnap.data() as Map<String, dynamic>;
      final status = (req['status'] ?? '').toString();
      final amount = _parseMoney(req['amount']);

      if (status != 'pending') {
        throw Exception("Only pending requests can be cancelled.");
      }

      final wallet = walletSnap.data();
      final totalWithdraw = _parseMoney(wallet?['totalWithdraw']);
      final currentBalance = _parseMoney(wallet?['currentBalance']);

      // Mark canceled
      tx.set(reqRef, {
        'status': 'cancel',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Rollback wallet
      tx.set(walletRef, {
        'totalWithdraw': (totalWithdraw - amount).clamp(0, 1 << 31),
        'currentBalance': currentBalance + amount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  void _openWithdrawSheet({
    required int currentBalance,
    required String uid,
    required String email,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _WithdrawSheet(
          currentBalance: currentBalance,
          onSubmit: (amount, method, accountInfo) async {
            await _createWithdrawRequest(
              uid: uid,
              email: email,
              amount: amount,
              method: method,
              accountInfo: accountInfo,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser!;
    final uid = user.uid;
    final email = user.email ?? '';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[50];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Earning Wallet",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _completedJobsStream(uid),
        builder: (context, jobsSnap) {
          if (jobsSnap.hasError) {
            return const Center(child: Text("Failed to load completed jobs"));
          }
          if (!jobsSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobsDocs = jobsSnap.data!.docs;

          //  Auto-sync wallet based on completedJobs (real-time)
          // Ignore build spam via _syncInProgress and change-detection in transaction.
          _syncWalletFromCompletedJobs(
            uid: uid,
            email: email,
            jobsDocs: jobsDocs,
          );

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _walletStream(uid),
            builder: (context, walletSnap) {
              final wallet = walletSnap.data?.data() ?? {};
              final totalEarning = _parseMoney(wallet['totalEarning']);
              final totalWithdraw = _parseMoney(wallet['totalWithdraw']);
              final currentBalance = _parseMoney(wallet['currentBalance']);
              final thisMonthEarning = _parseMoney(wallet['thisMonthEarning']);
              final lastMonthEarning = _parseMoney(wallet['lastMonthEarning']);

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _withdrawRequestsStream(uid),
                builder: (context, wrSnap) {
                  final withdrawDocs = wrSnap.data?.docs ?? [];

                  //  Build combined history (jobs + withdraw paid/pending/cancel)
                  final history = <_HistoryItem>[];

                  for (final d in jobsDocs) {
                    final data = d.data();
                    history.add(
                      _HistoryItem(
                        type: _HistoryType.job,
                        title: (data['jobTitle'] ?? 'Job Payment').toString(),
                        amount: _parseMoney(data['salary']),
                        status: 'completed',
                        time: _safeDate(data['completedAt']),
                        extra: {'orderId': data['jobOrderId'] ?? ''},
                      ),
                    );
                  }

                  for (final d in withdrawDocs) {
                    final data = d.data();
                    history.add(
                      _HistoryItem(
                        type: _HistoryType.withdraw,
                        title:
                            'Withdraw (${(data['method'] ?? '').toString()})',
                        amount: _parseMoney(data['amount']),
                        status: (data['status'] ?? 'pending').toString(),
                        time: _safeDate(data['createdAt']),
                        extra: {
                          'requestId': d.id,
                          'method': data['method'] ?? '',
                        },
                      ),
                    );
                  }

                  history.sort((a, b) => b.time.compareTo(a.time));

                  return Column(
                    children: [
                      _walletDashboard(
                        totalEarning: totalEarning,
                        totalWithdraw: totalWithdraw,
                        currentBalance: currentBalance,
                        thisMonthEarning: thisMonthEarning,
                        lastMonthEarning: lastMonthEarning,
                        onWithdraw: () => _openWithdrawSheet(
                          currentBalance: currentBalance,
                          uid: uid,
                          email: email,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Transaction History",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Expanded(
                        child: history.isEmpty
                            ? const Center(
                                child: Text(
                                  "No history available",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: history.length,
                                itemBuilder: (context, index) {
                                  final item = history[index];
                                  return _historyCard(
                                    context: context,
                                    item: item,
                                    isDark: isDark,
                                    onCancelWithdraw: (requestId) async {
                                      await _cancelWithdrawRequest(
                                        uid: uid,
                                        requestId: requestId,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _walletDashboard({
    required int totalEarning,
    required int totalWithdraw,
    required int currentBalance,
    required int thisMonthEarning,
    required int lastMonthEarning,
    required VoidCallback onWithdraw,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.button, Color(0xFF00C853)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _walletTile("Current Balance", currentBalance)),
              const SizedBox(width: 12),
              Expanded(child: _walletTile("Total Earning", totalEarning)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _walletTile("Total Withdraw", totalWithdraw)),
              const SizedBox(width: 12),
              Expanded(child: _walletTile("This Month", thisMonthEarning)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _walletTile("Last Month", lastMonthEarning)),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: currentBalance > 0 ? onWithdraw : null,
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text("Withdraw"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.button,
                      disabledBackgroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletTile(String title, int value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 5),
          Text(
            "৳$value",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard({
    required BuildContext context,
    required _HistoryItem item,
    required bool isDark,
    required Future<void> Function(String requestId) onCancelWithdraw,
  }) {
    final formattedDate = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(item.time);

    final isJob = item.type == _HistoryType.job;
    final isWithdraw = item.type == _HistoryType.withdraw;

    final status = item.status.toLowerCase();
    final isPaid = status == 'paid';
    final isCancel = status == 'cancel';

    final amountText = isJob ? "+৳${item.amount}" : "-৳${item.amount}";

    Color amountColor;
    if (isJob) {
      amountColor = Colors.green;
    } else {
      amountColor = isCancel ? Colors.red : Colors.orange;
      if (isPaid) amountColor = Colors.grey;
    }

    Color badgeColor;
    if (isJob) {
      badgeColor = Colors.green;
    } else if (isPaid) {
      badgeColor = const Color.fromARGB(255, 83, 176, 21);
    } else if (isCancel) {
      badgeColor = const Color.fromARGB(255, 211, 10, 10);
    } else {
      badgeColor = Colors.orange;
    }

    String badgeText;
    if (isJob) {
      badgeText = "Completed";
    } else if (isPaid) {
      badgeText = "Paid";
    } else if (isCancel) {
      badgeText = "Cancelled";
    } else {
      badgeText = "Pending";
    }

    final orderId = item.extra['orderId']?.toString() ?? '';
    final requestId = item.extra['requestId']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isJob
                  ? Colors.green.withOpacity(0.12)
                  : Colors.orange.withOpacity(0.12),
            ),
            child: Icon(
              isJob ? Icons.payments_rounded : Icons.outbox_rounded,
              color: isJob ? Colors.green : Colors.orange,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (isJob && orderId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Order ID: $orderId",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                if (isWithdraw && requestId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Request ID: $requestId",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        color: badgeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Withdraw Bottom Sheet
// class _WithdrawSheet extends StatefulWidget {
//   final int currentBalance;
//   final Future<void> Function(
//     int amount,
//     String method,
//     Map<String, dynamic> accountInfo,
//   )
//   onSubmit;

//   const _WithdrawSheet({required this.currentBalance, required this.onSubmit});

//   @override
//   State<_WithdrawSheet> createState() => _WithdrawSheetState();
// }

// class _WithdrawSheetState extends State<_WithdrawSheet> {
//   final _formKey = GlobalKey<FormState>();

//   final _amountCtrl = TextEditingController();
//   final _accNameCtrl = TextEditingController();
//   final _accNumberCtrl = TextEditingController();

//   final _bankNameCtrl = TextEditingController();
//   final _branchCtrl = TextEditingController();

//   String _method = 'bkash';
//   bool _loading = false;

//   @override
//   void dispose() {
//     _amountCtrl.dispose();
//     _accNameCtrl.dispose();
//     _accNumberCtrl.dispose();
//     _bankNameCtrl.dispose();
//     _branchCtrl.dispose();
//     super.dispose();
//   }

//   bool get _isBank => _method == 'bank';

//   int _parseAmount() {
//     return int.tryParse(_amountCtrl.text.trim()) ?? 0;
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     final amount = _parseAmount();
//     final accountInfo = <String, dynamic>{
//       'accountName': _accNameCtrl.text.trim(),
//       'accountNumber': _accNumberCtrl.text.trim(),
//     };

//     if (_isBank) {
//       accountInfo['bankName'] = _bankNameCtrl.text.trim();
//       accountInfo['branch'] = _branchCtrl.text.trim();
//     }

//     setState(() => _loading = true);
//     try {
//       await widget.onSubmit(amount, _method, accountInfo);
//       if (mounted) Navigator.pop(context);
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(content: Text("Withdraw request submitted")),
//         // );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

//     return Padding(
//       padding: EdgeInsets.only(bottom: bottomPadding),
//       child: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   height: 4,
//                   width: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade400,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "Withdraw",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "Available Balance: ৳${widget.currentBalance}",
//                     style: TextStyle(color: Colors.grey.shade700),
//                   ),
//                 ),
//                 const SizedBox(height: 14),

//                 TextFormField(
//                   controller: _amountCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: "Withdraw Amount",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (v) {
//                     final amount = int.tryParse((v ?? '').trim()) ?? 0;
//                     if (amount <= 0) return "Enter valid amount";
//                     if (amount > widget.currentBalance) {
//                       return "Amount exceeds balance";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),

//                 _dropDownButtom(),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: _accNameCtrl,
//                   decoration: const InputDecoration(
//                     labelText: "Account Name",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (v) =>
//                       (v == null || v.trim().isEmpty) ? "Required" : null,
//                 ),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: _accNumberCtrl,
//                   keyboardType: TextInputType.phone,
//                   decoration: InputDecoration(
//                     labelText: _isBank ? "Account Number" : "Wallet Number",
//                     border: const OutlineInputBorder(),
//                   ),
//                   validator: (v) =>
//                       (v == null || v.trim().isEmpty) ? "Required" : null,
//                 ),

//                 if (_isBank) ...[
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _bankNameCtrl,
//                     decoration: const InputDecoration(
//                       labelText: "Bank Name",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (v) =>
//                         (v == null || v.trim().isEmpty) ? "Required" : null,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _branchCtrl,
//                     decoration: const InputDecoration(
//                       labelText: "Branch",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (v) =>
//                         (v == null || v.trim().isEmpty) ? "Required" : null,
//                   ),
//                 ],

//                 const SizedBox(height: 16),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 46,
//                   child: ElevatedButton(
//                     onPressed: _loading ? null : _submit,
//                     child: _loading
//                         ? const SizedBox(
//                             height: 22,
//                             width: 22,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Text("Withdraw Request"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   DropdownButtonFormField<String> _dropDownButtom() {
//     return DropdownButtonFormField<String>(
//       value: _method,
//       decoration: const InputDecoration(
//         labelText: "Method",
//         border: OutlineInputBorder(),
//       ),
//       items: const [
//         DropdownMenuItem(value: 'bkash', child: Text("Bkash")),
//         DropdownMenuItem(value: 'nagad', child: Text("Nagad")),
//         DropdownMenuItem(value: 'rocket', child: Text("Rocket")),
//         DropdownMenuItem(value: 'bank', child: Text("Bank")),
//       ],
//       onChanged: (v) => setState(() => _method = v ?? 'bkash'),
//     );
//   }
// }



class _WithdrawSheet extends StatefulWidget {
  final int currentBalance;
  final Future<void> Function(
    int amount,
    String method,
    Map<String, dynamic> accountInfo,
  ) onSubmit;

  const _WithdrawSheet({
    required this.currentBalance,
    required this.onSubmit,
  });

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _formKey = GlobalKey<FormState>();

  final _amountCtrl = TextEditingController();
  final _accNameCtrl = TextEditingController();
  final _accNumberCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();

  String _method = 'bkash';
  bool _loading = false;

  bool get _isBank => _method == 'bank';

  int _parseAmount() =>
      int.tryParse(_amountCtrl.text.trim()) ?? 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _accNameCtrl.dispose();
    _accNumberCtrl.dispose();
    _bankNameCtrl.dispose();
    _branchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final accountInfo = {
        'accountName': _accNameCtrl.text.trim(),
        'accountNumber': _accNumberCtrl.text.trim(),
        if (_isBank) 'bankName': _bankNameCtrl.text.trim(),
        if (_isBank) 'branch': _branchCtrl.text.trim(),
      };

      await widget.onSubmit(
        _parseAmount(),
        _method,
        accountInfo,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Drag handle
                Center(
                  child: Container(
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// Title
                const Text(
                  "Withdraw",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                /// Balance card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.green.withOpacity(0.12)
                        : Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Available Balance: ৳${widget.currentBalance}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _field(
                  controller: _amountCtrl,
                  label: "Withdraw Amount",
                  keyboard: TextInputType.number,
                  validator: (v) {
                    final amount = int.tryParse(v ?? '') ?? 0;
                    if (amount <= 0) return "Enter valid amount";
                    if (amount > widget.currentBalance) {
                      return "Amount exceeds balance";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _methodDropdown(),

                const SizedBox(height: 14),

                _field(
                  controller: _accNameCtrl,
                  label: "Account Name",
                  validator: _required,
                ),

                const SizedBox(height: 14),

                _field(
                  controller: _accNumberCtrl,
                  label: _isBank ? "Account Number" : "Wallet Number",
                  keyboard: TextInputType.phone,
                  validator: _required,
                ),

                if (_isBank) ...[
                  const SizedBox(height: 14),
                  _field(
                    controller: _bankNameCtrl,
                    label: "Bank Name",
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _branchCtrl,
                    label: "Branch",
                    validator: _required,
                  ),
                ],

                const SizedBox(height: 22),

                /// Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Submit Withdraw Request",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


Widget _methodDropdown() {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return DropdownButtonFormField<String>(
    value: _method,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: "Withdraw Method",
      filled: true,
      fillColor: isDark
          ? const Color(0xFF1E1E1E)
          : Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 115, 115, 115),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 122, 122, 122),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.button, // same accent color
          width: 1.6,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    dropdownColor:
        isDark ? const Color(0xFF1E1E1E) : Colors.white,
    items: const [
      DropdownMenuItem(value: 'bkash', child: Text("Bkash")),
      DropdownMenuItem(value: 'nagad', child: Text("Nagad")),
      DropdownMenuItem(value: 'rocket', child: Text("Rocket")),
      DropdownMenuItem(value: 'bank', child: Text("Bank")),
    ],
    onChanged: (v) => setState(() => _method = v ?? 'bkash'),
  );
}

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? "Required" : null;
}


/// History Models
enum _HistoryType { job, withdraw }

class _HistoryItem {
  final _HistoryType type;
  final String title;
  final int amount;
  final String status;
  final DateTime time;
  final Map<String, dynamic> extra;

  _HistoryItem({
    required this.type,
    required this.title,
    required this.amount,
    required this.status,
    required this.time,
    required this.extra,
  });
}
