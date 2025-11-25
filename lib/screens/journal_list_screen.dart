import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/db_helper.dart';
import '../data_models/journal_entry.dart';
import 'add_journal_screen.dart';
import 'journal_detail_screen.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  // Data
  List<JournalEntry> _allJournals = [];
  List<JournalEntry> _displayedJournals =
      []; // Jurnal yang ditampilkan (terfilter tanggal/semua)
  bool _isLoading = true;
  bool _isCalendarView = false; // Toggle state

  // Calendar State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<JournalEntry>> _journalEvents = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadJournals();
  }

  // 1. Load Data dari DB dan Mapping untuk Kalender
  Future<void> _loadJournals() async {
    setState(() => _isLoading = true);
    final list = await DBHelper.instance.getAllJournals();

    // Mapping data untuk kalender: DateTime -> List<Journal>
    Map<DateTime, List<JournalEntry>> events = {};
    for (var journal in list) {
      // Parse tanggal string ke DateTime
      final date = DateTime.parse(journal.date);
      // Normalisasi jam/menit/detik menjadi 00:00:00 agar bisa dikelompokkan per hari
      final dayKey = DateTime.utc(date.year, date.month, date.day);

      if (events[dayKey] == null) {
        events[dayKey] = [];
      }
      events[dayKey]!.add(journal);
    }

    setState(() {
      _allJournals = list;
      _journalEvents = events;
      _isLoading = false;
      // Default: Tampilkan semua di list view, atau filter by hari ini jika kalender view
      _displayedJournals = _isCalendarView
          ? _getJournalsForDay(_selectedDay!)
          : list;
    });
  }

  List<JournalEntry> _getJournalsForDay(DateTime day) {
    // Normalisasi tanggal yang dipilih user
    final dayKey = DateTime.utc(day.year, day.month, day.day);
    return _journalEvents[dayKey] ?? [];
  }

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

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return Colors.greenAccent;
      case 'Sad':
        return Colors.blueAccent;
      case 'Calm':
        return Colors.tealAccent;
      case 'Tired':
        return Colors.orangeAccent;
      case 'Excited':
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCalendarView ? "Calendar View" : "My Journals"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          // Tombol Toggle List/Calendar
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            tooltip: _isCalendarView ? "Switch to List" : "Switch to Calendar",
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
                // Reset list filter saat ganti mode
                _displayedJournals = _isCalendarView
                    ? _getJournalsForDay(_selectedDay!)
                    : _allJournals;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFBB86FC),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddJournalScreen()),
          );
          if (result == true) _loadJournals();
        },
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          "Write",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 📅 AREA KALENDER (Hanya muncul jika mode kalender aktif)
                if (_isCalendarView) _buildCalendar(),

                if (_isCalendarView)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(thickness: 1, color: Colors.white24),
                  ),

                // 📝 LIST JURNAL
                Expanded(
                  child: _displayedJournals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.book_outlined,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isCalendarView
                                    ? "No entries for this date."
                                    : "No journals yet.\nStart writing!",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _displayedJournals.length,
                          itemBuilder: (context, index) {
                            return _buildJournalCard(_displayedJournals[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            // Filter list berdasarkan tanggal yg diklik
            _displayedJournals = _getJournalsForDay(selectedDay);
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        // Style Kalender
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0xFF03DAC6),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFFBB86FC),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        // Logika Marker (Titik-titik warna)
        eventLoader: _getJournalsForDay,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;

            // Ambil jurnal pertama di hari itu untuk menentukan warna dot
            // (Bisa dikembangkan: jika ada banyak, tampilkan multi-dot)
            final journal = events.first as JournalEntry;

            return Positioned(
              bottom: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getMoodColor(journal.mood), // Warna sesuai mood!
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry j) {
    final formattedDate = j.date.split('T').first.replaceAll('-', '/');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JournalDetailScreen(entry: j)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getMoodColor(j.mood).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji Besar di Kiri
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getMoodColor(j.mood).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                _getMoodEmoji(j.mood),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        j.mood,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _getMoodColor(j.mood),
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    j.title.isEmpty ? "No Title" : j.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    j.content,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
