import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Trends"),
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
                  // Kartu Overview
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
                    "Grafik 7 Entri Terakhir",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chart Area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 16, top: 10),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) =>
                                FlLine(color: Colors.white10, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < _trends.length) {
                                    // Ambil tanggal (misal: 2025-11-25)
                                    final dateStr =
                                        _trends[index]['date'] as String;
                                    // Parse dan ambil tanggalnya saja (tgl 25)
                                    final day = DateTime.parse(
                                      dateStr,
                                    ).day.toString();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        day,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (_trends.length - 1).toDouble(),
                          minY: 0,
                          maxY: 6, // Skala mood 1-5, kita beri ruang sampai 6
                          lineBarsData: [
                            LineChartBarData(
                              spots: _trends.asMap().entries.map((e) {
                                return FlSpot(
                                  e.key.toDouble(),
                                  (e.value['moodScore'] as int).toDouble(),
                                );
                              }).toList(),
                              isCurved: true,
                              color: const Color(0xFFBB86FC),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 6,
                                          color: const Color(0xFFBB86FC),
                                          strokeWidth: 2,
                                          strokeColor: Colors.black,
                                        ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFFBB86FC).withOpacity(0.2),
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
