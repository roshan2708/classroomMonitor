import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/responsive/responsive_helper.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/classroom_feed.dart';

class TrendChart extends StatelessWidget {
  final String title;
  final List<ClassroomFeed> feeds;
  final double Function(ClassroomFeed) valueSelector;
  final Color lineColor;
  final Color? gradientColor;
  final String unit;
  final double minY;
  final double maxY;
  final String Function(double value)? yAxisLabelFormatter;
  final double? yAxisInterval;

  const TrendChart({
    super.key,
    required this.title,
    required this.feeds,
    required this.valueSelector,
    required this.lineColor,
    this.gradientColor,
    required this.unit,
    required this.minY,
    required this.maxY,
    this.yAxisLabelFormatter,
    this.yAxisInterval,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (feeds.isEmpty) {
      return Center(
        child: Text(
          'No historical data available.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: ResponsiveHelper.fontSize(context, 14),
          ),
        ),
      );
    }

    final List<FlSpot> spots = [];
    for (int i = 0; i < feeds.length; i++) {
      spots.add(FlSpot(i.toDouble(), valueSelector(feeds[i])));
    }

    final startGradient = gradientColor ?? lineColor.withOpacity(0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.fontSize(context, 15),
              color: theme.colorScheme.onBackground.withOpacity(0.85),
            ),
          ),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: yAxisInterval ?? ((maxY - minY) == 0 ? 1 : (maxY - minY) / 4),
                verticalInterval: 3,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  strokeWidth: 1.0,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  strokeWidth: 1.0,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 3,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < feeds.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormatter.formatTime(feeds[index].createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                              fontSize: ResponsiveHelper.fontSize(context, 8.5),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    interval: yAxisInterval,
                    getTitlesWidget: (value, meta) {
                      final labelText = yAxisLabelFormatter != null
                          ? yAxisLabelFormatter!(value)
                          : '${value.toStringAsFixed(0)}$unit';
                      return Text(
                        labelText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontSize: ResponsiveHelper.fontSize(context, 8.5),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  width: 1,
                ),
              ),
              minX: 0,
              maxX: (feeds.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [lineColor, lineColor.withOpacity(0.75)],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3,
                      color: lineColor,
                      strokeWidth: 1.5,
                      strokeColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        startGradient,
                        lineColor.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
               lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => isDark ? const Color(0xFF1E293B) : Colors.white,
                  tooltipBorder: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                    width: 1,
                  ),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final feed = feeds[touchedSpot.x.toInt()];
                      return LineTooltipItem(
                        '${touchedSpot.y.toStringAsFixed(1)}$unit\n',
                        theme.textTheme.bodyMedium!.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.fontSize(context, 11),
                        ),
                        children: [
                          TextSpan(
                            text: DateFormatter.formatTime(feed.createdAt),
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontSize: ResponsiveHelper.fontSize(context, 9),
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
