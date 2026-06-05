import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? color;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.border,
    this.color,
    this.blur = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(20);
    
    // Choose beautiful translucent colors optimized for background styles
    final defaultColor = color ?? (isDark
        ? Colors.white.withOpacity(0.03)
        : Colors.white.withOpacity(0.4));
        
    final defaultBorder = border ?? Border.all(
      color: isDark 
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06),
      width: 1.5,
    );

    return ClipRRect(
      borderRadius: defaultBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: defaultColor,
            borderRadius: defaultBorderRadius,
            border: defaultBorder,
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
