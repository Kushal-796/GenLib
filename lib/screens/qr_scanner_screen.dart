// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'book_detail_screen.dart';
// import 'book_list_screen.dart';
//
//
// class QRScannerScreen extends StatefulWidget {
//   final VoidCallback onToggleTheme;
//   const QRScannerScreen({super.key, required this.onToggleTheme});
//
//   @override
//   State<QRScannerScreen> createState() => _QRScannerScreenState();
// }
//
//
// class _QRScannerScreenState extends State<QRScannerScreen> {
//   bool _isProcessing = false;
//
//   Future<void> _handleQRCode(String bookId) async {
//     if (_isProcessing) return;
//     setState(() => _isProcessing = true);
//
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('books')
//           .where('bookId', isEqualTo: bookId)
//           .limit(1)
//           .get();
//
//       if (snapshot.docs.isNotEmpty) {
//         final doc = snapshot.docs.first;
//         final bookData = doc.data();
//         final title = bookData['title'] ?? 'Untitled';
//         final author = bookData['author'] ?? 'Unknown Author';
//         final isAvailable = bookData['isAvailable'];
//         final docId = doc.id;
//
//         if (!mounted) return;
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => BookDetailScreen(
//               bookId: bookId,
//               title: title,
//               author: author,
//               isAvailable: isAvailable,
//             ),
//           ),
//         );
//
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("📚 Book not found in the database."),
//             backgroundColor: Colors.redAccent,
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("❌ Error: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       Navigator.pop(context);
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => BookListScreen(onToggleTheme: widget.onToggleTheme)),
//         );
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           title: const Text('Scan QR Code'),
//           backgroundColor: const Color(0xFF91D7C3),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => BookListScreen(onToggleTheme: widget.onToggleTheme)),
//               );
//             },
//           ),
//         ),
//         body: Stack(
//           children: [
//             MobileScanner(
//               onDetect: (barcodeCapture) {
//                 final barcode = barcodeCapture.barcodes.first;
//                 final String? code = barcode.rawValue;
//                 if (code != null) {
//                   _handleQRCode(code);
//                 }
//               },
//             ),
//             Center(
//               child: Container(
//                 width: 250,
//                 height: 250,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.white, width: 3),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     'Align QR here',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             if (_isProcessing)
//               Container(
//                 color: Colors.black.withOpacity(0.5),
//                 child: const Center(
//                   child: CircularProgressIndicator(color: Color(0xFF91D7C3)),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_screen.dart';
import 'book_list_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const QRScannerScreen({super.key, required this.onToggleTheme});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleQRCode(String bookId) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final bookData = doc.data();
        final title = bookData['title'] ?? 'Untitled';
        final author = bookData['author'] ?? 'Unknown Author';
        final isAvailable = bookData['isAvailable'];
        final docId = doc.id;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(
              bookId: bookId,
              title: title,
              author: author,
              isAvailable: isAvailable,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚫 Invalid QR Code"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BookListScreen(onToggleTheme: widget.onToggleTheme)),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          backgroundColor: const Color(0xFF91D7C3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BookListScreen(onToggleTheme: widget.onToggleTheme)),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            MobileScanner(
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                final String? code = barcode.rawValue;
                if (code != null) {
                  _handleQRCode(code);
                }
              },
            ),

            // Scanner Frame with Glow & Animating Line
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                                0, _animationController.value * 220),
                            child: Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              color: Colors.greenAccent,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Prompt text
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "📸 Align QR within the frame",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Progress overlay
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF91D7C3)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
