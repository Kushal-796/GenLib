import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libraryqr/widgets/app_drawer.dart';
import 'package:libraryqr/screens/penalty_checkout_page.dart';

class PenaltyScreen extends StatelessWidget {
  const PenaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF8),
      drawer: AppDrawer(onToggleTheme: () {}),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF00253A)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          "Penalties",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF00253A),
          ),
        ),
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
                    icon: const Icon(Icons.notifications, color: Color(0xFF00253A)),
                    onPressed: () {
                      Navigator.pushNamed(context, '/alerts');
                    },
                  ),
                  if (hasUnread)
                    const Positioned(
                      right: 11,
                      top: 11,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
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
              return const Center(
                child: Text(
                  "🎉 No active penalties!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: penaltyDocs.length,
              itemBuilder: (context, index) {
                final penaltyData = penaltyDocs[index].data() as Map<String, dynamic>;
                final timestamp = penaltyData['timestamp'] as Timestamp;
                final penaltyAmount = penaltyData['penaltyAmount'] ?? 0;
                final bookId = penaltyData['bookId'];
                final formattedTime = DateFormat.yMMMd().add_jm().format(timestamp.toDate());

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
                  builder: (context, snapshot) {
                    String title = 'Unknown';

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final bookData = snapshot.data!.data() as Map<String, dynamic>;
                      title = bookData['title'] ?? 'Unknown';
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.redAccent,
                              child: Icon(Icons.warning_amber_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF00253A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Penalty since: $formattedTime",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "₹$penaltyAmount",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PenaltyCheckoutPage(
                                          penaltyId: penaltyDocs[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00253A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    textStyle: const TextStyle(fontSize: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Pay"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
