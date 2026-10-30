import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmerApiService {
  static String defaultBaseUrl = 'http://127.0.0.1:8000';
  static String? _cachedBaseUrl;

  /// Get current active API base URL (can be customized by farmer in Profile settings)
  static Future<String> getBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedBaseUrl = prefs.getString('backend_base_url') ?? defaultBaseUrl;
    } catch (_) {
      _cachedBaseUrl = defaultBaseUrl;
    }
    return _cachedBaseUrl!;
  }

  /// Set and persist custom backend host (e.g. http://192.168.1.5:8000 for Android phone)
  static Future<void> setBaseUrl(String newUrl) async {
    String cleanUrl = newUrl.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    _cachedBaseUrl = cleanUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend_base_url', cleanUrl);
  }

  /// Ask a voice or text question to the multilingual agricultural assistant
  static Future<Map<String, dynamic>> askQuestion({
    required String question,
    String? language,
  }) async {
    final host = await getBaseUrl();
    final uri = Uri.parse('$host/ask').replace(
      queryParameters: {
        'question': question,
        if (language != null && language.isNotEmpty) 'language': language,
      },
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 130));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw Exception('Unexpected response format from the server.');
      }

      throw Exception('Server error ${response.statusCode}: ${response.body}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Could not connect to backend at $host. Details: $e');
    }
  }

  /// Fetch real-time live weather with live temperature, humidity, and farmer advisory
  static Future<Map<String, dynamic>> getLiveWeather({
    String location = 'Pune',
    String language = 'Marathi',
  }) async {
    final host = await getBaseUrl();
    final uri = Uri.parse('$host/weather').replace(
      queryParameters: {
        'location': location,
        'language': language,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load weather: ${response.statusCode}');
  }

  /// Fetch official government farming schemes with website links
  static Future<Map<String, dynamic>> getSchemes({
    String? category,
    String language = 'Marathi',
    String? search,
  }) async {
    final host = await getBaseUrl();
    final uri = Uri.parse('$host/schemes').replace(
      queryParameters: {
        if (category != null && category.isNotEmpty) 'category': category,
        'language': language,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load schemes: ${response.statusCode}');
  }

  /// Analyze crop/plant disease with symptoms or optional image
  static Future<Map<String, dynamic>> scanDisease({
    String crop = 'tomato',
    String? symptoms,
    String? imageBase64,
    String language = 'Marathi',
  }) async {
    final host = await getBaseUrl();
    final uri = Uri.parse('$host/disease-scan');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'crop': crop,
        'symptoms': symptoms,
        'image_base64': imageBase64,
        'language': language,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to analyze disease: ${response.statusCode}');
  }

  /// Fetch APMC Mandi market rates
  static Future<Map<String, dynamic>> getMarketPrices({
    String? crop,
    String language = 'Marathi',
  }) async {
    final host = await getBaseUrl();
    final uri = Uri.parse('$host/market-price').replace(
      queryParameters: {
        if (crop != null && crop.isNotEmpty) 'crop': crop,
        'language': language,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load market prices: ${response.statusCode}');
  }

  /// Fetch Soil Health advisory
  static Future<Map<String, dynamic>> getSoilHealth({
    String soilType = 'black',
    String language = 'Marathi',
  }) async {
    final host = await getBaseUrl();
    final uri = Uri.parse('$host/soil-health').replace(
      queryParameters: {
        'soil_type': soilType,
        'language': language,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load soil advisory: ${response.statusCode}');
  }

  /// Fetch Crop Advice
  static Future<Map<String, dynamic>> getCropAdvice({
    String crop = 'tomato',
    String language = 'Marathi',
  }) async {
    final host = await getBaseUrl();
    final uri = Uri.parse('$host/crop-advice').replace(
      queryParameters: {
        'crop': crop,
        'language': language,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load crop advice: ${response.statusCode}');
  }

  /// Fetch Farm Machinery and equipment guide
  static Future<Map<String, dynamic>> getMachinery({
    String? category,
    String language = 'Marathi',
  }) async {
    final host = await getBaseUrl();
    final uri = Uri.parse('$host/machinery').replace(
      queryParameters: {
        if (category != null && category.isNotEmpty) 'category': category,
        'language': language,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load machinery guide: ${response.statusCode}');
  }
}