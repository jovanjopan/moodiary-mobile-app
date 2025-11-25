import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/journal_list_screen.dart';
import 'screens/counselor_screen.dart';
import 'screens/profile_screen.dart';
// import 'screens/trends_screen.dart';
import 'screens/splash_screen.dart'; // ✅ Import Splash

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env not found");
  }
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
      home: const SplashScreen(), // ✅ Mulai dari sini
    );
  }
}

// 🏠 MAIN PAGE UTAMA (Wadah Bottom Navigation)
// Ini dipanggil setelah Login/Register sukses
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
    CounselorScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1E1E1E),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFBB86FC),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
            BottomNavigationBarItem(
              icon: Icon(Icons.wechat_sharp),
              label: 'Counselor',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
