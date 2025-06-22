import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libraryqr/screens/admin_users_borrowed_books_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminUsersListScreen extends StatefulWidget {
  const AdminUsersListScreen({super.key});

  @override
  State<AdminUsersListScreen> createState() => _AdminUsersListScreenState();
}

class _AdminUsersListScreenState extends State<AdminUsersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.data();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> _generateExcelStylePdf() async {
    final pdf = pw.Document();

    final lendingSnapshot = await FirebaseFirestore.instance
        .collection('lending_requests')
        .where('status', isEqualTo: 'approved')
        .orderBy('timestamp', descending: true)
        .get();

    final rows = <List<String>>[];
    int serial = 1;

    for (final doc in lendingSnapshot.docs) {
      final data = doc.data();
      final userId = data['userId'];
      final bookId = data['bookId'];
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final formattedDate = "${timestamp.day}/${timestamp.month}/${timestamp.year}";

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? 'Unknown';
      final userEmail = userData['email'] ?? 'No Email';

      final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      final bookData = bookDoc.data() ?? {};
      final bookTitle = bookData['title'] ?? 'Unknown';
      final author = bookData['author'] ?? 'Unknown';

      final penaltySnapshot = await FirebaseFirestore.instance
          .collection('penalties')
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      String penalty = "0 (Paid)";
      if (penaltySnapshot.docs.isNotEmpty) {
        final penaltyData = penaltySnapshot.docs.first.data();
        final amount = (penaltyData['penaltyAmount'] ?? 0).toDouble();
        final isPaid = penaltyData['isPaid'] == true;
        penalty = "${amount.toStringAsFixed(0)} (${isPaid ? 'Paid' : 'Unpaid'})";
      }

      rows.add([
        serial.toString(),
        userName,
        userEmail,
        bookId,
        bookTitle,
        author,
        formattedDate,
        penalty,
      ]);

      serial++;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Text("Library Lending & Penalty Report", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: [
              'S no',
              'User name',
              'User mail',
              'BookId',
              'Book name',
              'Author',
              'Borrowed date',
              'Penalty'
            ],
            data: rows,
            headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 10),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      format: PdfPageFormat.a4.landscape,
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search by name or email",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                return FutureBuilder<List<Widget>>(
                  future: _buildUserCards(uniqueUserIds),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final cards = snapshot.data!;
                    return cards.isEmpty
                        ? const Center(child: Text("No matching users found."))
                        : ListView(children: cards);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF91D7C3),
        icon: const Icon(Icons.download),
        label: const Text("Download PDF"),
        onPressed: () async {
          await _generateExcelStylePdf();
        },
      ),
    );
  }

  Future<List<Widget>> _buildUserCards(Set<String> userIds) async {
    List<Widget> cards = [];

    for (final userId in userIds) {
      final userData = await _fetchUserData(userId);
      if (userData == null) continue;

      final name = (userData['name'] ?? '').toString();
      final email = (userData['email'] ?? '').toString();

      final matchesQuery = _searchQuery.isEmpty ||
          name.toLowerCase().contains(_searchQuery) ||
          email.toLowerCase().contains(_searchQuery);

      if (matchesQuery) {
        cards.add(
          Card(
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
          ),
        );
      }
    }
    return cards;
  }
}
