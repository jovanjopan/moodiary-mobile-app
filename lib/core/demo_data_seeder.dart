// import 'dart:math';
// import 'package:flutter/material.dart';
import '../data_models/journal_entry.dart';
import '../data_models/user_model.dart';
import 'db_helper.dart';

class DemoDataSeeder {
  static Future<void> seedDatabase() async {
    final db = await DBHelper.instance.database;

    // 1. Reset Data Lama (Opsional: Agar demo selalu fresh)
    await db.delete('users');
    await db.delete('journals');

    // 2. Buat Akun Demo
    final demoUser = User(
      name: "Demo User",
      pin: "1234", // PIN Gampang
      avatarEmoji: "🤖",
      bio: "Just a robot exploring human emotions.",
    );
    await DBHelper.instance.registerUser(demoUser);

    // 3. Siapkan Data Jurnal 7 Hari Terakhir
    final List<Map<String, dynamic>> dummyData = [
      {
        'daysAgo': 0, // Hari Ini
        'title': "Presentasi Project Moodiary",
        'content':
            "Hari ini akhirnya demo aplikasi! Sedikit gugup tapi sangat bersemangat. Semoga semuanya berjalan lancar dan tidak ada bug yang muncul tiba-tiba.",
        'mood': 'Excited',
        'score': 5,
        'insight':
            "Energi positifmu sangat menular! Pertahankan semangat ini dan percaya pada persiapanmu.",
      },
      {
        'daysAgo': 1, // Kemarin
        'title': "Begadang Coding",
        'content':
            "Mata rasanya berat banget. Semalam suntuk memperbaiki fitur notifikasi yang error terus. Tapi akhirnya berhasil fix jam 3 pagi. Butuh kopi.",
        'mood': 'Tired',
        'score': 2,
        'insight':
            "Kerja kerasmu luar biasa, tapi ingat tubuhmu butuh istirahat untuk pulih kembali.",
      },
      {
        'daysAgo': 2,
        'title': "Menikmati Hujan",
        'content':
            "Sore ini hujan deras. Duduk di teras sambil minum teh hangat. Rasanya damai sekali bisa sejenak melupakan deadline.",
        'mood': 'Calm',
        'score': 4,
        'insight':
            "Momen ketenangan seperti ini sangat penting untuk menjernihkan pikiran.",
      },
      {
        'daysAgo': 3,
        'title': "Kangen Rumah",
        'content':
            "Tiba-tiba kepikiran masakan ibu di rumah. Rasanya sepi banget di kost sendirian. Kadang menjadi dewasa itu berat.",
        'mood': 'Sad',
        'score': 2,
        'insight':
            "Rasa rindu itu wajar. Mungkin menelepon keluarga bisa sedikit mengobati perasaanmu.",
      },
      {
        'daysAgo': 4,
        'title': "Olahraga Pagi",
        'content':
            "Akhirnya berhasil bangun pagi dan jogging keliling komplek! Badan terasa segar dan mood jadi bagus banget seharian.",
        'mood': 'Happy',
        'score': 5,
        'insight':
            "Langkah kecil untuk kesehatan fisik berdampak besar pada kebahagiaanmu hari ini!",
      },
      {
        'daysAgo': 5,
        'title': "Deadline Menumpuk",
        'content':
            "Tugas kuliah numpuk banget. Bingung mau mulai dari mana. Rasanya pengen nyerah aja tapi harus tetap jalan.",
        'mood': 'Tired',
        'score': 1,
        'insight':
            "Tarik napas dalam-dalam. Coba kerjakan satu per satu mulai dari yang termudah.",
      },
      {
        'daysAgo': 6,
        'title': "Nonton Film Bagus",
        'content':
            "Nonton film sci-fi keren banget tadi malam. Jadi terinspirasi buat bikin cerita fiksi sendiri.",
        'mood': 'Excited',
        'score': 4,
        'insight':
            "Inspirasi bisa datang dari mana saja, salurkan energi kreatifmu itu!",
      },
    ];

    // 4. Masukkan Jurnal ke Database
    for (var data in dummyData) {
      // Hitung tanggal mundur (Hari ini - X hari)
      final date = DateTime.now().subtract(
        Duration(days: data['daysAgo'] as int),
      );

      final entry = JournalEntry(
        title: data['title'] as String,
        content: data['content'] as String,
        mood: data['mood'] as String,
        moodScore: data['score'] as int,
        date: date.toIso8601String(), // Format tanggal ISO
        insight: data['insight'] as String,
      );

      await DBHelper.instance.insertJournal(entry);
    }
  }
}
