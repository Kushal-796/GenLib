import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  void _updateStatus(String requestId, String newStatus) {
    FirebaseFirestore.instance
        .collection('lending_requests')
        .doc(requestId)
        .update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Lending Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lending_requests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No pending requests."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final bookId = request['bookId'];
              final userId = request['userId'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Book ID: $bookId"),
                  subtitle: Text("User ID: $userId"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateStatus(request.id, 'approved'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateStatus(request.id, 'rejected'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
