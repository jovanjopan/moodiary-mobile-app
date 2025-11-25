import 'package:flutter/material.dart';
import '../data_models/journal_entry.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;
  const JournalDetailScreen({super.key, required this.entry});

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Happy':
        return '😊';
      case 'Sad':
        return '😢';
      case 'Calm':
        return '😌';
      case 'Tired':
        return '😴';
      case 'Excited':
        return '🤩';
      default:
        return '🙂';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emoji = _getMoodEmoji(entry.mood);
    final formattedDate = entry.date.split('T').first.replaceAll('-', '/');

    return Scaffold(
      appBar: AppBar(title: const Text("Journal Detail"), centerTitle: true),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Header
              Center(
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 10),
                    Text(
                      entry.mood,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Mood Score: ${entry.moodScore}/5",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "📅 $formattedDate",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Section
              Text(
                entry.title.isEmpty ? "(No Title)" : entry.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const Divider(height: 24, thickness: 0.5, color: Colors.white24),

              // Content Section
              Text(
                entry.content,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 30),

              // AI Insight Section
              if (entry.insight != null && entry.insight!.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("💡", style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "AI Insight",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purpleAccent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.insight!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (entry.insight == null || entry.insight!.isEmpty)
                Center(
                  child: Text(
                    "✨ Tidak ada insight dari AI untuk entri ini.",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
