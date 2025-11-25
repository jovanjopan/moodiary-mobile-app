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
  // Data Utama
  List<JournalEntry> _allJournals = []; // Sumber data asli dari DB
  List<JournalEntry> _filteredJournals = []; // Hasil filter untuk ditampilkan

  bool _isLoading = true;
  bool _isCalendarView = false;

  // Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _selectedMoodFilter = 'All'; // 'All', 'Happy', 'Sad', dll.
  final List<String> _moodOptions = [
    'All',
    'Happy',
    'Excited',
    'Calm',
    'Tired',
    'Sad',
  ];

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

  // 1. Load Data
  Future<void> _loadJournals() async {
    setState(() => _isLoading = true);
    final list = await DBHelper.instance.getAllJournals();

    // Mapping data untuk kalender
    Map<DateTime, List<JournalEntry>> events = {};
    for (var journal in list) {
      final date = DateTime.parse(journal.date);
      final dayKey = DateTime.utc(date.year, date.month, date.day);
      if (events[dayKey] == null) events[dayKey] = [];
      events[dayKey]!.add(journal);
    }

    setState(() {
      _allJournals = list;
      _journalEvents = events;
      _isLoading = false;
      _applyFilter(); // Jalankan filter awal
    });
  }

  // 2. Logika Inti: Filter & Search
  void _applyFilter() {
    List<JournalEntry> temp = _allJournals;

    // A. Jika mode Kalender: Filter berdasarkan tanggal dulu
    if (_isCalendarView && _selectedDay != null) {
      final dayKey = DateTime.utc(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );
      temp = _journalEvents[dayKey] ?? [];
    }

    // B. Filter Mood (Jika bukan 'All')
    if (_selectedMoodFilter != 'All') {
      temp = temp.where((j) => j.mood == _selectedMoodFilter).toList();
    }

    // C. Search Text (Judul atau Konten)
    String query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      temp = temp.where((j) {
        return j.title.toLowerCase().contains(query) ||
            j.content.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredJournals = temp;
    });
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(_isCalendarView ? "Calendar" : "My Journals"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
                _applyFilter(); // Re-apply filter saat ganti view
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
        icon: const Icon(Icons.edit, color: Colors.black),
        label: const Text(
          "Write",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 📅 Bagian Kalender (Hanya muncul jika mode ON)
                if (_isCalendarView) _buildCalendarSection(),

                // 🔍 Bagian Search & Filter (Selalu muncul di List View, Optional di Calendar)
                if (!_isCalendarView) _buildSearchAndFilterSection(),

                // 📝 Daftar Jurnal
                Expanded(
                  child: _filteredJournals.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredJournals.length,
                          itemBuilder: (context, index) {
                            return _buildJournalCard(_filteredJournals[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Widget Bagian Search & Chips
  Widget _buildSearchAndFilterSection() {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => _applyFilter(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search title or content...",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips (Horizontal Scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _moodOptions.map((mood) {
                final isSelected = _selectedMoodFilter == mood;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(mood),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMoodFilter = selected ? mood : 'All';
                        _applyFilter();
                      });
                    },
                    selectedColor: const Color(0xFFBB86FC),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
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
        calendarFormat: CalendarFormat
            .month, // Pakai 2 weeks biar hemat tempat? Bisa ganti .month
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _applyFilter(); // Filter list bawah
          });
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
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
        eventLoader: (day) {
          final dayKey = DateTime.utc(day.year, day.month, day.day);
          return _journalEvents[dayKey] ?? [];
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            final journal = events.first as JournalEntry;
            return Positioned(
              bottom: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getMoodColor(journal.mood),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "No journals found.",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          if (_selectedMoodFilter != 'All' || _searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedMoodFilter = 'All';
                  _applyFilter();
                });
              },
              child: const Text(
                "Clear Filters",
                style: TextStyle(color: Color(0xFFBB86FC)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry j) {
    final formattedDate = j.date.split('T').first.replaceAll('-', '/');
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JournalDetailScreen(entry: j)),
        );
        _loadJournals(); // Refresh jika ada edit/delete nanti
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getMoodColor(j.mood).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        j.mood,
                        style: TextStyle(
                          color: _getMoodColor(j.mood),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    j.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  if (j.content.isNotEmpty)
                    Text(
                      j.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
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
