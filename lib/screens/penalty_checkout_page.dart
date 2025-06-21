import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PenaltyCheckoutPage extends StatefulWidget {
  final String penaltyId;
  final int amount;
  final String bookTitle;

  const PenaltyCheckoutPage({
    super.key,
    required this.penaltyId,
    required this.amount,
    required this.bookTitle,
  });

  @override
  State<PenaltyCheckoutPage> createState() => _PenaltyCheckoutPageState();
}

class _PenaltyCheckoutPageState extends State<PenaltyCheckoutPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_v9Yt3HAkNFB8sd', // Replace this with your Razorpay key
      'amount': widget.amount * 100, // Razorpay takes amount in paisa
      'name': 'Library Penalty',
      'description': 'Penalty for "${widget.bookTitle}"',
      'prefill': {'contact': '', 'email': ''},
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   // TODO: Mark penalty as paid in Firestore if needed
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Payment Successful!")),
  //   );
  //   Navigator.pop(context);
  // }
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await FirebaseFirestore.instance
          .collection('penalties')
          .doc(widget.penaltyId)
          .update({'isPaid': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful! Penalty updated.")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment successful but failed to update Firestore: $e")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Failed. Try again.")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Wallet selected: ${response.walletName}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penalty Checkout'),
        backgroundColor: const Color(0xFF91D7C3),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _startPayment,
          child: Text('Pay ₹${widget.amount} Now'),
        ),
      ),
    );
  }
}
