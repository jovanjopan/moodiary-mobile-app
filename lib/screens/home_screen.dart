import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ WAJIB ADA
import '../core/db_helper.dart';
import '../network/ai_insight_service.dart';
import 'add_journal_screen.dart';
import 'journal_list_screen.dart';
import 'trends_screen.dart';
import 'counselor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String aiInspiration = "Loading inspiration...";
  String userMood = "Happy";
  String userName = "Friend";
  bool isLoading = true;

  // Kunci untuk SharedPreferences
  static const String _lastFetchKey = 'last_ai_fetch_timestamp';
  static const String _cachedQuoteKey = 'cached_ai_quote';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserName();
    _loadMoodAndAIQuote(); // Load pertama kali
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ✅ AMAN: Sekarang fungsi ini punya pengaman cooldown
      _loadMoodAndAIQuote();
      _loadUserName();
    }
  }

  Future<void> _loadUserName() async {
    final user = await DBHelper.instance.getUser();
    if (!mounted) return;
    if (user != null) {
      setState(() {
        userName = user.name;
      });
    }
  }

  // 🔥 LOGIC BARU: COOLDOWN SYSTEM
  Future<void> _loadMoodAndAIQuote({bool forceUpdate = false}) async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final lastFetch = prefs.getInt(_lastFetchKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cachedQuote = prefs.getString(_cachedQuoteKey);

    // Dapatkan mood terakhir dari database
    final mood = await DBHelper.instance.getLastMood() ?? "Happy";

    // 🛑 CEK COOLDOWN
    // Kalau tidak dipaksa update (forceUpdate == false)
    // DAN belum 1 jam (3600000 ms) sejak request terakhir
    // DAN kita punya quote simpanan di cache
    if (!forceUpdate && (now - lastFetch < 3600000) && cachedQuote != null && cachedQuote.isNotEmpty) {
      print("⏳ Masih cooldown. Menggunakan quote dari cache.");
      setState(() {
        userMood = mood;
        aiInspiration = cachedQuote;
        isLoading = false;
      });
      return; // Stop di sini, jangan panggil API
    }

    // Kalau lolos cek di atas, berarti waktunya fetch baru
    setState(() => isLoading = true);

    String aiResponse;
    try {
      print("🚀 Fetching new AI Insight...");
      aiResponse = await AIInsightService.generateInsight(
        "Hari ini aku ingin termotivasi dan merasa lebih baik.",
        mood,
      );

      // ✅ SIMPAN HASIL KE CACHE & UPDATE WAKTU
      await prefs.setInt(_lastFetchKey, now);
      await prefs.setString(_cachedQuoteKey, aiResponse);

    } catch (e) {
      print("❌ Error fetching AI: $e");
      // Fallback message jika error
      if (e.toString().contains("SocketException") ||
          e.toString().contains("ClientException")) {
        aiResponse = "Maaf, quote hari ini tidak bisa dimuat karena tidak ada internet 📡. Tapi tetap semangat ya! ✨";
      } else {
        aiResponse = "Sedang ada gangguan kecil, tapi kamu hebat! 💪";
      }
    }

    if (!mounted) return;
    setState(() {
      userMood = mood;
      aiInspiration = aiResponse;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1B2F), Color(0xFF2B1E3D), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👋 Greeting
                Text(
                  "Hi, $userName 👋",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "How are you feeling today?",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),

                // 🧩 Main grid buttons
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildCard(
                        color1: const Color(0xFF6A1B9A),
                        color2: const Color(0xFF8E24AA),
                        icon: Icons.mood,
                        title: "Log Mood",
                        subtitle: "How are you feeling?",
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddJournalScreen(),
                            ),
                          );
                          // ⚡ PAKSA UPDATE: Karena user baru aja input mood baru,
                          // kita butuh insight baru yang relevan.
                          _loadMoodAndAIQuote(forceUpdate: true);
                        },
                      ),
                      _buildCard(
                        color1: const Color(0xFF00897B),
                        color2: const Color(0xFF26A69A),
                        icon: Icons.book,
                        title: "Journal",
                        subtitle: "Reflect on your day",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JournalListScreen(),
                            ),
                          );
                        },
                      ),
                      _buildCard(
                        color1: const Color(0xFF3949AB),
                        color2: const Color(0xFF5C6BC0),
                        icon: Icons.show_chart,
                        title: "Trends",
                        subtitle: "View your progress",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TrendsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildCard(
                        color1: const Color(0xFFAD1457),
                        color2: const Color(0xFFD81B60),
                        icon: Icons.chat_bubble_outline,
                        title: "Counselor",
                        subtitle: "Chat with AI",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CounselorScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 💬 Daily inspiration card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "✨ Daily Inspiration",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              aiInspiration,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color color1,
    required Color color2,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color2.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}