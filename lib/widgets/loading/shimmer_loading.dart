import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/responsive/responsive_helper.dart';

class ShimmerLoader extends StatelessWidget {
  final Widget child;

  const ShimmerLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      child: child,
    );
  }
}

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.padding(context, 16);

    // Compute column count dynamically
    final double width = ResponsiveHelper.screenWidth(context);
    int cols = 2;
    if (width >= 1200) {
      cols = 4;
    } else {
      cols = 2;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoader(
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          SizedBox(height: padding),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: padding,
              mainAxisSpacing: padding,
              childAspectRatio: cols == 4 ? 1.4 : 1.3,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return ShimmerLoader(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: padding),
          ShimmerLoader(
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsShimmer extends StatelessWidget {
  const AnalyticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.padding(context, 16);
    
    // Grid or column layout for charts based on width
    final isWide = ResponsiveHelper.screenWidth(context) >= 1000;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: isWide
          ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: padding,
                mainAxisSpacing: padding,
                childAspectRatio: 1.4,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ShimmerLoader(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            )
          : Column(
              children: List.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: padding),
                  child: ShimmerLoader(
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              }),
            ),
    );
  }
}
