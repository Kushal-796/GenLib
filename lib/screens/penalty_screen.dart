import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/widgets/app_drawer.dart';

class PenaltyScreen extends StatelessWidget {
  const PenaltyScreen({super.key});

  int calculatePenalty(Timestamp timestamp) {
    final now = DateTime.now();
    final borrowedTime = timestamp.toDate();
    final difference = now.difference(borrowedTime);
    final totalMinutes = difference.inMinutes;

    // 7 days = 10080 minutes
    if (totalMinutes <= 10080) return 0;

    final extraDays = difference.inDays - 7; // Days after first week
    return extraDays * 2;
  }



  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Penalty"),
        backgroundColor: const Color(0xFF91D7C3),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('alerts')
                .where('userId', isEqualTo: userId)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.pushNamed(context, '/alerts');
                    },
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(onToggleTheme: () {}),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('penalties')
            .where('userId', isEqualTo: userId)
            .where('isPaid', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final penaltyDocs = snapshot.data?.docs ?? [];

          if (penaltyDocs.isEmpty) {
            return const Center(child: Text("No active penalties."));
          }

          return ListView.builder(
            itemCount: penaltyDocs.length,
            itemBuilder: (context, index) {
              final penaltyData = penaltyDocs[index].data() as Map<String, dynamic>;
              final timestamp = penaltyData['timestamp'] as Timestamp;
              final penalty = calculatePenalty(timestamp);
              final bookId = penaltyData['bookId'];
              final formattedTime = '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} '
                  '${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
                builder: (context, snapshot) {
                  String title = 'Unknown';

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final bookData = snapshot.data!.data() as Map<String, dynamic>;
                    title = bookData['title'] ?? 'Unknown';
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        title: Text("Book: $title"),
                        subtitle: Text("Since: $formattedTime"),
                        trailing: Text(
                          "₹$penalty",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 18,
                          ),
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
