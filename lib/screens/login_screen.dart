import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/db_helper.dart';
import '../data_models/user_model.dart';
import '../main.dart'; // Untuk navigasi ke MainPage

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  User? _user;
  bool _isPinError = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await DBHelper.instance.getUser();
    setState(() => _user = user);
  }

  Future<void> _verifyPin(String pin) async {
    final isValid = await DBHelper.instance.verifyPin(pin);
    if (isValid) {
      if (!mounted) return;
      // Login Sukses
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    } else {
      // Login Gagal
      setState(() {
        _isPinError = true;
        _pinController.clear();
      });

      // Reset error flag setelah animasi getar selesai
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _isPinError = false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PIN Salah! Coba lagi."),
          backgroundColor: Colors.redAccent,
          duration: Duration(milliseconds: 1000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null)
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
      ); // Loading kosong

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isPinError ? Colors.redAccent : Colors.white24,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar User (Bounce Animation)
              Text(_user!.avatarEmoji, style: const TextStyle(fontSize: 80))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(
                    begin: 1.0,
                    end: 1.1,
                    duration: 1500.ms,
                    curve: Curves.easeInOut,
                  ),

              const SizedBox(height: 20),

              Text(
                "Welcome back,",
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
              ),
              Text(
                _user!.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 50),

              Text(
                "Enter Security PIN",
                style: TextStyle(
                  color: _isPinError ? Colors.redAccent : Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // PIN INPUT
              Pinput(
                    controller: _pinController,
                    length: 4,
                    obscureText: true,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: const Color(0xFFBB86FC)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBB86FC).withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    onCompleted:
                        _verifyPin, // Otomatis submit saat 4 angka terisi
                  )
                  .animate(target: _isPinError ? 1 : 0)
                  .shake(hz: 8, duration: 500.ms), // Efek getar kalau salah

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
