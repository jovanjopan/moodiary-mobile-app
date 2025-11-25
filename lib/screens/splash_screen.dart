import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/db_helper.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 1. Tunggu minimal 3 detik agar animasi selesai (Branding)
    await Future.delayed(const Duration(seconds: 3));

    // 2. Cek Database
    final isRegistered = await DBHelper.instance.isUserRegistered();

    if (!mounted) return;

    // 3. Navigasi
    if (isRegistered) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1B2F), Color(0xFF2B1E3D), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO ANIMASI
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBB86FC).withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBB86FC).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome, // Icon Bintang/Magic
                    size: 80,
                    color: Color(0xFFBB86FC),
                  ),
                )
                .animate()
                .scale(
                  duration: 1000.ms,
                  curve: Curves.elasticOut,
                ) // Muncul membesar
                .then(delay: 500.ms)
                .shimmer(duration: 1500.ms, color: Colors.white54), // Berkilau

            const SizedBox(height: 24),

            // NAMA APLIKASI
            Text(
              "Moodiary",
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0),

            const SizedBox(height: 8),

            // SLOGAN
            Text(
              "Your Personal AI Companion",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white54,
                letterSpacing: 1.5,
              ),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 60),

            // LOADING INDICATOR KECIL
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Color(0xFFBB86FC),
                strokeWidth: 2,
              ),
            ).animate().fadeIn(delay: 1500.ms),
          ],
        ),
      ),
    );
  }
}
