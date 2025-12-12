import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data_models/article.dart';

class NewsService {
  static final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  static const String _baseUrl = 'https://newsapi.org/v2';

  // Fungsi GET Data dengan parameter pencarian yang LEBIH RELEVAN
  Future<List<Article>> fetchArticles({String query = 'mental health'}) async {
    try {
      // 🔧 PERUBAHAN STRATEGI URL:
      // 1. searchIn=title,description -> Agar hasil pencarian fokus, tidak melenceng.
      // 2. sortBy=relevancy -> Menampilkan berita yang paling cocok dulu, bukan yang terbaru.
      // 3. pageSize=20 -> Membatasi 20 berita terbaik saja agar loading cepat.

      final url = Uri.parse(
        '$_baseUrl/everything?'
        'q=$query&'
        'searchIn=title,description&' // 👈 Cari di judul & deskripsi saja
        'language=en&'
        'sortBy=relevancy&' // 👈 Urutkan berdasarkan kecocokan (bukan waktu)
        'pageSize=20&' // 👈 Ambil 20 terbaik
        'apiKey=$_apiKey',
      );

      print('🌐 Requesting News: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'];

        return articlesJson
            .map((json) => Article.fromJson(json))
            .where(
              (article) =>
                  article.urlToImage.isNotEmpty &&
                  article.title != '[Removed]' &&
                  article.description != 'No Description', // Filter tambahan
            )
            .toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching news: $e');
      rethrow;
    }
  }
}
