import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/screens/book_detail_screen.dart';
import 'package:libraryqr/screens/alerts_screen.dart';
import 'package:libraryqr/widgets/app_drawer.dart';

class BookListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const BookListScreen({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  Stream<QuerySnapshot> getAvailableBooksStream() {
    return FirebaseFirestore.instance
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .snapshots();
  }

  Future<String?> checkRequestStatus(String bookId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final query = await FirebaseFirestore.instance
        .collection('lending_requests')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first['status'];
    }

    return null;
  }

  Stream<bool> hasUnreadAlerts() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF91D7C3),
        title: const Text('Available Books', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          StreamBuilder<bool>(
            stream: hasUnreadAlerts(),
            builder: (context, snapshot) {
              final hasUnread = snapshot.data ?? false;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlertsScreen(onToggleTheme: widget.onToggleTheme),
                        ),
                      );
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
                          shape: BoxShape.circle,
                          color: Colors.red,
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAvailableBooksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final books = snapshot.data?.docs ?? [];

                if (books.isEmpty) {
                  return const Center(child: Text('No available books at the moment.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final title = book['title'] ?? 'Untitled';
                    final author = book['author'] ?? 'Unknown Author';
                    final bookId = book['bookId'];
                    final isAvailable = book['isAvailable'];

                    return FutureBuilder<String?>(
                      future: checkRequestStatus(bookId),
                      builder: (context, requestSnapshot) {
                        final requestStatus = requestSnapshot.data;
                        final isRequestMade = requestStatus == 'pending' || requestStatus == 'approved';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookDetailScreen(
                                  bookId: bookId,
                                  title: title,
                                  author: author,
                                  isAvailable: isAvailable,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'by $author',
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  isRequestMade
                                      ? const Text(
                                    'Request Made',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                      : const Icon(Icons.arrow_forward_ios, color: Color(0xFF91D7C3), size: 20),
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
          ),
        ],
      ),
    );
  }
}
