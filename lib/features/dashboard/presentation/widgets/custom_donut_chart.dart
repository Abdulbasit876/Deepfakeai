import 'package:flutter/material.dart';
import 'dart:math';
import 'package:deepfake_ai/core/constants/app_colors.dart';

class CustomDonutChart extends StatelessWidget {
  final double aiPercentage; // e.g. 62
  final double realisticPercentage; // e.g. 38

  const CustomDonutChart({
    Key? key,
    this.aiPercentage = 62.0,
    this.realisticPercentage = 38.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The Donut Circle Drawing
        SizedBox(
          height: 140,
          width: 140,
          child: CustomPaint(
            painter: DonutChartPainter(
              aiPercentage: aiPercentage,
              realisticPercentage: realisticPercentage,
              isDark: isDark,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${aiPercentage.toInt()}%",
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkBgStart,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "AI Generated",
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),

        // Legends
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem("AI Generated", aiPercentage, AppColors.neonPink, isDark),
            const SizedBox(height: 14),
            _buildLegendItem("Realistic", realisticPercentage, AppColors.neonBlue, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, double percentage, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${percentage.toInt()}%",
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double aiPercentage;
  final double realisticPercentage;
  final bool isDark;

  DonutChartPainter({
    required this.aiPercentage,
    required this.realisticPercentage,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.3;
    final strokeWidth = 14.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Empty background ring
    final bgPaint = Paint()
      ..color = AppColors.cardBorder(isDark).withOpacity(0.4)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Calculate arc angles
    final aiAngle = (aiPercentage / 100) * 2 * pi;
    final realisticAngle = (realisticPercentage / 100) * 2 * pi;

    // Start drawing AI Generated Arc (Glow + Sweep)
    final aiPaintGlow = Paint()
      ..color = AppColors.neonPink.withOpacity(0.3)
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final aiPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.neonPink, AppColors.electricViolet],
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw AI arc (Starting from top: -pi/2)
    canvas.drawArc(rect, -pi / 2, aiAngle, false, aiPaintGlow);
    canvas.drawArc(rect, -pi / 2, aiAngle, false, aiPaint);

    // Start drawing Realistic Arc (Glow + Sweep)
    final realisticPaintGlow = Paint()
      ..color = AppColors.neonBlue.withOpacity(0.3)
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final realisticPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.neonBlue, AppColors.successGreen],
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw Realistic arc (Starting from end of AI Arc with slight gap offset)
    final startAngle = -pi / 2 + aiAngle + 0.12;
    final sweepAngle = realisticAngle - 0.12;

    canvas.drawArc(rect, startAngle, sweepAngle, false, realisticPaintGlow);
    canvas.drawArc(rect, startAngle, sweepAngle, false, realisticPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
