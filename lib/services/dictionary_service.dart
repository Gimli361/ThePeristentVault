import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryService {
  static const String _baseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  /// Fetches word data from the Free Dictionary API.
  /// Returns a map with keys: audioUrl, synonyms, phonetic
  Future<Map<String, dynamic>> fetchWordData(String word) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$word'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) return {};

        final entry = data[0] as Map<String, dynamic>;

        // Extract phonetic
        String? phonetic = entry['phonetic'] as String?;

        // Extract audio URL
        String? audioUrl;
        final phonetics = entry['phonetics'] as List<dynamic>?;
        if (phonetics != null) {
          for (final p in phonetics) {
            final audio = p['audio'] as String?;
            if (audio != null && audio.isNotEmpty) {
              audioUrl = audio;
              break;
            }
            if (phonetic == null || phonetic.isEmpty) {
              final text = p['text'] as String?;
              if (text != null && text.isNotEmpty) {
                phonetic = text;
              }
            }
          }
        }

        // Extract synonyms
        final Set<String> synonymSet = {};
        final meanings = entry['meanings'] as List<dynamic>?;
        if (meanings != null) {
          for (final meaning in meanings) {
            final defs = meaning['definitions'] as List<dynamic>?;
            if (defs != null) {
              for (final def in defs) {
                final syns = def['synonyms'] as List<dynamic>?;
                if (syns != null) {
                  for (final s in syns) {
                    synonymSet.add(s.toString());
                  }
                }
              }
            }
            final syns = meaning['synonyms'] as List<dynamic>?;
            if (syns != null) {
              for (final s in syns) {
                synonymSet.add(s.toString());
              }
            }
          }
        }

        return {
          'audioUrl': audioUrl,
          'phonetic': phonetic,
          'synonyms': synonymSet.take(8).join(', '),
        };
      }

      return {};
    } catch (e) {
      return {};
    }
  }
}
