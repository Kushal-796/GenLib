import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libraryqr/screens/admin_users_borrowed_books_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminUsersListScreen extends StatelessWidget {
  const AdminUsersListScreen({super.key});

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.data();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> _generatePdf(List<String> userIds) async {
    final pdf = pw.Document();

    for (final id in userIds) {
      final userData = await _fetchUserData(id);
      if (userData == null) continue;

      final userName = userData['name'] ?? 'Unknown';
      final userEmail = userData['email'] ?? 'No Email';

      // Fetch approved lending requests for the user
      final lendingSnapshot = await FirebaseFirestore.instance
          .collection('lending_requests')
          .where('userId', isEqualTo: id)
          .where('status', isEqualTo: 'approved')
          .get();

      List<List<String>> bookRows = [];

      for (final doc in lendingSnapshot.docs) {
        final data = doc.data();
        final bookId = data['bookId'];
        final timestamp = (data['timestamp'] as Timestamp).toDate();

        // Fetch book details
        final bookSnapshot = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
        final bookData = bookSnapshot.data();
        if (bookData != null) {
          final title = bookData['title'] ?? 'Unknown Title';
          final author = bookData['author'] ?? 'Unknown Author';

          bookRows.add([
            title,
            author,
            "${timestamp.day}/${timestamp.month}/${timestamp.year}"
          ]);
        }
      }

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Text("User: $userName", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text("Email: $userEmail", style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text("Borrowed Books:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Title', 'Author', 'Borrowed On'],
              data: bookRows.isEmpty ? [['No books borrowed', '', '']] : bookRows,
            ),
            pw.Divider(),
          ],
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lending_requests')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;
          final Set<String> uniqueUserIds = requests.map((doc) => doc['userId'] as String).toSet();

          return ListView.builder(
            itemCount: uniqueUserIds.length,
            itemBuilder: (context, index) {
              final userId = uniqueUserIds.elementAt(index);
              return FutureBuilder<Map<String, dynamic>?>(
                future: _fetchUserData(userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  final userData = snapshot.data!;
                  final name = userData['name'] ?? 'Unknown';
                  final email = userData['email'] ?? 'No Email';

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(name),
                      subtitle: Text(email),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminUsersBorrowedBooksScreen(
                              userId: userId,
                              userName: name,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF91D7C3),
        icon: const Icon(Icons.download),
        label: const Text("Download PDF"),
        onPressed: () async {
          final lendingSnapshot = await FirebaseFirestore.instance
              .collection('lending_requests')
              .where('status', isEqualTo: 'approved')
              .get();
          final userIds = lendingSnapshot.docs.map((doc) => doc['userId'] as String).toSet().toList();
          await _generatePdf(userIds);
        },
      ),
    );
  }

}
