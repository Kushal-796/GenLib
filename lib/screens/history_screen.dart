import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/screens/book_list_screen.dart';
import 'package:libraryqr/screens/login_screen.dart';
import 'package:libraryqr/screens/alerts_screen.dart';
import 'package:libraryqr/widgets/app_drawer.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HistoryScreen({super.key, required this.onToggleTheme});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchReturnedBooks() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final lendingSnapshot = await _firestore
        .collection('lending_requests')
        .where('userId', isEqualTo: user.uid)
        .where('isReturned', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> history = [];

    for (var doc in lendingSnapshot.docs) {
      final lendingData = doc.data();
      final bookId = lendingData['bookId'];

      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      final bookData = bookDoc.data();

      if (bookData != null) {
        history.add({
          'title': bookData['title'],
          'author': bookData['author'],
          'timestamp': lendingData['timestamp'],
        });
      }
    }

    return history;
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

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: () {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BookListScreen(onToggleTheme: widget.onToggleTheme)),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF91D7C3),
          title: const Text('History', style: TextStyle(color: Colors.black)),
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
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchReturnedBooks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final history = snapshot.data ?? [];

            if (history.isEmpty) {
              return const Center(child: Text('No returned books history found.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final formattedDate = item['timestamp'] != null
                    ? (item['timestamp'] as Timestamp).toDate()
                    : DateTime.now();

                return Card(
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
                              item['title'] ?? 'Unknown Title',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'by ${item['author'] ?? 'Unknown Author'}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Returned on: ${formattedDate.day}/${formattedDate.month}/${formattedDate.year}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const Chip(
                          label: Text('RETURNED', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
