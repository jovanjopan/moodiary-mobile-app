import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/db_helper.dart';
import '../data_models/user_model.dart';
import '../main.dart'; // Untuk navigasi ke MainPage

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  // Pilihan Avatar Emoji
  final List<String> _emojis = [
    '😎',
    '🥰',
    '🤠',
    '😊',
    '🧐',
    '😴',
    '🤖',
    '👻',
    '👽',
    '🐶',
  ];
  String _selectedEmoji = '😎';

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Isi nama dulu ya!")));
      return;
    }
    if (pin.length < 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PIN harus 4 digit!")));
      return;
    }

    // Simpan ke Database
    final newUser = User(name: name, pin: pin, avatarEmoji: _selectedEmoji);
    await DBHelper.instance.registerUser(newUser);

    if (!mounted) return;

    // Pindah ke MainPage dan hapus history navigasi (agar tidak bisa back ke register)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tema Pinput (Kotak PIN)
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Header
              Text(
                "Welcome to Moodiary",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn().slideY(begin: -0.5, end: 0),
              const SizedBox(height: 8),
              Text(
                "Let's set up your profile",
                style: GoogleFonts.poppins(color: Colors.white54),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 40),

              // 2. Emoji Selector
              Text(
                "Choose your Avatar",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _emojis.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final emoji = _emojis[index];
                    final isSelected = _selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = emoji),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFBB86FC)
                              : Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFBB86FC,
                                    ).withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().scale(delay: 300.ms),

              const SizedBox(height: 30),

              // 3. Name Input
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Your Name",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),

              const SizedBox(height: 30),

              // 4. PIN Input
              Text(
                "Create 4-digit PIN",
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Pinput(
                controller: _pinController,
                length: 4,
                obscureText: true, // Sembunyikan angka jadi titik/bintang
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: const Color(0xFFBB86FC)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBB86FC).withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),

              const SizedBox(height: 50),

              // 5. Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBB86FC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Get Started 🚀",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
