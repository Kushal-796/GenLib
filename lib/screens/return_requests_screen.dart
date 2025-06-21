// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ReturnRequestsScreen extends StatelessWidget {
//   const ReturnRequestsScreen({super.key});
//
//   Future<String> _getUserName(String userId) async {
//     try {
//       final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//       if (userDoc.exists) {
//         return userDoc.data()?['name'] ?? 'Unknown User';
//       }
//     } catch (e) {
//       debugPrint('Error fetching user name: $e');
//     }
//     return 'Unknown User';
//   }
//
//   Future<String> _getBookTitle(String bookId) async {
//     try {
//       final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
//       if (bookDoc.exists) {
//         return bookDoc.data()?['title'] ?? 'Unknown Book';
//       }
//     } catch (e) {
//       debugPrint('Error fetching book title: $e');
//     }
//     return 'Unknown Book';
//   }
//
//   Future<void> _processReturnRequest(
//       BuildContext context, String docId, String bookId, bool approve) async {
//     final firestore = FirebaseFirestore.instance;
//     final returnRequestRef = firestore.collection('return_requests').doc(docId);
//     final bookRef = firestore.collection('books').doc(bookId);
//
//     try {
//       if (approve) {
//         await firestore.runTransaction((transaction) async {
//           final bookSnap = await transaction.get(bookRef);
//           final returnRequestSnap = await transaction.get(returnRequestRef);
//
//           if (!bookSnap.exists || !returnRequestSnap.exists) {
//             throw Exception("Book or return request not found");
//           }
//
//           final currentCount = bookSnap.get('count');
//           final newCount = currentCount + 1;
//
//           final returnRequestData = returnRequestSnap.data();
//           final lendingRequestId = returnRequestData?['lendingRequestId'];
//           final penaltyId = returnRequestData != null && returnRequestData.containsKey('penaltyId')
//               ? returnRequestData['penaltyId']
//               : null;
//
//           final lendingRequestRef = firestore.collection('lending_requests').doc(lendingRequestId);
//           final penaltyRef = penaltyId != null
//               ? firestore.collection('penalties').doc(penaltyId)
//               : null;
//
//           transaction.update(bookRef, {
//             'count': newCount,
//             'isAvailable': true,
//           });
//
//           transaction.update(returnRequestRef, {
//             'status': 'approved',
//             'processedAt': Timestamp.now(),
//           });
//
//           transaction.update(lendingRequestRef, {
//             'isReturned': true,
//             'returnRequestStatus': 'approved',
//           });
//
//           if (penaltyRef != null) {
//             transaction.update(penaltyRef, {
//               'isPaid': true,
//             });
//           }
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Return request approved and penalty marked as paid')),
//         );
//       } else {
//         final returnRequestSnap = await returnRequestRef.get();
//         if (!returnRequestSnap.exists) {
//           throw Exception("Return request not found");
//         }
//
//         final returnRequestData = returnRequestSnap.data() as Map<String, dynamic>?;
//         final lendingRequestId = returnRequestData?['lendingRequestId'];
//
//         final lendingRequestRef = firestore.collection('lending_requests').doc(lendingRequestId);
//
//         await firestore.runTransaction((transaction) async {
//           transaction.update(returnRequestRef, {
//             'status': 'rejected',
//             'processedAt': Timestamp.now(),
//           });
//
//           transaction.update(lendingRequestRef, {
//             'isReturnRequest': false,
//             'returnRequestStatus': 'rejected',
//           });
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Return request rejected')),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error processing return request: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to process request: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('return_requests')
//             .where('status', isEqualTo: 'pending')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final docs = snapshot.data?.docs ?? [];
//
//           if (docs.isEmpty) {
//             return const Center(child: Text('No return requests.'));
//           }
//
//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               final docId = docs[index].id;
//               final bookId = data['bookId'] ?? 'Unknown';
//               final userId = data['userId'] ?? 'Unknown';
//
//               return FutureBuilder<List<String>>(
//                 future: Future.wait([
//                   _getUserName(userId),
//                   _getBookTitle(bookId),
//                 ]),
//                 builder: (context, snapshot) {
//                   final userName = snapshot.data?[0] ?? 'Loading...';
//                   final bookTitle = snapshot.data?[1] ?? 'Loading...';
//
//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: ListTile(
//                       leading: const Icon(Icons.assignment_return),
//                       title: Text(bookTitle),
//                       subtitle: Text('User: $userName'),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.check, color: Colors.green),
//                             onPressed: () => _processReturnRequest(context, docId, bookId, true),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close, color: Colors.red),
//                             onPressed: () => _processReturnRequest(context, docId, bookId, false),
//                           ),
//                         ],
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

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ReturnRequestsScreen extends StatelessWidget {
//   const ReturnRequestsScreen({super.key});
//
//   Future<String> _getUserName(String userId) async {
//     try {
//       final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//       if (userDoc.exists) {
//         return userDoc.data()?['name'] ?? 'Unknown User';
//       }
//     } catch (e) {
//       debugPrint('Error fetching user name: $e');
//     }
//     return 'Unknown User';
//   }
//
//   Future<String> _getBookTitle(String bookId) async {
//     try {
//       final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
//       if (bookDoc.exists) {
//         return bookDoc.data()?['title'] ?? 'Unknown Book';
//       }
//     } catch (e) {
//       debugPrint('Error fetching book title: $e');
//     }
//     return 'Unknown Book';
//   }
//
//   Future<void> _processReturnRequest(
//       BuildContext context, String lendingRequestId, String bookId, bool approve, String? penaltyId) async {
//     final firestore = FirebaseFirestore.instance;
//     final lendingRequestRef = firestore.collection('lending_requests').doc(lendingRequestId);
//     final bookRef = firestore.collection('books').doc(bookId);
//     final penaltyRef = penaltyId != null ? firestore.collection('penalties').doc(penaltyId) : null;
//
//     try {
//       if (approve) {
//         await firestore.runTransaction((transaction) async {
//           final bookSnap = await transaction.get(bookRef);
//           final lendingSnap = await transaction.get(lendingRequestRef);
//
//           if (!bookSnap.exists || !lendingSnap.exists) {
//             throw Exception("Book or lending request not found");
//           }
//
//           final currentCount = bookSnap.get('count');
//           final newCount = currentCount + 1;
//
//           transaction.update(bookRef, {
//             'count': newCount,
//             'isAvailable': true,
//           });
//
//           transaction.update(lendingRequestRef, {
//             'returnRequestStatus': 'approved',
//             'isReturned': true,
//             'isReturnRequest': false,
//             'processedAt': Timestamp.now(),
//           });
//
//           if (penaltyRef != null) {
//             transaction.update(penaltyRef, {
//               'isPaid': true,
//             });
//           }
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Return request approved and penalty marked as paid')),
//         );
//       } else {
//         await lendingRequestRef.update({
//           'returnRequestStatus': 'rejected',
//           'isReturnRequest': false,
//           'processedAt': Timestamp.now(),
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Return request rejected')),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error processing return request: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to process request: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text("Return Requests")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('lending_requests')
//             .where('isReturnRequest', isEqualTo: true)
//             .where('returnRequestStatus', isEqualTo: 'pending')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final docs = snapshot.data?.docs ?? [];
//
//           if (docs.isEmpty) {
//             return const Center(child: Text('No return requests.'));
//           }
//
//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               final lendingRequestId = docs[index].id;
//               final bookId = data['bookId'] ?? 'Unknown';
//               final userId = data['userId'] ?? 'Unknown';
//               final penaltyId = data.containsKey('penaltyId') ? data['penaltyId'] : null;
//
//               return FutureBuilder<List<String>>(
//                 future: Future.wait([
//                   _getUserName(userId),
//                   _getBookTitle(bookId),
//                 ]),
//                 builder: (context, snapshot) {
//                   final userName = snapshot.data?[0] ?? 'Loading...';
//                   final bookTitle = snapshot.data?[1] ?? 'Loading...';
//
//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: ListTile(
//                       leading: const Icon(Icons.assignment_return),
//                       title: Text(bookTitle),
//                       subtitle: Text('User: $userName'),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.check, color: Colors.green),
//                             onPressed: () => _processReturnRequest(
//                                 context, lendingRequestId, bookId, true, penaltyId),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close, color: Colors.red),
//                             onPressed: () => _processReturnRequest(
//                                 context, lendingRequestId, bookId, false, penaltyId),
//                           ),
//                         ],
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

class ReturnRequestsScreen extends StatelessWidget {
  const ReturnRequestsScreen({super.key});

  Future<Map<String, dynamic>> _fetchDetails(
      String userId, String bookId, String? penaltyId) async {
    String userName = 'Unknown';
    String bookTitle = 'Unknown';
    bool canApprove = true;

    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        userName = userDoc.data()?['name'] ?? 'Unknown';
      }

      final bookDoc =
      await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      if (bookDoc.exists) {
        bookTitle = bookDoc.data()?['title'] ?? 'Unknown';
      }

      if (penaltyId != null && penaltyId.toString().isNotEmpty) {
        final penaltyDoc = await FirebaseFirestore.instance
            .collection('penalties')
            .doc(penaltyId)
            .get();

        if (penaltyDoc.exists) {
          final penaltyData = penaltyDoc.data()!;
          final isPaid = penaltyData['isPaid'] == true;
          final penaltyAmount = (penaltyData['penaltyAmount'] ?? 0).toDouble();

          debugPrint(
              "🧾 Penalty for $penaltyId → isPaid: $isPaid | Amount: $penaltyAmount");

          if (!isPaid && penaltyAmount > 0) {
            canApprove = false;
          }
        }
      }
    } catch (e) {
      debugPrint("🔥 Error in _fetchDetails: $e");
    }

    return {
      'userName': userName,
      'bookTitle': bookTitle,
      'canApprove': canApprove,
    };
  }

  Future<void> _processReturnRequest(
      BuildContext context,
      String lendingRequestId,
      String bookId,
      bool approve,
      String? penaltyId,
      ) async {
    final firestore = FirebaseFirestore.instance;
    final lendingRef =
    firestore.collection('lending_requests').doc(lendingRequestId);
    final bookRef = firestore.collection('books').doc(bookId);
    final penaltyRef = penaltyId != null && penaltyId.isNotEmpty
        ? firestore.collection('penalties').doc(penaltyId)
        : null;

    try {
      if (approve) {
        await firestore.runTransaction((txn) async {
          final bookSnap = await txn.get(bookRef);
          final requestSnap = await txn.get(lendingRef);

          if (!bookSnap.exists || !requestSnap.exists) {
            throw Exception('Book or request not found');
          }

          final currentCount = bookSnap.get('count') ?? 0;

          txn.update(bookRef, {
            'count': currentCount + 1,
            'isAvailable': true,
          });

          txn.update(lendingRef, {
            'isReturned': true,
            'isReturnRequest': false,
            'returnRequestStatus': 'approved',
            'processedAt': Timestamp.now(),
          });

          if (penaltyRef != null) {
            txn.update(penaltyRef, {
              'isPaid': true,
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Return approved ✅")),
        );
      } else {
        await lendingRef.update({
          'isReturnRequest': false,
          'returnRequestStatus': 'rejected',
          'processedAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Return request rejected ❌")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error processing return: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lending_requests')
            .where('isReturnRequest', isEqualTo: true)
            .where('returnRequestStatus', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No return requests."));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              final requestId = doc.id;
              final bookId = data['bookId'];
              final userId = data['userId'];
              final penaltyId = data['penaltyId'];

              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchDetails(userId, bookId, penaltyId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  final details = snapshot.data!;
                  final userName = details['userName'] ?? 'User';
                  final bookTitle = details['bookTitle'] ?? 'Unknown';
                  final canApprove = details['canApprove'] ?? false;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.assignment_return),
                      title: Text(
                        'User: $userName',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Book: $bookTitle'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: canApprove
                                ? 'Approve return'
                                : 'Blocked: unpaid penalty',
                            child: IconButton(
                              icon: Icon(
                                Icons.check,
                                color: canApprove ? Colors.green : Colors.grey,
                              ),
                              onPressed: canApprove
                                  ? () => _processReturnRequest(context, requestId, bookId, true, penaltyId)
                                  : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _processReturnRequest(context, requestId, bookId, false, penaltyId),
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
