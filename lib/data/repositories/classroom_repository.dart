import 'dart:math';
import '../models/classroom_feed.dart';
import '../services/thingspeak_api_service.dart';

class ClassroomRepository {
  final ThingSpeakApiService _apiService;
  
  // Cache the last generated mock feed to simulate smooth transitions
  ClassroomFeed? _lastMockFeed;
  final Random _random = Random();

  ClassroomRepository({ThingSpeakApiService? apiService})
      : _apiService = apiService ?? ThingSpeakApiService();

  Future<ClassroomFeed> getLastFeed({bool forceMock = false}) async {
    if (forceMock) {
      return _generateMockFeed();
    }
    try {
      return await _apiService.fetchLastFeed();
    } catch (e) {
      // Fallback to mock on connection or channel error
      return _generateMockFeed();
    }
  }

  Future<List<ClassroomFeed>> getFeedsHistory({int results = 15, bool forceMock = false}) async {
    if (forceMock) {
      return _generateMockHistory(results);
    }
    try {
      return await _apiService.fetchFeedsHistory(results: results);
    } catch (e) {
      // Fallback to mock history on failure
      return _generateMockHistory(results);
    }
  }

  // Generates a mock feed that fluctuates based on the last one
  ClassroomFeed _generateMockFeed() {
    final now = DateTime.now();
    
    if (_lastMockFeed == null) {
      // Initialize with base values
      _lastMockFeed = ClassroomFeed(
        temperature: 26.5,
        humidity: 55.0,
        lightIntensity: 450.0,
        occupancy: 1, // Start occupied
        createdAt: now,
      );
      return _lastMockFeed!;
    }

    // Fluctuate temperature: +/- 0.4 degrees
    double newTemp = _lastMockFeed!.temperature + (_random.nextDouble() - 0.5) * 0.8;
    newTemp = newTemp.clamp(20.0, 39.5); // Can drift past 35°C warning limit

    // Fluctuate humidity: +/- 1.5 percent
    double newHum = _lastMockFeed!.humidity + ((_random.nextDouble() - 0.5) * 3.0);
    newHum = newHum.clamp(40.0, 85.0);

    // Fluctuate light intensity
    double newLight = _lastMockFeed!.lightIntensity + ((_random.nextDouble() - 0.5) * 40.0);
    
    // 8% chance of occupancy status toggling
    int isOccupiedNow = _lastMockFeed!.occupancy;
    if (_random.nextDouble() < 0.08) {
      isOccupiedNow = isOccupiedNow == 1 ? 0 : 1;
    }

    if (isOccupiedNow == 1) {
      newLight = newLight.clamp(350.0, 800.0);
    } else {
      // Drop light slowly if empty
      newLight = (newLight - 100.0).clamp(40.0, 200.0);
    }

    _lastMockFeed = ClassroomFeed(
      temperature: double.parse(newTemp.toStringAsFixed(1)),
      humidity: double.parse(newHum.toStringAsFixed(1)),
      lightIntensity: double.parse(newLight.toStringAsFixed(0)),
      occupancy: isOccupiedNow,
      createdAt: now,
    );

    return _lastMockFeed!;
  }

  // Generates a mock history of classroom feeds
  List<ClassroomFeed> _generateMockHistory(int count) {
    List<ClassroomFeed> history = [];
    DateTime timestamp = DateTime.now().subtract(Duration(minutes: count * 2));
    
    double temp = 24.5;
    double hum = 52.0;
    double light = 480.0;
    int occ = 1;

    for (int i = 0; i < count; i++) {
      timestamp = timestamp.add(const Duration(minutes: 2));
      
      temp += (_random.nextDouble() - 0.5) * 0.8;
      temp = temp.clamp(21.0, 38.0);

      hum += (_random.nextDouble() - 0.5) * 3.0;
      hum = hum.clamp(45.0, 75.0);

      if (i > 0 && i % 5 == 0) {
        occ = occ == 1 ? 0 : 1;
      }

      if (occ == 1) {
        light = 400.0 + (_random.nextDouble() * 250.0);
      } else {
        light = 50.0 + (_random.nextDouble() * 80.0);
      }

      history.add(ClassroomFeed(
        temperature: double.parse(temp.toStringAsFixed(1)),
        humidity: double.parse(hum.toStringAsFixed(1)),
        lightIntensity: double.parse(light.toStringAsFixed(0)),
        occupancy: occ,
        createdAt: timestamp,
      ));
    }
    
    // Set the last historical feed as the basis for further mock updates
    if (history.isNotEmpty) {
      _lastMockFeed = history.last;
    }
    
    return history;
  }
}
