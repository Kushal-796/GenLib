// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class AdminAvailableBooksScreen extends StatelessWidget {
//   const AdminAvailableBooksScreen({super.key});
//
//   Future<void> _showRestockDialog(BuildContext context, String bookId) async {
//     final countController = TextEditingController();
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Add Copies"),
//         content: TextField(
//           controller: countController,
//           decoration: const InputDecoration(labelText: "Number of Copies to Add"),
//           keyboardType: TextInputType.number,
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           ElevatedButton(
//             onPressed: () async {
//               final added = int.tryParse(countController.text.trim());
//               if (added != null && added > 0) {
//                 final docRef = FirebaseFirestore.instance.collection('books').doc(bookId);
//                 final snapshot = await docRef.get();
//                 final current = (snapshot.data()?['count'] ?? 0) as int;
//
//                 await docRef.update({
//                   'count': current + added,
//                   'isAvailable': true,
//                 });
//
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("✅ Copies added successfully")),
//                 );
//               }
//             },
//             child: const Text("Confirm"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('books').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         final books = snapshot.data?.docs ?? [];
//
//         if (books.isEmpty) {
//           return const Center(child: Text('No books in library'));
//         }
//
//         return ListView.builder(
//           itemCount: books.length,
//           itemBuilder: (context, index) {
//             final doc = books[index];
//             final data = doc.data() as Map<String, dynamic>;
//             final title = data['title'] ?? 'No Title';
//             final author = data['author'] ?? 'Unknown';
//             final count = data['count'] ?? 0;
//             final isAvailable = data['isAvailable'] == true;
//
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               child: ListTile(
//                 leading: const Icon(Icons.book, color: Color(0xFF91D7C3)),
//                 title: Text(title),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Author: $author"),
//                     const SizedBox(height: 4),
//                     if (isAvailable) ...[
//                       Text(
//                         "Available Copies: $count",
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ] else ...[
//                       const Text(
//                         "Out of Stock",
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       ElevatedButton.icon(
//                         onPressed: () => _showRestockDialog(context, doc.id),
//                         icon: const Icon(Icons.add),
//                         label: const Text("Add Copies"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           textStyle: const TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminAvailableBooksScreen extends StatefulWidget {
  const AdminAvailableBooksScreen({super.key});

  @override
  State<AdminAvailableBooksScreen> createState() => _AdminAvailableBooksScreenState();
}

class _AdminAvailableBooksScreenState extends State<AdminAvailableBooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _showRestockDialog(BuildContext context, String bookId) async {
    final countController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Copies"),
        content: TextField(
          controller: countController,
          decoration: const InputDecoration(labelText: "Number of Copies to Add"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final added = int.tryParse(countController.text.trim());
              if (added != null && added > 0) {
                final docRef = FirebaseFirestore.instance.collection('books').doc(bookId);
                final snapshot = await docRef.get();
                final current = (snapshot.data()?['count'] ?? 0) as int;

                await docRef.update({
                  'count': current + added,
                  'isAvailable': true,
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Copies added successfully")),
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Search by Title or Author",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase().trim();
              });
            },
          ),
        ),

        // Book List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('books').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final books = snapshot.data?.docs ?? [];

              // Apply search filter
              final filteredBooks = books.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = (data['title'] ?? '').toString().toLowerCase();
                final author = (data['author'] ?? '').toString().toLowerCase();
                return title.contains(_searchQuery) || author.contains(_searchQuery);
              }).toList();

              if (filteredBooks.isEmpty) {
                return const Center(child: Text('No matching books found.'));
              }

              return ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final doc = filteredBooks[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'No Title';
                  final author = data['author'] ?? 'Unknown';
                  final count = data['count'] ?? 0;
                  final isAvailable = data['isAvailable'] == true;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.book, color: Color(0xFF91D7C3)),
                      title: Text(title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Author: $author"),
                          const SizedBox(height: 4),
                          if (isAvailable) ...[
                            Text(
                              "Available Copies: $count",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else ...[
                            const Text(
                              "Out of Stock",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton.icon(
                              onPressed: () => _showRestockDialog(context, doc.id),
                              icon: const Icon(Icons.add),
                              label: const Text("Add Copies"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
