import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  final String title;
  final String author;
  final bool isAvailable;

  const BookDetailScreen({
    super.key,
    required this.bookId,
    required this.title,
    required this.author,
    required this.isAvailable,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isLoading = false;
  bool _requestMade = false;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkIfRequestAlreadyMade();
  }

  Future<void> _checkIfRequestAlreadyMade() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final query = await _firestore
        .collection('lending_requests')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: widget.bookId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        _requestMade = true;
      });
    }
  }

  Future<void> _sendBorrowRequest() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('lending_requests').add({
        'userId': user.uid,
        'bookId': widget.bookId,
        'status': 'pending',
        'timestamp': Timestamp.now(),
        'isReturned': false,
      });

      setState(() {
        _requestMade = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FDFD),
      appBar: AppBar(
        title: const Text("Book Details"),
        backgroundColor: const Color(0xFF91D7C3),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF91D7C3),
                child: const Icon(Icons.menu_book, size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Author: ${widget.author}",
                      style: const TextStyle(fontSize: 18, color: Color(0xFF555555)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Book ID: ${widget.bookId}",
                      style: const TextStyle(fontSize: 16, color: Color(0xFF777777)),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(_requestMade || !widget.isAvailable
                      ? Icons.check_circle
                      : Icons.send),
                  onPressed: (_requestMade || !widget.isAvailable)
                      ? null
                      : _sendBorrowRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _requestMade || !widget.isAvailable
                        ? Colors.grey.shade400
                        : const Color(0xFF91D7C3),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(
                    _requestMade || !widget.isAvailable ? "Request Made" : "Borrow",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
