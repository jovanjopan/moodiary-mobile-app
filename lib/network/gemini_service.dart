// import 'dart:convert';
// import 'package:http/http.dart' as http;

// /// Service untuk berkomunikasi dengan Gemini API (Google Generative AI)
// class GeminiService {
//   static const String _apiKey = "YOUR_GEMINI_API_KEY_HERE"; // Ganti manual dulu
//   static const String _endpoint =
//       "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey";

//   /// Menghasilkan kalimat motivasi singkat berdasarkan mood
//   static Future<String> generateMotivation(String mood) async {
//     final prompt =
//         "Buat satu kalimat motivasi singkat dan lembut dalam bahasa Indonesia, "
//         "yang sesuai dengan suasana hati seseorang yang sedang merasa '$mood'. "
//         "Gunakan nada positif, empatik, dan realistis.";

//     try {
//       final response = await http.post(
//         Uri.parse(_endpoint),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "contents": [
//             {
//               "parts": [
//                 {"text": prompt},
//               ],
//             },
//           ],
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final text =
//             data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
//         return text.trim().isEmpty
//             ? "Kamu sudah cukup berjuang hari ini, beristirahatlah sejenak 💜"
//             : text.trim();
//       } else {
//         return "Koneksi AI gagal (${response.statusCode})";
//       }
//     } catch (e) {
//       return "Gagal menghubungi Gemini API: $e";
//     }
//   }
// }
