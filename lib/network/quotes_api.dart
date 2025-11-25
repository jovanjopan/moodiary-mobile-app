import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_insight_service.dart';

class QuotesApi {
  static const String _randomUrl = 'https://zenquotes.io/api/random';

  static final Map<String, List<Map<String, String>>> moodQuotes = {
    'Sad': [
      {'q': 'Every storm runs out of rain.', 'a': 'Maya Angelou'},
      {
        'q': 'Tough times never last, but tough people do.',
        'a': 'Robert Schuller',
      },
      {
        'q': 'It’s okay to not be okay, as long as you don’t stay that way.',
        'a': 'Unknown',
      },
    ],
    'Happy': [
      {
        'q':
            'Happiness is not something ready made. It comes from your actions.',
        'a': 'Dalai Lama',
      },
      {'q': 'Smile, it’s free therapy.', 'a': 'Douglas Horton'},
    ],
    'Calm': [
      {'q': 'Peace begins with a smile.', 'a': 'Mother Teresa'},
      {
        'q':
            'The nearer a man comes to a calm mind, the closer he is to strength.',
        'a': 'Marcus Aurelius',
      },
    ],
    'Tired': [
      {'q': 'Rest, and be thankful.', 'a': 'William Wordsworth'},
      {
        'q':
            'Almost everything will work again if you unplug it for a few minutes… including you.',
        'a': 'Anne Lamott',
      },
    ],
    'Excited': [
      {
        'q':
            'The future belongs to those who believe in the beauty of their dreams.',
        'a': 'Eleanor Roosevelt',
      },
      {
        'q': 'Your energy introduces you before you even speak.',
        'a': 'Unknown',
      },
    ],
  };

  static Future<Map<String, String>> fetchTodayQuote({String? mood}) async {
    try {
      if (mood != null && moodQuotes.containsKey(mood)) {
        final list = moodQuotes[mood]!;
        list.shuffle();
        final picked = list.first;

        // 🔮 Integrasi langsung dengan AI Insight
        final aiMotivation = await AIInsightService.generateInsight(
          "Hari ini aku merasa $mood dan butuh semangat tambahan.",
          mood,
        );

        return {
          'quote': "$aiMotivation\n\n“${picked['q']}”",
          'author': picked['a'] ?? "Gemini AI",
        };
      }

      // Fallback ke random quote dari API publik
      final response = await http.get(Uri.parse(_randomUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final quote = data.first;
        return {'quote': quote['q'], 'author': quote['a']};
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      print('❌ Error di QuotesApi: $e');
      return {
        'quote': 'Tetap semangat, setiap hari adalah awal yang baru.',
        'author': 'Moodiary AI',
      };
    }
  }
}
