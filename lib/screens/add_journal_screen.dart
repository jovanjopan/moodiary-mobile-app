import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data_models/journal_entry.dart';
import '../core/db_helper.dart';
import '../network/ai_insight_service.dart';

class AddJournalScreen extends StatefulWidget {
  const AddJournalScreen({super.key});

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Data Mood yang lebih visual
  final List<Map<String, dynamic>> _moods = [
    {'label': 'Happy', 'emoji': '😊', 'color': Colors.greenAccent},
    {'label': 'Excited', 'emoji': '🤩', 'color': Colors.orangeAccent},
    {'label': 'Calm', 'emoji': '😌', 'color': Colors.lightBlueAccent},
    {'label': 'Tired', 'emoji': '😴', 'color': Colors.purpleAccent},
    {'label': 'Sad', 'emoji': '😢', 'color': Colors.blueGrey},
  ];

  String selectedMood = 'Happy';
  String selectedEmoji = '😊';
  Color selectedColor = Colors.greenAccent;

  double selectedMoodScore = 3.0;
  bool isSaving = false;

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi konten minimal
    if (_contentController.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tulis sedikit lebih banyak ya... (min 5 karakter)"),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final content = _contentController.text.trim();

      // Feedback visual saat AI bekerja
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text('AI sedang membaca perasaanmu...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final insight = await AIInsightService.generateInsight(
        content,
        selectedMood,
      );

      final entry = JournalEntry(
        title: _titleController.text.trim(),
        content: content,
        mood: selectedMood,
        moodScore: selectedMoodScore.toInt(),
        date: DateTime.now().toIso8601String(),
        insight: insight,
      );

      await DBHelper.instance.insertJournal(entry);

      if (!mounted) return;
      Navigator.pop(context, true); // Kembali dengan sinyal sukses
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          "New Entry",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Title Input (Clean Look)
                Text(
                  "Judul",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: "Apa judul hari ini?",
                    hintStyle: TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
                ),

                const SizedBox(height: 24),

                // 2. Mood Selector (Visual Chips)
                Text(
                  "Mood Kamu",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moods.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final m = _moods[index];
                      final isSelected = selectedMood == m['label'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMood = m['label'];
                            selectedEmoji = m['emoji'];
                            selectedColor = m['color'];
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? m['color'].withOpacity(0.2)
                                : const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? m['color']
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                m['emoji'],
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m['label'],
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: isSelected ? m['color'] : Colors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Slider Intensitas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Intensitas",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "${selectedMoodScore.toInt()}/5",
                      style: TextStyle(
                        color: selectedColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: selectedColor,
                    thumbColor: selectedColor,
                    inactiveTrackColor: const Color(0xFF1E1E1E),
                    trackHeight: 4.0,
                  ),
                  child: Slider(
                    value: selectedMoodScore,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (v) => setState(() => selectedMoodScore = v),
                  ),
                ),

                const SizedBox(height: 24),

                // 4. Content Area (Kertas Tulis)
                Text(
                  "Ceritakan harimu...",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        "Tulis apa saja yang kamu rasakan, AI akan mendengarmu...",
                    hintStyle: TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  validator: (v) => v!.isEmpty ? 'Jangan kosong ya...' : null,
                ),

                const SizedBox(height: 32),

                // 5. Big Gradient Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveEntry,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSaving
                              ? [Colors.grey, Colors.grey]
                              : [
                                  const Color(0xFF7B2FF7),
                                  const Color(0xFF9D4EDD),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Simpan Jurnal",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
