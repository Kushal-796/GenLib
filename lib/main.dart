import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/borrowed_books_screen.dart';
import 'screens/book_list_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.light);

  void _toggleTheme() {
    _themeNotifier.value =
    _themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Library App',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,

          // --------------------- LIGHT THEME ---------------------
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: const Color(0xFF91D7C3),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF91D7C3),
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF91D7C3),
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF91D7C3),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black),
            ),
            fontFamily: 'Roboto',
            cardTheme: CardTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),

          // --------------------- DARK THEME ---------------------
          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF1C1C1E),
            cardColor: const Color(0xFF2C2C2E),
            primaryColor: const Color(0xFF91D7C3),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF91D7C3),
              surface: Color(0xFF2C2C2E),
              onSurface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2C2C2E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF2C2C2E),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
            listTileTheme: const ListTileThemeData(
              iconColor: Colors.white,
              textColor: Colors.white,
            ),
            fontFamily: 'Roboto',
            cardTheme: const CardTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              color: Color(0xFF3A3A3C),
              elevation: 6,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Color(0xFF2C2C2E),
              border: OutlineInputBorder(),
            ),
          ),

          // --------------------- ROUTES ---------------------
          routes: {
            '/login': (_) => LoginScreen(onToggleTheme: _toggleTheme),
            '/booklist': (_) => BookListScreen(onToggleTheme: _toggleTheme),
            '/alerts': (_) => AlertsScreen(onToggleTheme: _toggleTheme),
            '/borrowedBooks': (_) => BorrowedBooksScreen(onToggleTheme: _toggleTheme),
            '/history': (_) => HistoryScreen(onToggleTheme: _toggleTheme),
          },

          // --------------------- HOME ---------------------
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return snapshot.hasData
                  ? BookListScreen(onToggleTheme: _toggleTheme)
                  : LoginScreen(onToggleTheme: _toggleTheme);
            },
          ),
        );
      },
    );
  }
}