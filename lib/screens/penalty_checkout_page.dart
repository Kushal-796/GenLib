// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // import 'package:slide_to_act/slide_to_act.dart'; // <-- import this at the top
// //
// //
// // class PenaltyCheckoutPage extends StatefulWidget {
// //   final String penaltyId;
// //   final int amount;
// //   final String bookTitle;
// //
// //   const PenaltyCheckoutPage({
// //     super.key,
// //     required this.penaltyId,
// //     required this.amount,
// //     required this.bookTitle,
// //   });
// //
// //   @override
// //   State<PenaltyCheckoutPage> createState() => _PenaltyCheckoutPageState();
// // }
// //
// // class _PenaltyCheckoutPageState extends State<PenaltyCheckoutPage> {
// //   late Razorpay _razorpay;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _razorpay = Razorpay();
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _razorpay.clear();
// //     super.dispose();
// //   }
// //
// //   void _startPayment() {
// //     var options = {
// //       'key': 'rzp_test_v9Yt3HAkNFB8sd', // Replace this with your Razorpay key
// //       'amount': widget.amount * 100, // Razorpay takes amount in paisa
// //       'name': 'Library Penalty',
// //       'description': 'Penalty for "${widget.bookTitle}"',
// //       'prefill': {'contact': '', 'email': ''},
// //       'external': {'wallets': ['paytm']},
// //     };
// //
// //     try {
// //       _razorpay.open(options);
// //     } catch (e) {
// //       debugPrint('Error: $e');
// //     }
// //   }
// //
// //   // void _handlePaymentSuccess(PaymentSuccessResponse response) {
// //   //   // TODO: Mark penalty as paid in Firestore if needed
// //   //   ScaffoldMessenger.of(context).showSnackBar(
// //   //     const SnackBar(content: Text("Payment Successful!")),
// //   //   );
// //   //   Navigator.pop(context);
// //   // }
// //   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
// //     try {
// //       await FirebaseFirestore.instance
// //           .collection('penalties')
// //           .doc(widget.penaltyId)
// //           .update({'isPaid': true});
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Payment Successful! Penalty updated.")),
// //       );
// //       Navigator.pop(context);
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Payment successful but failed to update Firestore: $e")),
// //       );
// //     }
// //   }
// //
// //   void _handlePaymentError(PaymentFailureResponse response) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text("Payment Failed. Try again.")),
// //     );
// //   }
// //
// //   void _handleExternalWallet(ExternalWalletResponse response) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text("Wallet selected: ${response.walletName}")),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Penalty Checkout'),
// //         backgroundColor: const Color(0xFF91D7C3),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text(
// //               'Penalty Amount: ₹${widget.amount}',
// //               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 30),
// //             Builder(
// //               builder: (context) {
// //                 final GlobalKey<SlideActionState> key = GlobalKey();
// //                 return SlideAction(
// //                   key: key,
// //                   onSubmit: () {
// //                     _startPayment();
// //
// //                     // Optional: reset the slider after a short delay
// //                     Future.delayed(const Duration(seconds: 2), () {
// //                       key.currentState?.reset();
// //                     });
// //                   },
// //                   text: 'Slide to Pay',
// //                   innerColor: Colors.white,
// //                   outerColor: const Color(0xFF91D7C3),
// //                   elevation: 4,
// //                   sliderButtonIcon: const Icon(Icons.payment, color: Colors.black),
// //                 );
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //
// //     );
// //   }
// // }
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:slide_to_act/slide_to_act.dart';
//
// class PenaltyCheckoutPage extends StatefulWidget {
//   final String penaltyId;
//   final int amount;
//   final String bookTitle;
//
//   const PenaltyCheckoutPage({
//     super.key,
//     required this.penaltyId,
//     required this.amount,
//     required this.bookTitle,
//   });
//
//   @override
//   State<PenaltyCheckoutPage> createState() => _PenaltyCheckoutPageState();
// }
//
// class _PenaltyCheckoutPageState extends State<PenaltyCheckoutPage> {
//   late Razorpay _razorpay;
//   DocumentSnapshot? penaltyDetails;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     _fetchPenaltyDetails();
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   Future<void> _fetchPenaltyDetails() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('penalties')
//           .doc(widget.penaltyId)
//           .get();
//
//       setState(() {
//         penaltyDetails = doc;
//       });
//     } catch (e) {
//       debugPrint('Error fetching penalty details: $e');
//     }
//   }
//
//   void _startPayment() {
//     var options = {
//       'key': 'rzp_test_v9Yt3HAkNFB8sd', // Replace with your actual Razorpay key
//       'amount': widget.amount * 100, // Razorpay takes amount in paisa
//       'name': 'Library Penalty',
//       'description': 'Penalty for "${widget.bookTitle}"',
//       'prefill': {'contact': '', 'email': ''},
//       'external': {'wallets': ['paytm']},
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('penalties')
//           .doc(widget.penaltyId)
//           .update({'isPaid': true});
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment Successful! Penalty updated.")),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Payment successful but failed to update Firestore: $e")),
//       );
//     }
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Payment Failed. Try again.")),
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Wallet selected: ${response.walletName}")),
//     );
//   }
//
//   String _formatTimestamp(Timestamp timestamp) {
//     final dateTime = timestamp.toDate();
//     return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Penalty Checkout'),
//         backgroundColor: const Color(0xFF91D7C3),
//       ),
//       body: penaltyDetails == null
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '📖 Book: ${penaltyDetails!['bookTitle']}',
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               '🆔 Book ID: ${penaltyDetails!['bookId']}',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               '🕒 Lended on: ${_formatTimestamp(penaltyDetails!['lendTime'])}',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 40),
//             Builder(
//               builder: (context) {
//                 final GlobalKey<SlideActionState> key = GlobalKey();
//                 return SlideAction(
//                   key: key,
//                   onSubmit: () {
//                     _startPayment();
//                     Future.delayed(const Duration(seconds: 2), () {
//                       key.currentState?.reset();
//                     });
//                   },
//                   text: 'Slide to Pay ₹${widget.amount}',
//                   innerColor: Colors.white,
//                   outerColor: const Color(0xFF91D7C3),
//                   elevation: 4,
//                   sliderButtonIcon: const Icon(Icons.payment, color: Colors.black),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:slide_to_act/slide_to_act.dart';

class PenaltyCheckoutPage extends StatefulWidget {
  final String penaltyId;

  const PenaltyCheckoutPage({
    super.key,
    required this.penaltyId,
  });

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
      } else {
        debugPrint("No matching book found for bookId: $bookId");
      }
    } catch (e) {
      debugPrint('Error fetching details: $e');
    }
  }

  void _startPayment() {
    final amount = penaltyDetails!['penaltyAmount'];
    final title = bookDetails!['title'];

    var options = {
      'key': 'rzp_test_v9Yt3HAkNFB8sd', // Replace with your Razorpay Key
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
        const SnackBar(content: Text("Payment Successful! Penalty marked as paid.")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment succeeded, but failed to update Firestore: $e")),
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

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return "${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penalty Checkout'),
        backgroundColor: const Color(0xFF91D7C3),
      ),
      body: (penaltyDetails == null || bookDetails == null)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📕 Title: ${bookDetails!['title']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '✍️ Author: ${bookDetails!['author']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '🆔 Book ID: ${penaltyDetails!['bookId']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '🕒 Lended on: ${_formatTimestamp(penaltyDetails!['timestamp'])}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Builder(
              builder: (context) {
                final GlobalKey<SlideActionState> key = GlobalKey();
                return SlideAction(
                  key: key,
                  onSubmit: () {
                    _startPayment();
                    Future.delayed(const Duration(seconds: 2), () {
                      key.currentState?.reset();
                    });
                  },
                  text:
                  'Slide to Pay ₹${penaltyDetails!['penaltyAmount']}',
                  innerColor: Colors.white,
                  outerColor: const Color(0xFF91D7C3),
                  elevation: 4,
                  sliderButtonIcon:
                  const Icon(Icons.payment, color: Colors.black),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
