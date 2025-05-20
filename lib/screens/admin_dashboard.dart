import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:libraryqr/screens/admin_pending_requests.dart';
import 'package:libraryqr/screens/admin_processed_requests.dart';
import 'package:libraryqr/screens/return_requests_screen.dart';
import 'package:libraryqr/screens/login_screen.dart';
import 'package:libraryqr/screens/admin_available_books_screen.dart';
import 'package:libraryqr/screens/admin_users_list_screen.dart';
import 'package:libraryqr/screens/admin_penalty_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminAvailableBooksScreen(),
    AdminPendingRequests(),
    AdminProcessedRequests(),
    ReturnRequestsScreen(),
    AdminUsersListScreen(),
    AdminPenaltyScreen(),
  ];

  final List<String> _titles = const [
    'Available Books',
    'Pending Requests',
    'Processed Requests',
    'Return Requests',
    'Users',
    'Penalty'
  ];

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF91D7C3),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LoginScreen(onToggleTheme: () {})),
                      (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFF91D7C3),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF91D7C3),
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF91D7C3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 30,
                          color: Color(0xFF91D7C3),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? 'Admin',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.library_books),
                      title: const Text('Available Books'),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        setState(() => _selectedIndex = 0);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.hourglass_empty),
                      title: const Text('Pending Requests'),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: const Text('Processed Requests'),
                      selected: _selectedIndex == 2,
                      onTap: () {
                        setState(() => _selectedIndex = 2);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.assignment_return),
                      title: const Text('Return Requests'),
                      selected: _selectedIndex == 3,
                      onTap: () {
                        setState(() => _selectedIndex = 3);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Users'),
                      selected: _selectedIndex == 4,
                      onTap: () {
                        setState(() => _selectedIndex = 4);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: const Text('Penalty'),
                      selected: _selectedIndex == 5,
                      onTap: () {
                        setState(() => _selectedIndex = 5);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
