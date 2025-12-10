import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/db_helper.dart';
import '../data_models/user_model.dart';
import '../main.dart'; // Untuk restart app saat logout

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Daftar Emoji untuk Avatar
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
    '🦁',
    '🦄',
  ];
  String _selectedEmoji = '😎';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await DBHelper.instance.getUser();
    if (user != null) {
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _bioController.text = user.bio;
        _selectedEmoji = user.avatarEmoji;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    final updatedUser = User(
      id: _user!.id,
      pin: _user!.pin, // PIN Tetap
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      avatarEmoji: _selectedEmoji,
    );

    await DBHelper.instance.updateUser(updatedUser);
    await _loadUser(); // Refresh UI

    if (mounted) {
      Navigator.pop(context); // Tutup BottomSheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diupdate! ✨")),
      );
    }
  }

  Future<void> _logout() async {
    await DBHelper.instance.clearAllData();
    
    // ✅ Check IMMEDIATELY after async operation
    if (!mounted) return;
    
    // Only navigate if widget is still alive
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MoodiaryApp()),
      (route) => false,
    );
  }

  // 👇 FITUR BARU: Hapus Semua Data Jurnal
  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Reset Jurnal?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Tindakan ini akan menghapus SEMUA jurnal kamu secara permanen.\nData profil & PIN tidak akan hilang.",
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
      await DBHelper.instance.deleteAllJournals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semua kenangan telah dihapus.")),
        );
      }
    }
  }

  void _showEditSheet() {
    String tempSelectedEmoji = _selectedEmoji;
    _nameController.text = _user!.name;
    _bioController.text = _user!.bio;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Profile",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Emoji Selector
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _emojis.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            tempSelectedEmoji = _emojis[index];
                          });
                          _selectedEmoji = _emojis[index];
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tempSelectedEmoji == _emojis[index]
                                ? const Color(0xFFBB86FC)
                                : Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _emojis[index],
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Display Name",
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _bioController,
                  style: const TextStyle(color: Colors.white),
                  maxLength: 50,
                  decoration: const InputDecoration(
                    labelText: "Short Bio / Mantra",
                    prefixIcon: Icon(Icons.edit_note, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBB86FC),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade900, const Color(0xFFBB86FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBB86FC).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _user!.avatarEmoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 20),

            // Info User
            Text(
              _user!.name,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn().moveY(begin: 10, end: 0),

            Text(
              _user!.bio,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 30),

            // Edit Button
            OutlinedButton.icon(
              onPressed: _showEditSheet,
              icon: const Icon(Icons.edit, color: Color(0xFFBB86FC)),
              label: const Text(
                "Edit Profile",
                style: TextStyle(color: Color(0xFFBB86FC)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFBB86FC)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Divider(color: Colors.white10),
            const SizedBox(height: 20),

            // Menu List
            _buildMenuItem(Icons.lock_outline, "Change Security PIN", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Ganti PIN segera hadir!")),
              );
            }),

            // 👇 MENU HAPUS DATA (Update Terbaru)
            _buildMenuItem(
              Icons.delete_forever,
              "Clear All Journals",
              _clearData,
            ),

            _buildMenuItem(Icons.info_outline, "About Moodiary", () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70),
      ),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    ).animate().fadeIn().slideX();
  }
}
