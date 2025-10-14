import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final double size;
  final Color? progressColor;
  final Color? backgroundColor;
  final double strokeWidth;
  final Widget? child;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.size = 200,
    this.progressColor,
    this.backgroundColor,
    this.strokeWidth = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultProgressColor = progressColor ?? AppColors.primary;
    final defaultBackgroundColor =
        backgroundColor ??
        (isDark ? AppColors.darkSecondary : AppColors.lightSecondary);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: defaultBackgroundColor.withOpacity(0.2),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(defaultProgressColor),
              backgroundColor: Colors.transparent,
            ),
          ),
          // Child content
          if (child != null) Center(child: child!),
        ],
      ),
    );
  }
}
