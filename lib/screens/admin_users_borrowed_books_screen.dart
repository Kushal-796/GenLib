// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AdminUsersBorrowedBooksScreen extends StatelessWidget {
//   final String userId;
//   final String userName;
//
//   const AdminUsersBorrowedBooksScreen({
//     super.key,
//     required this.userId,
//     required this.userName,
//   });
//
//   Future<Map<String, dynamic>?> _fetchBookData(String bookId) async {
//     try {
//       final bookDoc =
//       await FirebaseFirestore.instance.collection('books').doc(bookId).get();
//       return bookDoc.data();
//     } catch (e) {
//       debugPrint('Error fetching book data: $e');
//       return null;
//     }
//   }
//   Future<void> _sendAlert(BuildContext context, String bookId) async {
//     final TextEditingController _controller = TextEditingController();
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Send Alert to User"),
//         content: TextField(
//           controller: _controller,
//           maxLines: 3,
//           decoration: const InputDecoration(hintText: "Enter alert message..."),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final message = _controller.text.trim();
//               if (message.isNotEmpty) {
//                 await FirebaseFirestore.instance.collection('alerts').add({
//                   'userId': userId,
//                   'bookId': bookId,
//                   'message': message,
//                   'timestamp': Timestamp.now(),
//                   'isRead': false,
//                 });
//
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Alert sent successfully")),
//                 );
//               }
//             },
//             child: const Text("Send"),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   String _getReturnStatus(Map<String, dynamic> requestData) {
//     final isReturned = requestData['isReturned'] == true;
//     final isReturnRequested = requestData['isReturnRequest'] == true;
//
//     if (isReturned) {
//       return '✅ Returned';
//     } else if (isReturnRequested) {
//       return '🔄 Return Requested';
//     } else {
//       return '❌ Not Returned';
//     }
//   }
//
//   int _getSortPriority(Map<String, dynamic> data) {
//     final isReturned = data['isReturned'] == true;
//     final isReturnRequested = data['isReturnRequest'] == true;
//
//     if (!isReturned && !isReturnRequested) return 0;
//     if (isReturnRequested && !isReturned) return 1;
//     return 2; // Returned
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('$userName\'s Borrowed Books')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('lending_requests')
//             .where('userId', isEqualTo: userId)
//             .where('status', isEqualTo: 'approved')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final docs = snapshot.data!.docs;
//
//           if (docs.isEmpty) {
//             return const Center(child: Text("No borrowed books."));
//           }
//
//           // Sort by custom return status priority
//           docs.sort((a, b) {
//             final aData = a.data() as Map<String, dynamic>;
//             final bData = b.data() as Map<String, dynamic>;
//             return _getSortPriority(aData).compareTo(_getSortPriority(bData));
//           });
//
//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final request = docs[index];
//               final requestData = request.data() as Map<String, dynamic>;
//               final bookId = requestData['bookId'];
//               final timestamp = requestData['timestamp'] as Timestamp?;
//               final returnStatus = _getReturnStatus(requestData);
//
//               return FutureBuilder<Map<String, dynamic>?>(
//                 future: _fetchBookData(bookId),
//                 builder: (context, bookSnapshot) {
//                   if (!bookSnapshot.hasData ||
//                       bookSnapshot.connectionState == ConnectionState.waiting) {
//                     return const ListTile(title: Text("Loading book..."));
//                   }
//
//                   final book = bookSnapshot.data!;
//                   final title = book['title'] ?? 'Untitled';
//                   final author = book['author'] ?? 'Unknown Author';
//                   final dateBorrowed = timestamp != null
//                       ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
//                       : 'Unknown Date';
//
//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     child: ListTile(
//                       leading: const Icon(Icons.book),
//                       title: Text(title),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Author: $author'),
//                           Text('Borrowed on: $dateBorrowed'),
//                           Text('Return Status: $returnStatus'),
//                         ],
//                       ),
//                       trailing: ElevatedButton.icon(
//                         icon: const Icon(Icons.warning_amber_rounded, size: 18),
//                         label: const Text("Alert"),
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
//                         onPressed: () => _sendAlert(context, bookId),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersBorrowedBooksScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const AdminUsersBorrowedBooksScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  Future<Map<String, dynamic>?> _fetchBookData(String bookId) async {
    try {
      final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      return bookDoc.data();
    } catch (e) {
      debugPrint('Error fetching book data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchPenaltyData(String bookId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('penalties')
          .where('bookId', isEqualTo: bookId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching penalty data: $e');
      return null;
    }
  }

  Future<void> _sendAlert(BuildContext context, String bookId) async {
    final TextEditingController _controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Alert to User"),
        content: TextField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Enter alert message..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = _controller.text.trim();
              if (message.isNotEmpty) {
                await FirebaseFirestore.instance.collection('alerts').add({
                  'userId': userId,
                  'bookId': bookId,
                  'message': message,
                  'timestamp': Timestamp.now(),
                  'isRead': false,
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Alert sent successfully")),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  String _getReturnStatus(Map<String, dynamic> requestData) {
    final isReturned = requestData['isReturned'] == true;
    final isReturnRequested = requestData['isReturnRequest'] == true;

    if (isReturned) {
      return '✅ Returned';
    } else if (isReturnRequested) {
      return '🔄 Return Requested';
    } else {
      return '❌ Not Returned';
    }
  }

  int _getSortPriority(Map<String, dynamic> data) {
    final isReturned = data['isReturned'] == true;
    final isReturnRequested = data['isReturnRequest'] == true;

    if (!isReturned && !isReturnRequested) return 0;
    if (isReturnRequested && !isReturned) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$userName\'s Borrowed Books')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lending_requests')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No borrowed books."));
          }

          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            return _getSortPriority(aData).compareTo(_getSortPriority(bData));
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final request = docs[index];
              final requestData = request.data() as Map<String, dynamic>;
              final bookId = requestData['bookId'];
              final timestamp = requestData['timestamp'] as Timestamp?;
              final returnStatus = _getReturnStatus(requestData);

              return FutureBuilder<Map<String, dynamic>?>(
                future: _fetchBookData(bookId),
                builder: (context, bookSnapshot) {
                  if (!bookSnapshot.hasData || bookSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text("Loading book..."));
                  }

                  final book = bookSnapshot.data!;
                  final title = book['title'] ?? 'Untitled';
                  final author = book['author'] ?? 'Unknown Author';
                  final dateBorrowed = timestamp != null
                      ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                      : 'Unknown Date';

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchPenaltyData(bookId),
                    builder: (context, penaltySnapshot) {
                      final penalty = penaltySnapshot.data;
                      final penaltyAmount = penalty?['penaltyAmount'];
                      final isPaid = penalty?['isPaid'] == true;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.book),
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Author: $author'),
                              Text('Borrowed on: $dateBorrowed'),
                              Text('Status: $returnStatus'),
                              if (penalty != null)
                                Text(
                                  'Penalty: ₹$penaltyAmount - ${isPaid ? "Paid" : "Unpaid"}',
                                  style: TextStyle(
                                    color: isPaid ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: ElevatedButton.icon(
                            icon: const Icon(Icons.warning_amber_rounded, size: 18),
                            label: const Text("Alert"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: () => _sendAlert(context, bookId),
                          ),
                        ),
                      );
                    },
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
