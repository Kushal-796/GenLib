import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPenaltyScreen extends StatelessWidget {
  const AdminPenaltyScreen({super.key});

  int calculatePenalty(Timestamp timestamp) {
    final now = DateTime.now();
    final approvedTime = timestamp.toDate();
    final difference = now.difference(approvedTime);
    final totalMinutes = difference.inMinutes;

    if (totalMinutes < 1) return 0;
    return 200 + ((totalMinutes - 1) * 25);
  }

  Future<void> markAsPaid(String docId) async {
    await FirebaseFirestore.instance.collection('penalties').doc(docId).update({
      'isPaid': true,
    });
  }

  Future<Map<String, String>> getBookAndUserInfo(String bookId, String userId) async {
    final bookSnapshot = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
    final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final bookTitle = bookSnapshot.exists ? bookSnapshot['title'] ?? 'Unknown Title' : 'Unknown Title';
    final userName = userSnapshot.exists ? userSnapshot['name'] ?? 'Unknown User' : 'Unknown User';

    return {
      'bookTitle': bookTitle,
      'userName': userName,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('penalties')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("✅ No penalties found."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final bookId = data['bookId'] ?? '';
              final userId = data['userId'] ?? '';
              final timestamp = data['timestamp'] as Timestamp;
              final isPaid = data['isPaid'] ?? false;
              final penalty = calculatePenalty(timestamp);
              final dateTime = timestamp.toDate();
              final formattedTime =
                  '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

              return FutureBuilder<Map<String, String>>(
                future: getBookAndUserInfo(bookId, userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final bookTitle = snapshot.data!['bookTitle']!;
                  final userName = snapshot.data!['userName']!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Book: $bookTitle", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("User: $userName"),
                                  const SizedBox(height: 4),
                                  Text("Issued: $formattedTime"),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("₹$penalty", style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                isPaid
                                    ? const Chip(
                                  label: Text("Paid", style: TextStyle(color: Colors.green)),
                                  backgroundColor: Color(0xFFDFFFE0),
                                )
                                    : ElevatedButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Payment'),
                                        content: const Text('Are you sure you want to mark this penalty as paid?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            child: const Text('Confirm'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await markAsPaid(doc.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Penalty marked as paid!')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    minimumSize: const Size(60, 30),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                  child: const Text(
                                    "Mark Paid",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}