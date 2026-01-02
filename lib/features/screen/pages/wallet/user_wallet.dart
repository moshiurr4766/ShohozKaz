import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class UserTransactionHistory extends StatefulWidget {
  const UserTransactionHistory({super.key});

  @override
  State<UserTransactionHistory> createState() =>
      _UserTransactionHistoryState();
}

class _UserTransactionHistoryState extends State<UserTransactionHistory> {
  Stream<List<QueryDocumentSnapshot>> _getUserTransactions(String uid) {
    return FirebaseFirestore.instance
        .collection('completedJobs')
        .where('posterId', isEqualTo: uid) // ✅ USER paid
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          docs.sort((a, b) {
            final aTime =
                (a['completedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime =
                (b['completedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });
          return docs;
        });
  }

  int _parseSalary(dynamic salary) {
    if (salary is int) return salary;
    return int.tryParse(
          salary?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Transaction History"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _getUserTransactions(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Failed to load transaction history"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;
          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                "No transaction history available",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final data =
                  transactions[index].data() as Map<String, dynamic>;

              final completedAt =
                  (data['completedAt'] as Timestamp?)?.toDate() ??
                      DateTime.now();

              final formattedDate = DateFormat(
                'MMM dd, yyyy • hh:mm a',
              ).format(completedAt);

              final salary = _parseSalary(data['salary']);

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
                    /// LEFT ICON (Payment Sent)
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['jobTitle'] ?? 'Worker Payment',
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Order ID: ${data['jobOrderId'] ?? ''}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// AMOUNT + STATUS
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "-৳$salary",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Completed",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
