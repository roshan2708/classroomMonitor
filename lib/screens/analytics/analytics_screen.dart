import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/classroom_controller.dart';
import '../../core/responsive/responsive_helper.dart';
import '../../widgets/cards/glass_card.dart';
import '../../widgets/charts/trend_chart.dart';
import '../../widgets/loading/shimmer_loading.dart';
import '../../widgets/common/error_view.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classroomController = Get.find<ClassroomController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics Trends',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.fontSize(context, 18),
          ),
        ),
      ),
      body: Obx(() {
        if (classroomController.isLoading.value) {
          return const AnalyticsShimmer();
        }

        if (classroomController.hasError.value) {
          return ErrorView(
            errorMessage: classroomController.errorMessage.value,
            onRetry: () => classroomController.fetchData(showLoading: true),
          );
        }

        final feeds = classroomController.historyFeeds;
        if (feeds.isEmpty) {
          return ErrorView(
            errorMessage: 'No telemetry history found on the IoT server.',
            onRetry: () => classroomController.fetchData(showLoading: true),
          );
        }

        final padding = ResponsiveHelper.padding(context, 16);
        final width = ResponsiveHelper.screenWidth(context);
        final isWide = width >= 1000;

        final charts = [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: TrendChart(
              title: 'Temperature Trend',
              feeds: feeds,
              valueSelector: (f) => f.temperature,
              lineColor: const Color(0xFF2563EB),
              gradientColor: const Color(0xFF2563EB).withOpacity(0.15),
              unit: '°C',
              minY: 15,
              maxY: 45,
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: TrendChart(
              title: 'Humidity Trend',
              feeds: feeds,
              valueSelector: (f) => f.humidity,
              lineColor: const Color(0xFF10B981),
              gradientColor: const Color(0xFF10B981).withOpacity(0.15),
              unit: '%',
              minY: 30,
              maxY: 90,
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: TrendChart(
              title: 'Light Intensity Trend',
              feeds: feeds,
              valueSelector: (f) => f.lightIntensity,
              lineColor: const Color(0xFFF59E0B),
              gradientColor: const Color(0xFFF59E0B).withOpacity(0.15),
              unit: ' lx',
              minY: 0,
              maxY: 1000,
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: TrendChart(
              title: 'Occupancy Trend',
              feeds: feeds,
              valueSelector: (f) => f.occupancy.toDouble(),
              lineColor: const Color(0xFFEF4444),
              gradientColor: const Color(0xFFEF4444).withOpacity(0.15),
              unit: '',
              minY: -0.2,
              maxY: 1.2,
              yAxisInterval: 1.0,
              yAxisLabelFormatter: (val) {
                if (val.toInt() == 0) return 'Empty';
                if (val.toInt() == 1) return 'Occupied';
                return '';
              },
            ),
          ),
        ];

        return RefreshIndicator(
          onRefresh: () => classroomController.fetchData(showLoading: false),
          color: theme.primaryColor,
          child: isWide
              ? GridView.builder(
                  padding: EdgeInsets.all(padding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: padding,
                    mainAxisSpacing: padding,
                    childAspectRatio: 1.45,
                  ),
                  itemCount: charts.length,
                  itemBuilder: (context, idx) => charts[idx],
                )
              : ListView.builder(
                  padding: EdgeInsets.all(padding),
                  itemCount: charts.length,
                  itemBuilder: (context, idx) => Padding(
                    padding: EdgeInsets.only(bottom: padding),
                    child: SizedBox(
                      height: 290,
                      child: charts[idx],
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
