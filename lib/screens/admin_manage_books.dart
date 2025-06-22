import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManageBooksScreen extends StatelessWidget {
  const AdminManageBooksScreen({super.key});

  Future<void> _addBookDialog(BuildContext context) async {
    final bookIdController = TextEditingController();
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final countController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Book"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bookIdController,
              decoration: const InputDecoration(labelText: "Book ID"),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: "Author"),
            ),
            TextField(
              controller: countController,
              decoration: const InputDecoration(labelText: "Number of Copies"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final bookId = bookIdController.text.trim();
              final title = titleController.text.trim();
              final author = authorController.text.trim();
              final count = int.tryParse(countController.text.trim());

              if (bookId.isNotEmpty && title.isNotEmpty && author.isNotEmpty && count != null) {
                await FirebaseFirestore.instance.collection('books').doc(bookId).set({
                  'bookId': bookId,
                  'title': title,
                  'author': author,
                  'count': count,
                  'isAvailable': true,
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Book added successfully")),
                );
              }
            },
            child: const Text("Add Book"),
          ),
        ],
      ),
    );
  }


  Future<void> _deleteBookDialog(BuildContext context) async {
    final bookIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Book"),
        content: TextField(
          controller: bookIdController,
          decoration: const InputDecoration(labelText: "Enter Book ID"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final bookId = bookIdController.text.trim();

              if (bookId.isNotEmpty) {
                final doc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
                if (doc.exists) {
                  await doc.reference.delete();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🗑️ Book deleted successfully")),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Book not found")),
                  );
                }
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _addBookDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Add Book"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _deleteBookDialog(context),
              icon: const Icon(Icons.delete),
              label: const Text("Delete Book"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
