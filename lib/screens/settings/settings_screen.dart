import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/classroom_controller.dart';
import '../../core/responsive/responsive_helper.dart';
import '../../widgets/cards/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    final classroomController = Get.find<ClassroomController>();

    final padding = ResponsiveHelper.padding(context, 16);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.fontSize(context, 18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Appearance'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildThemeOption(
                    context,
                    title: 'System Default',
                    subtitle: 'Adapt theme to system preferences',
                    value: 'system',
                    icon: Icons.brightness_auto_rounded,
                    themeController: themeController,
                  ),
                  _buildDivider(context),
                  _buildThemeOption(
                    context,
                    title: 'Light Theme',
                    subtitle: 'Clean white background style',
                    value: 'light',
                    icon: Icons.light_mode_rounded,
                    themeController: themeController,
                  ),
                  _buildDivider(context),
                  _buildThemeOption(
                    context,
                    title: 'Dark Theme',
                    subtitle: 'Premium low-light visual mode',
                    value: 'dark',
                    icon: Icons.dark_mode_rounded,
                    themeController: themeController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Data Mode & Simulation'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final isDemo = classroomController.isDemoMode.value;
                    return SwitchListTile(
                      activeThumbColor: theme.primaryColor,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDemo 
                              ? Colors.orange.withOpacity(0.12)
                              : theme.primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDemo ? Icons.bolt_rounded : Icons.cloud_done_rounded,
                          color: isDemo ? Colors.orange : theme.primaryColor,
                        ),
                      ),
                      title: Text(
                        'Demo Mode (Simulation)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.fontSize(context, 14),
                        ),
                      ),
                      subtitle: Text(
                        'Generate real-time simulated telemetry to demonstrate interactive UI changes when API is private or offline.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                          fontSize: ResponsiveHelper.fontSize(context, 11),
                        ),
                      ),
                      value: isDemo,
                      onChanged: (val) => classroomController.toggleDemoMode(),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'System Info'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow(context, 'App Version', '1.0.0 (Production)'),
                  _buildDivider(context),
                  _buildInfoRow(context, 'ThingSpeak Channel ID', '3401297'),
                  _buildDivider(context),
                  _buildInfoRow(context, 'Auto Sync Interval', 'Every 15 Seconds'),
                  _buildDivider(context),
                  _buildInfoRow(context, 'Temperature Warning Limit', 'Above 35.0 °C'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
          letterSpacing: 0.5,
          fontSize: ResponsiveHelper.fontSize(context, 12),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required ThemeController themeController,
  }) {
    final theme = Theme.of(context);
    return Obx(() {
      final isSelected = themeController.themeModeString == value;
      return RadioListTile<String>(
        activeColor: theme.primaryColor,
        secondary: Icon(
          icon,
          color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.6),
          size: ResponsiveHelper.fontSize(context, 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: ResponsiveHelper.fontSize(context, 14),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.55),
            fontSize: ResponsiveHelper.fontSize(context, 11),
          ),
        ),
        value: value,
        groupValue: themeController.themeModeString,
        onChanged: (val) {
          if (val != null) {
            themeController.setThemeMode(val);
          }
        },
      );
    });
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.fontSize(context, 13),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.fontSize(context, 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
      height: 1,
      thickness: 1,
    );
  }
}
