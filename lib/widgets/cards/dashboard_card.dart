import 'package:flutter/material.dart';
import '../../core/responsive/responsive_helper.dart';
import '../../core/utils/date_formatter.dart';
import './glass_card.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final IconData icon;
  final Color statusColor;
  final DateTime lastUpdated;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    required this.statusColor,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: ResponsiveHelper.fontSize(context, 14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: statusColor,
                  size: ResponsiveHelper.fontSize(context, 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.fontSize(context, 26),
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.fontSize(context, 9),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: ResponsiveHelper.fontSize(context, 12),
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatTime(lastUpdated),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: ResponsiveHelper.fontSize(context, 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
