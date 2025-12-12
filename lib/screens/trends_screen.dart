import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Pastikan tambah intl di pubspec.yaml jika belum
import '../core/db_helper.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  List<Map<String, dynamic>> _trends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealTrends();
  }

  Future<void> _loadRealTrends() async {
    final data = await DBHelper.instance.getWeeklyTrends();
    setState(() {
      _trends = data;
      isLoading = false;
    });
  }

  // Helper buat nerjemahin skor ke Emoji/Label
  String _getMoodEmoji(int score) {
    switch (score) {
      case 1: return '😭'; // Terrible
      case 2: return '😟'; // Bad
      case 3: return '😐'; // Neutral
      case 4: return '🙂'; // Good
      case 5: return '🤩'; // Amazing
      default: return '❓';
    }
  }

  String _getMoodLabel(int score) {
    switch (score) {
      case 1: return 'Terrible';
      case 2: return 'Bad';
      case 3: return 'Neutral';
      case 4: return 'Good';
      case 5: return 'Amazing';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Trends", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trends.isEmpty
              ? Center(
                  child: Text(
                    "Belum cukup data untuk tren.\nYuk, isi jurnal dulu! 📝",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kartu Overview (Gue pertahanin karena lu suka)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B2FF7), Color(0xFF9D4EDD)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B2FF7).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text("🌤️", style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Rata-rata Mood",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  "${_averageMood().toStringAsFixed(1)} / 5.0",
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Judul Chart
                      Text(
                        "Analisis Mingguan",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Sentuh titik untuk detail",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white38,
                          fontStyle: FontStyle.italic
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Chart Area
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(right: 16, top: 10),
                          child: LineChart(
                            LineChartData(
                              // INTERAKSI: Biar user tau detail pas ditekan
                              lineTouchData: LineTouchData(
                                handleBuiltInTouches: true,
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (touchedSpot) => Colors.blueGrey.shade900,
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((touchedSpot) {
                                      final index = touchedSpot.x.toInt();
                                      final moodScore = touchedSpot.y.toInt();
                                      final dateStr = _trends[index]['date'] as String;
                                      final date = DateTime.parse(dateStr);
                                      // Format tanggal simpel
                                      final formattedDate = DateFormat('EEE, d MMM').format(date);
                                      
                                      return LineTooltipItem(
                                        '$formattedDate\n',
                                        const TextStyle(
                                          color: Colors.white70, 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${_getMoodEmoji(moodScore)} ${_getMoodLabel(moodScore)}',
                                            style: const TextStyle(
                                              color: Color(0xFFBB86FC),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1, // Grid per level mood
                                getDrawingHorizontalLine: (value) =>
                                    FlLine(color: Colors.white10, strokeWidth: 1, dashArray: [5, 5]),
                              ),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                
                                // SUMBU BAWAH (Tanggal)
                              bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize:
                                    50, // Kita butuh ruang lebih tinggi karena teksnya ditumpuk (Hari atas, Tanggal bawah)
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < _trends.length) {
                                    final dateStr =
                                        _trends[index]['date'] as String;
                                    final date = DateTime.parse(dateStr);

                                    // LOGIKA MANUAL BIAR INDONESIA (Tanpa ribet setting locale intl)
                                    // date.weekday itu return 1 (Senin) s/d 7 (Minggu)
                                    List<String> hariIndo = [
                                      'Sen',
                                      'Sel',
                                      'Rab',
                                      'Kam',
                                      'Jum',
                                      'Sab',
                                      'Min',
                                    ];
                                    String namaHari =
                                        hariIndo[date.weekday - 1];
                                    String tanggal = date.day.toString();

                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space:
                                          8, // Jarak dari garis grafik ke teks
                                      child: Column(
                                        mainAxisSize: MainAxisSize
                                            .min, // Biar gak makan tempat
                                        children: [
                                          // 1. NAMA HARI (Lebih tebal biar jadi fokus utama)
                                          Text(
                                            namaHari,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .white, // Warna terang biar jelas
                                            ),
                                          ),
                                          // 2. TANGGAL (Lebih kecil dan redup sebagai pelengkap)
                                          Text(
                                            tanggal,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.white54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                                // SUMBU KIRI (Emoji Mood) - INI KUNCINYA
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    reservedSize: 40, // Kasih ruang buat emoji
                                    getTitlesWidget: (value, meta) {
                                      // Cuma render emoji di angka bulat 1-5
                                      if (value % 1 == 0 && value >= 1 && value <= 5) {
                                        return Text(
                                          _getMoodEmoji(value.toInt()),
                                          style: const TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: (_trends.length - 1).toDouble(),
                              minY: 0.5, // Padding bawah dikit biar emoji gak kepotong
                              maxY: 5.5, // Padding atas dikit
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _trends.asMap().entries.map((e) {
                                    return FlSpot(
                                      e.key.toDouble(),
                                      (e.value['moodScore'] as int).toDouble(),
                                    );
                                  }).toList(),
                                  isCurved: true, // Biar smooth
                                  curveSmoothness: 0.35,
                                  color: const Color(0xFFBB86FC),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  // Gradient di bawah garis biar lebih 'berisi'
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFBB86FC).withOpacity(0.3),
                                        const Color(0xFFBB86FC).withOpacity(0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 4,
                                          color: const Color(0xFF1E1E1E), // Tengah bolong warna background
                                          strokeWidth: 3,
                                          strokeColor: const Color(0xFFBB86FC),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  double _averageMood() {
    if (_trends.isEmpty) return 0.0;
    final total = _trends.fold<int>(
      0,
      (sum, e) => sum + (e['moodScore'] as int),
    );
    return total / _trends.length;
  }
}