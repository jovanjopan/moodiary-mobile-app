import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/db_helper.dart';

class SettingsScreen extends StatefulWidget {
  final Function() onThemeChanged; // Nanti kalau mau fitur ganti tema
  final Function() onNameChanged; // Callback untuk refresh nama di Home

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onNameChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? "User";
    });

    // Ambil info versi aplikasi
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  Future<void> _saveName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    widget.onNameChanged(); // Beritahu Home screen untuk refresh

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama berhasil disimpan!")));
      FocusScope.of(context).unfocus(); // Tutup keyboard
    }
  }

  Future<void> _clearAllData() async {
    // Dialog konfirmasi bahaya
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Hapus Semua Data?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Tindakan ini akan menghapus SEMUA jurnal kamu secara permanen. Tidak bisa dikembalikan.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.instance
          .deleteAllJournals(); // Kita perlu buat fungsi ini di DB Helper
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semua kenangan telah dihapus.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Profil Section
          Text(
            "PROFIL",
            style: GoogleFonts.poppins(
              color: Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Nama Panggilan",
                      labelStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save, color: Color(0xFFBB86FC)),
                  onPressed: _saveName,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2. Data Section
          Text(
            "DATA & PRIVASI",
            style: GoogleFonts.poppins(
              color: Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text(
                "Hapus Semua Jurnal",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                "Reset aplikasi ke awal",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              onTap: _clearAllData,
            ),
          ),

          const SizedBox(height: 30),

          // 3. Info Section
          Text(
            "TENTANG",
            style: GoogleFonts.poppins(
              color: Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Versi Aplikasi",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      _appVersion,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 24),
                const Center(
                  child: Text(
                    "Dibuat dengan 💜 oleh Moodiary Team",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
