import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/admin_app_drawer.dart';
import 'admin_available_books_screen.dart';

class AdminPendingRequests extends StatefulWidget {
  const AdminPendingRequests({super.key});

  @override
  State<AdminPendingRequests> createState() => _AdminPendingRequestsState();
}

class _AdminPendingRequestsState extends State<AdminPendingRequests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Map<String, String>> _getBookTitleAndUserName(String bookId, String userId) async {
    String bookTitle = 'Unknown Book';
    String userName = 'Unknown User';

    try {
      final bookSnap = await _firestore.collection('books').doc(bookId).get();
      if (bookSnap.exists) {
        bookTitle = bookSnap.data()?['title'] ?? bookTitle;
      }

      final userSnap = await _firestore.collection('users').doc(userId).get();
      if (userSnap.exists) {
        userName = userSnap.data()?['name'] ?? userName;
      }
    } catch (e) {
      debugPrint('Error fetching book/user info: $e');
    }

    return {
      'bookTitle': bookTitle,
      'userName': userName,
    };
  }

  Future<void> _updateRequest(String requestId, String bookId, String status) async {
    final requestRef = _firestore.collection('lending_requests').doc(requestId);
    final bookRef = _firestore.collection('books').doc(bookId);
    final bookTitle = (await bookRef.get()).data()?['title'] ?? 'Unknown Book';

    try {
      final requestSnap = await requestRef.get();
      final requestData = requestSnap.data();
      final isReturnRequest = requestData?['isReturnRequest'] ?? false;
      final userId = requestData?['userId'];

      if (isReturnRequest) {
        if (status == 'approved') {
          await _firestore.runTransaction((transaction) async {
            final bookSnap = await transaction.get(bookRef);
            if (!bookSnap.exists) throw Exception("Book not found");

            final currentCount = bookSnap.get('count') ?? 0;
            final newCount = currentCount + 1;

            transaction.update(bookRef, {
              'count': newCount,
              'isAvailable': true,
            });

            transaction.update(requestRef, {
              'returnRequestStatus': 'approved',
              'isReturned': true,
            });
          });
        } else {
          await requestRef.update({
            'returnRequestStatus': 'rejected',
          });
        }
      } else {
        if (status == 'approved') {
          await _firestore.runTransaction((transaction) async {
            final bookSnap = await transaction.get(bookRef);
            if (!bookSnap.exists) throw Exception("Book not found");

            final currentCount = bookSnap.get('count') ?? 0;
            if (currentCount > 0) {
              final newCount = currentCount - 1;
              final now = Timestamp.now();

              transaction.update(bookRef, {'count': newCount});
              transaction.update(requestRef, {
                'status': 'approved',
                'approvedAt': now,
                'penaltyAmount': 0,
                'isPaid': false,
              });
            } else {
              throw Exception("No copies available to approve this request.");
            }
          });
        } else {
          await requestRef.update({'status': status});

          // 🔻 Decrease nob by 1 if status is rejected
          if (status == 'rejected') {
            final userRef = _firestore.collection('users').doc(userId);
            final userSnap = await userRef.get();

            if (userSnap.exists) {
              int currentNob = userSnap.data()?['nob'] ?? 0;
              if (currentNob > 0) {
                await userRef.update({'nob': currentNob - 1});
              }
            }
          }
        }
      }

      // Alert creation
      await _firestore.collection('alerts').add({
        'userId': userId,
        'bookId': bookId,
        'isRead': false,
        'timestamp': Timestamp.now(),
        'message': status == 'approved'
            ? '✅ Your request for "$bookTitle" has been approved!'
            : '❌ Your request for "$bookTitle" was rejected.',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${status == 'approved' ? 'approved' : 'rejected'} successfully')),
      );
    } catch (e) {
      debugPrint("Error updating request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminAvailableBooksScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3FAF8),
        drawer: AdminAppDrawer(),
        body: SafeArea(
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dad's AppBar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Icon(Icons.chevron_right, size: 32, color: Color(0xFF00253A)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Pending Requests',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00253A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshData,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('lending_requests')
                            .where('status', isEqualTo: 'pending')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          final requests = snapshot.data?.docs ?? [];

                          if (requests.isEmpty) {
                            return const Center(child: Text('No pending requests.'));
                          }

                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              final request = requests[index];
                              final bookId = request['bookId'];
                              final userId = request['userId'];
                              final timestamp = request['timestamp'];

                              final formattedDate = (timestamp != null && timestamp is Timestamp)
                                  ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                                  : 'Unknown';

                              return FutureBuilder<Map<String, String>>(
                                future: _getBookTitleAndUserName(bookId, userId),
                                builder: (context, snapshot) {
                                  final bookTitle = snapshot.data?['bookTitle'] ?? 'Loading...';
                                  final userName = snapshot.data?['userName'] ?? 'Loading...';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      leading: const Icon(Icons.pending_actions, color: Colors.orange),
                                      title: Text(
                                        bookTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF00253A),
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text("User: $userName"),
                                          const SizedBox(height: 4),
                                          Text("Requested on: $formattedDate"),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check, color: Colors.green),
                                            onPressed: () => _updateRequest(request.id, bookId, 'approved'),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () => _updateRequest(request.id, bookId, 'rejected'),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
