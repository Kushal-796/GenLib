import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProcessedRequests extends StatelessWidget {
  const AdminProcessedRequests({super.key});

  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['name'] ?? 'Unknown User';
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
    return 'Unknown User';
  }

  Future<String> _getBookTitle(String bookId) async {
    try {
      final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      if (bookDoc.exists) {
        return bookDoc.data()?['title'] ?? 'Unknown Book';
      }
    } catch (e) {
      debugPrint('Error fetching book title: $e');
    }
    return 'Unknown Book';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lending_requests')
            .where('status', whereIn: ['approved', 'rejected'])
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No processed requests.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final userId = request['userId'];
              final bookId = request['bookId'];
              final status = request['status'];
              final isApproved = status == 'approved';

              return FutureBuilder<List<String>>(
                future: Future.wait([
                  _getUserName(userId),
                  _getBookTitle(bookId),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final userName = snapshot.data![0];
                  final bookTitle = snapshot.data![1];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: isApproved
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          isApproved ? Icons.check : Icons.close,
                          color: isApproved ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        bookTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User: $userName'),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                            isApproved ? Colors.green : Colors.red,
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
    );
  }
}
