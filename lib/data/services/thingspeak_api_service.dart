import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/classroom_feed.dart';
import '../../core/constants/app_constants.dart';

class ThingSpeakApiService {
  final http.Client client;

  ThingSpeakApiService({http.Client? client}) : client = client ?? http.Client();

  Future<ClassroomFeed> fetchLastFeed() async {
    try {
      final response = await client
          .get(Uri.parse(AppConstants.lastFeedUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = response.body.trim();
        // ThingSpeak returns "-1" or "0" if the channel is private or doesn't exist
        if (body == '-1' || body == '0' || body.isEmpty) {
          throw Exception('Private channel or invalid ID (API returned $body)');
        }

        final data = json.decode(body);
        if (data is Map<String, dynamic>) {
          return ClassroomFeed.fromJson(data);
        } else {
          throw Exception('Invalid JSON response format');
        }
      } else {
        throw Exception('Server error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Connection Error: ${e.toString()}');
    }
  }

  Future<List<ClassroomFeed>> fetchFeedsHistory({int results = 15}) async {
    try {
      final url = '${AppConstants.historyFeedsUrl}?results=$results';
      final response = await client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body == '-1' || body == '0' || body.isEmpty) {
          throw Exception('Private channel or invalid ID (API returned $body)');
        }

        final data = json.decode(body);
        if (data is Map<String, dynamic> && data.containsKey('feeds')) {
          final List feedsJson = data['feeds'];
          return feedsJson
              .map((json) => ClassroomFeed.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid historical data format');
        }
      } else {
        throw Exception('Server error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Connection Error: ${e.toString()}');
    }
  }
}
