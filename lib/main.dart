import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/journal_list_screen.dart';
import 'screens/trends_screen.dart'; // ✅ import baru
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  // 🧠 Wajib dipanggil karena dotenv membutuhkan inisialisasi async
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 Load file .env dari root proyek
  await dotenv.load(fileName: ".env");

  // 🚀 Jalankan aplikasi
  runApp(const MoodiaryApp());
}

class MoodiaryApp extends StatelessWidget {
  const MoodiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodiary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFBB86FC),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    JournalListScreen(),
    TrendsScreen(), // ✅ page baru
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFBB86FC),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Trends',
          ),
        ],
      ),
    );
  }
}

