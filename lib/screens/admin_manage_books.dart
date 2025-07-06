import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../widgets/admin_app_drawer.dart';

class AdminManageBooksScreen extends StatefulWidget {
  const AdminManageBooksScreen({super.key});

  @override
  State<AdminManageBooksScreen> createState() => _AdminManageBooksScreenState();
}

class _AdminManageBooksScreenState extends State<AdminManageBooksScreen> {
  final List<String> genres = const [
    'Technology', 'Story Books', 'Comics', 'Fiction', 'Sci-Fi',
    'Science', 'Mathematics', 'Literature', 'Spiritual',
    'General Knowledge', 'Biography'
  ];

  Future<void> _addBookDialog(BuildContext context) async {
    final bookIdController = TextEditingController();
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final countController = TextEditingController();
    String? selectedGenre;
    XFile? pickedImage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Book"),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: bookIdController, decoration: const InputDecoration(labelText: "Book ID")),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: authorController, decoration: const InputDecoration(labelText: "Author")),
                TextField(
                  controller: countController,
                  decoration: const InputDecoration(labelText: "Number of Copies"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Genre"),
                  value: selectedGenre,
                  onChanged: (value) => setState(() => selectedGenre = value),
                  items: genres.map((genre) => DropdownMenuItem(value: genre, child: Text(genre))).toList(),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (picked != null) setState(() => pickedImage = picked);
                  },
                  icon: const Icon(Icons.photo),
                  label: Text(pickedImage == null ? "Upload Cover Photo" : "Change Photo"),
                ),
                if (pickedImage != null) const Text("✅ Image selected", style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final bookId = bookIdController.text.trim();
              final title = titleController.text.trim();
              final author = authorController.text.trim();
              final count = int.tryParse(countController.text.trim());

              if (bookId.isNotEmpty && title.isNotEmpty && author.isNotEmpty && count != null && selectedGenre != null && pickedImage != null) {
                try {
                  final ref = FirebaseStorage.instanceFor(bucket: 'gen-lib.appspot.com')
                      .ref().child('book_covers/$bookId.jpg');
                  await ref.putFile(File(pickedImage!.path));
                  final imageUrl = await ref.getDownloadURL();

                  await FirebaseFirestore.instance.collection('books').doc(bookId).set({
                    'bookId': bookId,
                    'title': title,
                    'author': author,
                    'count': count,
                    'genre': selectedGenre,
                    'isAvailable': true,
                    'imageUrl': imageUrl,
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("📚 Book added with cover photo!")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Error: $e")),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("❗Fill all fields and pick an image")),
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
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🗑️ Book deleted successfully")),
                    );
                  }
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
      backgroundColor: const Color(0xFFF3FAF8),
      drawer: AdminAppDrawer(
        // selectedIndex: 6,
        // onItemSelected: (int index) {},
      ),
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
                      'Manage Books',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00253A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _addBookDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text("Add Book"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size.fromHeight(50),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _deleteBookDialog(context),
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete Book"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: const Size.fromHeight(50),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
