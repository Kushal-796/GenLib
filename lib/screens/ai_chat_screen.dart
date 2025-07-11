// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class JotformChatScreen extends StatefulWidget {
//   const JotformChatScreen({super.key});
//
//   @override
//   State<JotformChatScreen> createState() => _JotformChatScreenState();
// }
//
// class _JotformChatScreenState extends State<JotformChatScreen> {
//   late final WebViewController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadHtmlString('''
//         <!DOCTYPE html>
//         <html>
//           <head>
//             <meta name="viewport" content="width=device-width, initial-scale=1.0">
//           </head>
//           <body>
//             <script src="https://cdn.jotfor.ms/agent/embedjs/0197df79275370d4bc00ea46fc54846f90f8/embed.js?skipWelcome=1&maximizable=1"></script>
//           </body>
//         </html>
//       ''');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat Support'),
//         centerTitle: true,
//       ),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }
