import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:slide_to_act/slide_to_act.dart';

class PenaltyCheckoutPage extends StatefulWidget {
  final String penaltyId;

  const PenaltyCheckoutPage({super.key, required this.penaltyId});

  @override
  State<PenaltyCheckoutPage> createState() => _PenaltyCheckoutPageState();
}

class _PenaltyCheckoutPageState extends State<PenaltyCheckoutPage> {
  late Razorpay _razorpay;
  DocumentSnapshot? penaltyDetails;
  DocumentSnapshot? bookDetails;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchDetails();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    try {
      final penaltyDoc = await FirebaseFirestore.instance
          .collection('penalties')
          .doc(widget.penaltyId)
          .get();

      final bookId = penaltyDoc['bookId'];

      final bookQuery = await FirebaseFirestore.instance
          .collection('books')
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (bookQuery.docs.isNotEmpty) {
        setState(() {
          penaltyDetails = penaltyDoc;
          bookDetails = bookQuery.docs.first;
        });
      }
    } catch (e) {
      debugPrint('Error fetching details: $e');
    }
  }

  void _startPayment() {
    final amount = penaltyDetails!['penaltyAmount'];
    final title = bookDetails!['title'];

    var options = {
      'key': 'rzp_test_v9Yt3HAkNFB8sd', // Replace with your Razorpay key
      'amount': amount * 100,
      'name': 'Library Penalty',
      'description': 'Penalty for "$title"',
      'prefill': {'contact': '', 'email': ''},
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await FirebaseFirestore.instance
          .collection('penalties')
          .doc(widget.penaltyId)
          .update({'isPaid': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Payment Successful!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Payment Failed. Try again.")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("💰 Wallet Selected: ${response.walletName}")),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return "${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF8),
      appBar: AppBar(
        title: const Text(
          'Penalty Checkout',
          style: TextStyle(color: Color(0xFF00253A), fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00253A)),
      ),
      body: (penaltyDetails == null || bookDetails == null)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  radius: 35,
                  child: const Icon(Icons.book, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '📕 Title: ${bookDetails!['title']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00253A)),
              ),
              const SizedBox(height: 10),
              Text(
                '✍️ Author: ${bookDetails!['author']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                '🆔 Book ID: ${penaltyDetails!['bookId']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                '🕒 Lended on: ${_formatTimestamp(penaltyDetails!['timestamp'])}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              SlideAction(
                outerColor: Colors.indigo,
                innerColor: Colors.white,
                elevation: 1,
                sliderButtonIcon: const Icon(Icons.payment, color: Colors.black),
                text: 'Slide to Pay ₹${penaltyDetails!['penaltyAmount']}',
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                onSubmit: () {
                  _startPayment();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
