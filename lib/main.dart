import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/theme/app_theme.dart';
import 'controllers/theme_controller.dart';
import 'controllers/classroom_controller.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local persistent storage
  await GetStorage.init();
  
  // Bind controllers permanently in GetX DI container
  final themeController = Get.put(ThemeController());
  Get.put(ClassroomController());

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        title: 'Smart Classroom Monitor',
        debugShowCheckedModeBanner: false,
        
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      );
    });
  }
}
