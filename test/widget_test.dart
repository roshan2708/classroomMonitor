import 'package:flutter_test/flutter_test.dart';
import 'package:classroom_management/data/models/classroom_feed.dart';

void main() {
  group('ClassroomFeed Model Tests', () {
    test('Should parse json correctly', () {
      final json = {
        "field1": "29",
        "field2": "65",
        "field3": "540",
        "field4": "1",
        "created_at": "2026-06-05T10:30:00Z"
      };

      final feed = ClassroomFeed.fromJson(json);

      expect(feed.temperature, 29.0);
      expect(feed.humidity, 65.0);
      expect(feed.lightIntensity, 540.0);
      expect(feed.occupancy, 1);
      expect(feed.isOccupied, true);
      expect(feed.tempStatus, 'Normal');
      expect(feed.humidityStatus, 'Normal');
      expect(feed.lightStatus, 'Moderate');
    });

    test('Should handle null or malformed data gracefully', () {
      final json = {
        "field1": null,
        "field2": "invalid",
        "field3": 120.5,
        "field4": null,
        "created_at": null
      };

      final feed = ClassroomFeed.fromJson(json);

      expect(feed.temperature, 0.0);
      expect(feed.humidity, 0.0);
      expect(feed.lightIntensity, 120.5);
      expect(feed.occupancy, 0);
      expect(feed.isOccupied, false);
    });
  });
}
