import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/home_page.dart';
import 'pages/add_item_page.dart';
import 'pages/profile_page.dart';
import 'pages/products_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/articles_page.dart';

import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'theme_notifier.dart';
import 'provider/cart_provider.dart'; // ✅ Tambahkan import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://inqkxchudfcofvczgnec.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlucWt4Y2h1ZGZjb2Z2Y3pnbmVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5ODMxNzQsImV4cCI6MjA2NTU1OTE3NH0.RKSiyNRU_h2IOHU50achFLuPK9ZUlUsNEeayqdYAa1U',
  );

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.containsKey('user_id');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => CartProvider()), // ✅ Tambahkan CartProvider
      ],
      child: SmartCartApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class SmartCartApp extends StatelessWidget {
  final bool isLoggedIn;
  const SmartCartApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.currentTheme,
      initialRoute: isLoggedIn ? '/main' : '/',
      routes: {
        '/': (context) => const login_page(),
        '/main': (context) => const MainScreen(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  final List<Widget> _pages = [
    HomePage(),
    ProductsPage(),
    ArticlesPage(),
    ProfilePage(onLogout: () {}),
  ];

  @override
  Widget build(BuildContext context) {
    _pages[3] = ProfilePage(onLogout: _handleLogout);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Artikel'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
