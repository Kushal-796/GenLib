import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/screens/alerts_screen.dart';
import 'package:libraryqr/screens/book_list_screen.dart';
import 'package:libraryqr/screens/borrowed_books_screen.dart';
import 'package:libraryqr/screens/history_screen.dart';
import 'package:libraryqr/screens/qr_scanner_screen.dart';

class AdminAppDrawer extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const AdminAppDrawer({super.key, required this.onToggleTheme});

  Future<String> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Admin';

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.exists ? (doc.data()?['name'] ?? 'Admin') : 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Admin';

    return Drawer(
      child: Container(
        color: const Color(0xFF91D7C3),
        child: Column(
          children: [
            FutureBuilder<String>(
              future: getUserName(),
              builder: (context, snapshot) {
                final userName = snapshot.data ?? 'Admin';

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF91D7C3)),
                  accountName: Text(userName, style: const TextStyle(color: Colors.black)),
                  accountEmail: Text(email, style: const TextStyle(color: Colors.black)),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, color: Colors.black),
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
                    leading: const Icon(Icons.history, color: Colors.black),
                    title: const Text('Returned History', style: TextStyle(color: Colors.black)),
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
              leading: const Icon(Icons.brightness_6, color: Colors.black),
              title: const Text('Toggle Theme', style: TextStyle(color: Colors.black)),
              onTap: onToggleTheme,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Logout', style: TextStyle(color: Colors.black)),
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