import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:libraryqr/widgets/app_drawer.dart';

class AlertsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AlertsScreen({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _markAlertsAsRead();
  }


  Future<void> _markAlertsAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection('alerts')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in query.docs) {
      await FirebaseFirestore.instance
          .collection('alerts')
          .doc(doc.id)
          .update({'isRead': true});
    }
  }


  Stream<QuerySnapshot> _getAlertsStream() {
    return FirebaseFirestore.instance
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      drawer: AppDrawer(onToggleTheme: widget.onToggleTheme),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getAlertsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data!.docs;

          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts.'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(alert['message']),
                subtitle: Text(
                  alert['timestamp'] != null
                      ? (alert['timestamp'] as Timestamp).toDate().toString()
                      : '',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
