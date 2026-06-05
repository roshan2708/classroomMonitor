import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/classroom_feed.dart';
import '../data/repositories/classroom_repository.dart';
import '../core/constants/app_constants.dart';

class ClassroomController extends GetxController {
  final ClassroomRepository _repository;
  final _box = GetStorage();

  ClassroomController({ClassroomRepository? repository})
      : _repository = repository ?? ClassroomRepository();

  // State Observables
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<ClassroomFeed> currentFeed = Rxn<ClassroomFeed>();
  final RxList<ClassroomFeed> historyFeeds = <ClassroomFeed>[].obs;
  final Rxn<DateTime> lastSyncedTime = Rxn<DateTime>();
  
  // Settings & Toggles
  final RxBool isDemoMode = false.obs;

  // Alerts
  final RxBool showTempWarningBanner = false.obs;

  // Timer for auto-refresh
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    
    // Load Demo Mode setting or default to false
    final savedDemo = _box.read(AppConstants.keyDemoMode);
    if (savedDemo != null) {
      isDemoMode.value = savedDemo;
    }

    // Initial Fetch
    fetchData(showLoading: true);

    // Start auto-refresh timer (every 15 seconds)
    _startAutoRefresh();

    // Listen to Demo Mode changes to trigger refresh immediately
    ever(isDemoMode, (_) {
      _box.write(AppConstants.keyDemoMode, isDemoMode.value);
      fetchData(showLoading: true);
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.refreshIntervalSeconds),
      (timer) {
        fetchData(showLoading: false);
      },
    );
  }

  Future<void> fetchData({bool showLoading = false}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    
    try {
      // 1. Fetch current feed status
      final feed = await _repository.getLastFeed(forceMock: isDemoMode.value);
      
      // Check alerts and status modifications
      _checkAlertsAndNotifications(feed);
      
      currentFeed.value = feed;
      
      // 2. Fetch history feeds for charts
      final history = await _repository.getFeedsHistory(
        results: 15,
        forceMock: isDemoMode.value,
      );
      historyFeeds.assignAll(history);

      hasError.value = false;
      errorMessage.value = '';
      lastSyncedTime.value = DateTime.now();
    } catch (e) {
      // Only set UI to error state if we don't have existing feed data
      if (currentFeed.value == null) {
        hasError.value = true;
        errorMessage.value = e.toString();
      } else {
        // If we already have data, keep it and show a non-intrusive snackbar
        Get.snackbar(
          'Sync Timeout',
          'Unable to reach IoT feed. Displaying cached classroom data.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
          icon: const Icon(Icons.cloud_off, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleDemoMode() {
    isDemoMode.value = !isDemoMode.value;
  }

  void _checkAlertsAndNotifications(ClassroomFeed newFeed) {
    // A. Temperature Alert (> 35°C)
    if (newFeed.temperature > AppConstants.temperatureThresholdWarning) {
      if (!showTempWarningBanner.value) {
        showTempWarningBanner.value = true;
        Get.snackbar(
          'High Temperature Warning',
          'Classroom temperature is critical at ${newFeed.temperature}°C!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(15),
          borderRadius: 12,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        );
      }
    } else {
      showTempWarningBanner.value = false;
    }

    // B. Occupancy Change Alerts (only trigger if we had a previous value)
    if (currentFeed.value != null) {
      final oldOccupancy = currentFeed.value!.occupancy;
      final newOccupancy = newFeed.occupancy;

      if (oldOccupancy != newOccupancy) {
        final status = newOccupancy == 1 ? 'OCCUPIED' : 'EMPTY';
        final color = newOccupancy == 1 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
        final icon = newOccupancy == 1 ? Icons.meeting_room : Icons.no_meeting_room;

        Get.snackbar(
          'Room Status Change',
          'Classroom is now $status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: color,
          colorText: Colors.white,
          icon: Icon(icon, color: Colors.white, size: 28),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(15),
          borderRadius: 12,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        );
      }
    }
  }
}
