
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/book_list_screen.dart';
import '../screens/borrowed_books_screen.dart';
import '../screens/history_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/penalty_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const AppDrawer({super.key, required this.onToggleTheme});

  Future<String> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'User';

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.exists ? (doc.data()?['name'] ?? 'User') : 'User';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'User';

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            FutureBuilder<String>(
              future: getUserName(),
              builder: (context, snapshot) {
                final userName = snapshot.data ?? 'User';

                return Container(
                  color: const Color(0xFF91D7C3),
                  child: UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xFF91D7C3)),
                    accountName: Text(userName, style: const TextStyle(color: Colors.black)),
                    accountEmail: Text(email, style: const TextStyle(color: Colors.black)),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.book, color: Colors.black),
                    title: const Text('Available Books', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => BookListScreen(onToggleTheme: onToggleTheme)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner, color: Colors.black),
                    title: const Text('Scan QR', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => QRScannerScreen(onToggleTheme: onToggleTheme)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark, color: Colors.black),
                    title: const Text('My Borrowed Books', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => BorrowedBooksScreen(onToggleTheme: onToggleTheme)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.black),
                    title: const Text('Alerts', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => AlertsScreen(onToggleTheme: onToggleTheme)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money, color: Colors.black),
                    title: const Text('Penalty', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => PenaltyScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.black),
                    title: const Text('History', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HistoryScreen(onToggleTheme: onToggleTheme)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.black),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}