import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const CustomDrawer({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: const Color(0xFF91D7C3), // Ocean Blue
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            currentAccountPicture: CircleAvatar(
              backgroundColor: const Color(0xFF91D7C3),
              child: Text(
                user?.displayName != null && user!.displayName!.isNotEmpty
                    ? user.displayName![0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            accountName: Text(
              user?.displayName ?? 'User',
              style: const TextStyle(color: Colors.black),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.black54),
            ),
            otherAccountsPictures: [
              IconButton(
                icon: const Icon(Icons.brightness_6, color: Colors.black),
                onPressed: onToggleTheme,
              )
            ],
          ),

          _buildDrawerItem(Icons.person, 'Available Books', context, '/booklist'),
          _buildDrawerItem(Icons.book, 'Borrowed Books', context, '/borrowedBooks'),
          _buildDrawerItem(Icons.notifications, 'Alerts', context, '/alerts'),
          _buildDrawerItem(Icons.history, 'History', context, '/history'),

          const Spacer(),

          const Divider(color: Colors.white70),
          _buildLogoutTile(context),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.white),
      title: const Text('Logout', style: TextStyle(color: Colors.white)),
      onTap: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        );

        if (shouldLogout ?? false) {
          Navigator.pop(context); // Close drawer
          await FirebaseAuth.instance.signOut(); // Sign out
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
    );
  }
}
