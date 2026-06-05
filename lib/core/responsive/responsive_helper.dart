import 'package:flutter/widgets.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static Orientation orientation(BuildContext context) => MediaQuery.of(context).orientation;

  static bool isLandscape(BuildContext context) =>
      orientation(context) == Orientation.landscape;

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < 600;

  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= 600 && screenWidth(context) < 1200;

  static bool isDesktop(BuildContext context) =>
      screenWidth(context) >= 1200;

  // Responsive design system typography and spacing scaling
  static double fontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) {
      return baseSize * 1.25;
    } else if (isTablet(context)) {
      return baseSize * 1.15;
    } else {
      return baseSize;
    }
  }

  static double padding(BuildContext context, double basePadding) {
    if (isDesktop(context)) {
      return basePadding * 1.5;
    } else if (isTablet(context)) {
      return basePadding * 1.25;
    } else {
      return basePadding;
    }
  }

  static double cardHeight(BuildContext context, double baseHeight) {
    if (isDesktop(context)) {
      return baseHeight * 1.2;
    } else if (isTablet(context)) {
      return baseHeight * 1.1;
    } else {
      return baseHeight;
    }
  }
}
