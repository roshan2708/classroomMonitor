import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/classroom_controller.dart';
import '../../core/responsive/responsive_helper.dart';
import '../../core/utils/date_formatter.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/cards/glass_card.dart';
import '../../widgets/loading/shimmer_loading.dart';
import '../../widgets/common/error_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ClassroomController controller = Get.find<ClassroomController>();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Classroom Monitor',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.fontSize(context, 18),
          ),
        ),
        actions: [
          Obx(() {
            final lastSync = controller.lastSyncedTime.value;
            if (lastSync == null) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.sync_rounded,
                    size: ResponsiveHelper.fontSize(context, 14),
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Synced: ${DateFormatter.formatTime(lastSync)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: ResponsiveHelper.fontSize(context, 11),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const DashboardShimmer();
        }

        if (controller.hasError.value) {
          return ErrorView(
            errorMessage: controller.errorMessage.value,
            onRetry: () => controller.fetchData(showLoading: true),
          );
        }

        final feed = controller.currentFeed.value;
        if (feed == null) {
          return ErrorView(
            errorMessage: 'No data retrieved from IoT server.',
            onRetry: () => controller.fetchData(showLoading: true),
          );
        }

        // Calculate statistics
        final history = controller.historyFeeds;
        double minTemp = feed.temperature;
        double maxTemp = feed.temperature;
        double avgTemp = feed.temperature;
        double minHum = feed.humidity;
        double maxHum = feed.humidity;
        double avgHum = feed.humidity;
        double minLight = feed.lightIntensity;
        double maxLight = feed.lightIntensity;
        double avgLight = feed.lightIntensity;
        double occupancyRate = feed.isOccupied ? 100.0 : 0.0;

        if (history.isNotEmpty) {
          final temps = history.map((e) => e.temperature).toList();
          final hums = history.map((e) => e.humidity).toList();
          final lights = history.map((e) => e.lightIntensity).toList();
          final occs = history.map((e) => e.occupancy).toList();

          minTemp = temps.reduce((a, b) => a < b ? a : b);
          maxTemp = temps.reduce((a, b) => a > b ? a : b);
          avgTemp = temps.reduce((a, b) => a + b) / temps.length;

          minHum = hums.reduce((a, b) => a < b ? a : b);
          maxHum = hums.reduce((a, b) => a > b ? a : b);
          avgHum = hums.reduce((a, b) => a + b) / hums.length;

          minLight = lights.reduce((a, b) => a < b ? a : b);
          maxLight = lights.reduce((a, b) => a > b ? a : b);
          avgLight = lights.reduce((a, b) => a + b) / lights.length;

          final occupiedCount = occs.where((o) => o == 1).length;
          occupancyRate = (occupiedCount / occs.length) * 100;
        }

        // Status determinations
        final Color tempColor = feed.temperature > 35.0 ? const Color(0xFFEF4444) : const Color(0xFF2563EB);
        final Color humColor = feed.humidity > 70.0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
        
        Color lightColor = const Color(0xFF10B981);
        if (feed.lightIntensity > 600) {
          lightColor = const Color(0xFFF59E0B);
        } else if (feed.lightIntensity < 300) {
          lightColor = const Color(0xFF64748B);
        }

        final Color occColor = feed.isOccupied ? const Color(0xFF10B981) : const Color(0xFFEF4444);

        final padding = ResponsiveHelper.padding(context, 16);
        final width = ResponsiveHelper.screenWidth(context);
        final isDesktop = ResponsiveHelper.isDesktop(context);
        
        int gridColumns = 2;
        if (width >= 1200) {
          gridColumns = 4;
        } else {
          gridColumns = 2;
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchData(showLoading: false),
          color: theme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Temperature Alert Banner
                if (controller.showTempWarningBanner.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HIGH CLASSROOM TEMPERATURE DETECTED',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: const Color(0xFFEF4444),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'The temperature has exceeded the safety threshold of 35.0°C.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Occupancy pulsating banner indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: feed.isOccupied 
                          ? const Color(0xFF10B981).withOpacity(0.1) 
                          : const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: feed.isOccupied 
                            ? const Color(0xFF10B981).withOpacity(0.2) 
                            : const Color(0xFFEF4444).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: feed.isOccupied 
                                        ? const Color(0xFF10B981).withOpacity(_pulseAnimation.value)
                                        : const Color(0xFFEF4444).withOpacity(_pulseAnimation.value),
                                    boxShadow: [
                                      BoxShadow(
                                        color: feed.isOccupied 
                                            ? const Color(0xFF10B981).withOpacity(0.5)
                                            : const Color(0xFFEF4444).withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2 * _pulseAnimation.value,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feed.isOccupied ? 'CLASSROOM OCCUPIED' : 'CLASSROOM EMPTY',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: feed.isOccupied ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    letterSpacing: 0.5,
                                    fontSize: ResponsiveHelper.fontSize(context, 14),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  feed.isOccupied ? 'Student activity detected inside room' : 'No occupancy detected',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onBackground.withOpacity(0.55),
                                    fontSize: ResponsiveHelper.fontSize(context, 11),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(
                          feed.isOccupied ? Icons.people_rounded : Icons.people_outline_rounded,
                          color: feed.isOccupied ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: ResponsiveHelper.fontSize(context, 26),
                        ),
                      ],
                    ),
                  ),
                ),

                // Responsive cards grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: gridColumns,
                  crossAxisSpacing: padding,
                  mainAxisSpacing: padding,
                  childAspectRatio: gridColumns == 4 ? 1.35 : 1.25,
                  children: [
                    DashboardCard(
                      title: 'Temperature',
                      value: '${feed.temperature}°C',
                      status: feed.tempStatus,
                      icon: Icons.thermostat_rounded,
                      statusColor: tempColor,
                      lastUpdated: feed.createdAt,
                    ),
                    DashboardCard(
                      title: 'Humidity',
                      value: '${feed.humidity}%',
                      status: feed.humidityStatus,
                      icon: Icons.water_drop_rounded,
                      statusColor: humColor,
                      lastUpdated: feed.createdAt,
                    ),
                    DashboardCard(
                      title: 'Light Intensity',
                      value: '${feed.lightIntensity.toStringAsFixed(0)} lx',
                      status: feed.lightStatus,
                      icon: Icons.light_mode_rounded,
                      statusColor: lightColor,
                      lastUpdated: feed.createdAt,
                    ),
                    DashboardCard(
                      title: 'Occupancy Status',
                      value: feed.isOccupied ? 'Occupied' : 'Empty',
                      status: feed.isOccupied ? 'Active' : 'Idle',
                      icon: Icons.door_sliding_rounded,
                      statusColor: occColor,
                      lastUpdated: feed.createdAt,
                    ),
                  ],
                ),
                SizedBox(height: padding),

                // Dashboard Summary and Stats Section
                Text(
                  'Dashboard Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.fontSize(context, 16),
                  ),
                ),
                const SizedBox(height: 12),
                
                GlassCard(
                  padding: EdgeInsets.all(ResponsiveHelper.padding(context, 20)),
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(child: _buildSummaryItem(context, 'Temperature Status', feed.tempStatus, tempColor)),
                            _buildDivider(context, true),
                            Expanded(child: _buildSummaryItem(context, 'Humidity Status', feed.humidityStatus, humColor)),
                            _buildDivider(context, true),
                            Expanded(child: _buildSummaryItem(context, 'Light Status', feed.lightStatus, lightColor)),
                            _buildDivider(context, true),
                            Expanded(child: _buildSummaryItem(context, 'Avg Occupancy Rate', '${occupancyRate.toStringAsFixed(0)}%', occColor)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildSummaryItem(context, 'Temperature Status', feed.tempStatus, tempColor),
                            _buildDivider(context, false),
                            _buildSummaryItem(context, 'Humidity Status', feed.humidityStatus, humColor),
                            _buildDivider(context, false),
                            _buildSummaryItem(context, 'Light Status', feed.lightStatus, lightColor),
                            _buildDivider(context, false),
                            _buildSummaryItem(context, 'Avg Occupancy Rate', '${occupancyRate.toStringAsFixed(0)}%', occColor),
                          ],
                        ),
                ),
                SizedBox(height: padding),

                // Statistics Section
                Text(
                  'Telemetry Statistics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.fontSize(context, 16),
                  ),
                ),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideStats = constraints.maxWidth >= 750;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWideStats ? 3 : 1,
                      crossAxisSpacing: padding,
                      mainAxisSpacing: padding,
                      childAspectRatio: isWideStats ? 1.5 : 2.5,
                      children: [
                        _buildStatCard(context, 'Temperature (°C)', minTemp, maxTemp, avgTemp, Colors.blue),
                        _buildStatCard(context, 'Humidity (%)', minHum, maxHum, avgHum, Colors.teal),
                        _buildStatCard(context, 'Light Intensity (lx)', minLight, maxLight, avgLight, Colors.amber),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String title, String status, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.fontSize(context, 13),
            ),
          ),
          Text(
            status,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.fontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context, bool isVertical) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);
    
    if (isVertical) {
      return Container(
        width: 1.5,
        height: 40,
        color: color,
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );
    } else {
      return Container(
        height: 1.5,
        color: color,
        margin: const EdgeInsets.symmetric(vertical: 8),
      );
    }
  }

  Widget _buildStatCard(BuildContext context, String title, double min, double max, double avg, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: ResponsiveHelper.fontSize(context, 12),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatValue(context, 'Min', min.toStringAsFixed(1)),
                _buildStatValue(context, 'Max', max.toStringAsFixed(1)),
                _buildStatValue(context, 'Avg', avg.toStringAsFixed(1), highlight: true, highlightColor: color),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatValue(BuildContext context, String label, String value, {bool highlight = false, Color? highlightColor}) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.45),
            fontSize: ResponsiveHelper.fontSize(context, 10),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? highlightColor : null,
            fontSize: ResponsiveHelper.fontSize(context, 14),
          ),
        ),
      ],
    );
  }
}
