import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants/app_constants.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final RxString _themeModeString = 'system'.obs;

  String get themeModeString => _themeModeString.value;

  ThemeMode get themeMode {
    switch (_themeModeString.value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  void onInit() {
    super.onInit();
    final savedMode = _box.read(AppConstants.keyThemeMode);
    if (savedMode != null) {
      _themeModeString.value = savedMode;
    }
  }

  void setThemeMode(String mode) {
    if (mode == 'light' || mode == 'dark' || mode == 'system') {
      _themeModeString.value = mode;
      _box.write(AppConstants.keyThemeMode, mode);
      Get.changeThemeMode(themeMode);
    }
  }
}
