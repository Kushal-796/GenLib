import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:libraryqr/widgets/app_drawer.dart';

class BorrowedBooksScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const BorrowedBooksScreen({super.key, required this.onToggleTheme});

  @override
  State<BorrowedBooksScreen> createState() => _BorrowedBooksScreenState();
}

class _BorrowedBooksScreenState extends State<BorrowedBooksScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _sendReturnRequest(String lendingRequestId, String bookId) async {
    try {
      final userId = user?.uid;
      if (userId == null) throw Exception("User not logged in");

      // Check for an associated penalty
      final penaltySnapshot = await FirebaseFirestore.instance
          .collection('penalties')
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .where('isPaid', isEqualTo: false)
          .limit(1)
          .get();

      String? penaltyId;
      if (penaltySnapshot.docs.isNotEmpty) {
        penaltyId = penaltySnapshot.docs.first.id;
      }

      // Update lending request to reflect return attempt
      await FirebaseFirestore.instance.collection('lending_requests').doc(lendingRequestId).update({
        'isReturnRequest': true,
        'returnRequestStatus': 'pending',
        'returnTimestamp': Timestamp.now(),
      });

      // Add return request with optional penaltyId
      final returnRequestData = {
        'lendingRequestId': lendingRequestId,
        'bookId': bookId,
        'userId': userId,
        'status': 'pending',
        'createdAt': Timestamp.now(),
        if (penaltyId != null) 'penaltyId': penaltyId,
      };

      await FirebaseFirestore.instance.collection('return_requests').add(returnRequestData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return request sent successfully.')),
      );

      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  int _getSortPriority(Map<String, dynamic> data) {
    final isReturnRequested = data['isReturnRequest'] == true;
    final isRejected = data['returnRequestStatus'] == 'rejected';
    if (!isReturnRequested) return 0;
    if (isReturnRequested && !isRejected) return 1;
    if (isRejected) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Borrowed Books"),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('alerts')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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

      drawer: AppDrawer(onToggleTheme: widget.onToggleTheme),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lending_requests')
            .where('userId', isEqualTo: user?.uid)
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final rawRequests = snapshot.data!.docs;
          final filteredRequests = rawRequests.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isReturned'] != true;
          }).toList();

          if (filteredRequests.isEmpty) {
            return const Center(child: Text('No borrowed books found.'));
          }

          filteredRequests.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            return _getSortPriority(aData).compareTo(_getSortPriority(bData));
          });

          return ListView.builder(
            itemCount: filteredRequests.length,
            itemBuilder: (context, index) {
              final lendingData = filteredRequests[index].data() as Map<String, dynamic>;
              final lendingRequestId = filteredRequests[index].id;
              final bookId = lendingData['bookId'];
              final isReturnRequested = lendingData['isReturnRequest'] == true;
              final returnStatus = lendingData['returnRequestStatus'];
              final canRequestReturn = !isReturnRequested || returnStatus == 'rejected';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
                builder: (context, bookSnapshot) {
                  if (!bookSnapshot.hasData || !bookSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final bookData = bookSnapshot.data!.data() as Map<String, dynamic>;
                  final bookTitle = bookData['title'] ?? 'Untitled';
                  final bookAuthor = bookData['author'] ?? 'Unknown';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.book, color: Color(0xFF91D7C3)),
                      title: Text(bookTitle),
                      subtitle: Text('Author: $bookAuthor'),
                      trailing: ElevatedButton(
                        onPressed: canRequestReturn
                            ? () => _sendReturnRequest(lendingRequestId, bookId)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF91D7C3),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: Text(
                          !isReturnRequested
                              ? 'Return'
                              : (returnStatus == 'pending'
                              ? 'Request Sent'
                              : returnStatus == 'rejected'
                              ? 'Retry Return'
                              : 'Returned'),
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
