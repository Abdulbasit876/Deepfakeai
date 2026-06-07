import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/analysis/presentation/result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final int mediaType; // 0 = Image, 1 = Video, 2 = Audio

  const ProcessingScreen({super.key, required this.mediaType});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with SingleTickerProviderStateMixin {
  double _scanProgress = 0.0;
  Timer? _timer;
  late AnimationController _waveController;

  // Operational checklist states
  int _currentStepIndex = 0;
  late List<String> _checklistSteps;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Map Checklist Steps based on media type
    if (widget.mediaType == 0) {
      _checklistSteps = [
        "Scanning pixels",
        "Detecting patterns",
        "Comparing database",
        "Finalizing results",
      ];
    } else if (widget.mediaType == 1) {
      _checklistSteps = [
        "Extracting frames",
        "Analyzing frames",
        "Checking inconsistencies",
        "Finalizing results",
      ];
    } else {
      _checklistSteps = [
        "Reading waveform",
        "Analyzing frequency",
        "Matching patterns",
        "Finalizing results",
      ];
    }

    // Simulate scanning progress and operational checklist steps
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      setState(() {
        if (_scanProgress < 1.0) {
          _scanProgress += 0.01;
          
          // Map checklist state transitions
          if (_scanProgress >= 0.75) {
            _currentStepIndex = 3;
          } else if (_scanProgress >= 0.50) {
            _currentStepIndex = 2;
          } else if (_scanProgress >= 0.25) {
            _currentStepIndex = 1;
          } else {
            _currentStepIndex = 0;
          }
        } else {
          _timer?.cancel();
          _navigateToResult();
        }
      });
    });
  }

  void _navigateToResult() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(mediaType: widget.mediaType),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaLabel = widget.mediaType == 0 ? "Image" : (widget.mediaType == 1 ? "Video" : "Audio");

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.bgGradient(isDark),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header back action
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg(isDark),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardBorder(isDark)),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  "Analyzing $mediaLabel",
                  style: AppTextStyles.getHeadingMedium(isDark),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.mediaType == 0 
                      ? "Our AI is scanning the image pixels..." 
                      : (widget.mediaType == 1 ? "Scanning frames sequence..." : "Processing audio waveforms..."),
                  style: AppTextStyles.getBodyMedium(isDark),
                ),
                const SizedBox(height: 36),

                // Large Dynamic Visualizer Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg(isDark),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cardBorder(isDark), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: ScannerVisualizerPainter(
                              mediaType: widget.mediaType,
                              progress: _scanProgress,
                              animationValue: _waveController.value,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Numerical percentage indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Scanning Progress",
                      style: AppTextStyles.getLabelMedium(isDark),
                    ),
                    Text(
                      "${(_scanProgress * 100).toInt()}%",
                      style: TextStyle(
                        color: AppColors.neonBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress Loading bar
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder(isDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: _scanProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Checklist checklist displaying scanning state animations
                Column(
                  children: List.generate(_checklistSteps.length, (index) {
                    return _buildChecklistItem(index, isDark);
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(int index, bool isDark) {
    final stepText = _checklistSteps[index];
    final isCompleted = _currentStepIndex > index;
    final isCurrent = _currentStepIndex == index;

    IconData icon;
    Color iconColor;
    if (isCompleted) {
      icon = Icons.check_circle_rounded;
      iconColor = AppColors.successGreen;
    } else if (isCurrent) {
      icon = Icons.radio_button_checked_rounded;
      iconColor = AppColors.neonBlue;
    } else {
      icon = Icons.radio_button_off_rounded;
      iconColor = AppColors.textSecondary(isDark).withValues(alpha: 0.4);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 14),
          Text(
            stepText,
            style: TextStyle(
              color: isCompleted 
                  ? AppColors.textPrimary(isDark) 
                  : (isCurrent ? AppColors.neonBlue : AppColors.textSecondary(isDark).withValues(alpha: 0.5)),
              fontSize: 14,
              fontWeight: isCurrent || isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter mapping Image head scan wireframe, Video timeline, and Audio oscillating wave
class ScannerVisualizerPainter extends CustomPainter {
  final int mediaType;
  final double progress;
  final double animationValue;
  final bool isDark;

  ScannerVisualizerPainter({
    required this.mediaType,
    required this.progress,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (mediaType == 0) {
      _paintFaceScan(canvas, size, center);
    } else if (mediaType == 1) {
      _paintVideoTimeline(canvas, size, center);
    } else {
      _paintAudioSoundwave(canvas, size, center);
    }

    // Top-to-bottom laser sweeping line
    final laserY = size.height * progress;
    final laserPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, AppColors.neonBlue, Colors.transparent],
      ).createShader(Rect.fromLTRB(0, laserY - 10, size.width, laserY + 10))
      ..strokeWidth = 3;
    
    canvas.drawLine(Offset(0, laserY), Offset(size.width, laserY), laserPaint);

    // Glowing laser dust particles
    final glowPaint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRect(Rect.fromLTRB(0, laserY - 14, size.width, laserY + 14), glowPaint);
  }

  void _paintFaceScan(Canvas canvas, Size size, Offset center) {
    final facePaint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid coordinates
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), facePaint);
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), facePaint);
    }

    // Paint holographic facial wireframe head outline
    final path = Path();
    path.moveTo(center.dx, center.dy - 100);
    // Forehead
    path.quadraticBezierTo(center.dx + 70, center.dy - 90, center.dx + 70, center.dy - 30);
    // Cheek
    path.quadraticBezierTo(center.dx + 80, center.dy + 20, center.dx + 40, center.dy + 70);
    // Chin
    path.quadraticBezierTo(center.dx + 25, center.dy + 95, center.dx, center.dy + 100);
    // Chin left side
    path.quadraticBezierTo(center.dx - 25, center.dy + 95, center.dx - 40, center.dy + 70);
    // Left cheek
    path.quadraticBezierTo(center.dx - 80, center.dy + 20, center.dx - 70, center.dy - 30);
    // Left forehead
    path.quadraticBezierTo(center.dx - 70, center.dy - 90, center.dx, center.dy - 100);
    path.close();

    final outlinePaint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, outlinePaint);

    // Glowing scanners nodes overlay
    final ptPaint = Paint()
      ..color = AppColors.neonPink
      ..style = PaintingStyle.fill;
    
    // Pulse animation based on animationValue
    final nodesScale = 1.0 + 0.15 * sin(animationValue * 2 * pi);
    canvas.drawCircle(Offset(center.dx - 25, center.dy - 20), 4 * nodesScale, ptPaint); // Left eye
    canvas.drawCircle(Offset(center.dx + 25, center.dy - 20), 4 * nodesScale, ptPaint); // Right eye
    canvas.drawCircle(Offset(center.dx, center.dy + 10), 3 * nodesScale, ptPaint);      // Nose tip
    canvas.drawCircle(Offset(center.dx, center.dy + 45), 4 * nodesScale, ptPaint);      // Mouth
  }

  void _paintVideoTimeline(Canvas canvas, Size size, Offset center) {
    // Film strip boundary
    final stripPaint = Paint()
      ..color = AppColors.cardBorder(isDark)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final stripHeight = size.height * 0.4;
    final topY = center.dy - stripHeight / 2;
    final bottomY = center.dy + stripHeight / 2;

    canvas.drawLine(Offset(0, topY), Offset(size.width, topY), stripPaint);
    canvas.drawLine(Offset(0, bottomY), Offset(size.width, bottomY), stripPaint);

    // Small square sprocket holes at top and bottom of film reel
    final sprocketPaint = Paint()
      ..color = AppColors.textSecondary(isDark).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (double x = 10; x < size.width; x += 25) {
      canvas.drawRect(Rect.fromLTWH(x, topY + 4, 12, 10), sprocketPaint);
      canvas.drawRect(Rect.fromLTWH(x, bottomY - 14, 12, 10), sprocketPaint);
    }

    // Overlapping checking lens
    final checkLens = Paint()
      ..color = AppColors.neonPink.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    
    final checkLensStroke = Paint()
      ..color = AppColors.neonPink
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // A shifting rectangle box mimicking sequential frame extraction
    final shiftX = (animationValue * (size.width - 120));
    final frameRect = Rect.fromLTWH(shiftX, topY + 20, 110, stripHeight - 40);
    
    canvas.drawRect(frameRect, checkLens);
    canvas.drawRect(frameRect, checkLensStroke);

    // Dynamic grid overlay inside the active checking frame
    final gridPaint = Paint()
      ..color = AppColors.neonPink.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    
    canvas.drawLine(Offset(shiftX + 36, topY + 20), Offset(shiftX + 36, bottomY - 20), gridPaint);
    canvas.drawLine(Offset(shiftX + 72, topY + 20), Offset(shiftX + 72, bottomY - 20), gridPaint);
    canvas.drawLine(Offset(shiftX, topY + (stripHeight / 2)), Offset(shiftX + 110, topY + (stripHeight / 2)), gridPaint);
  }

  void _paintAudioSoundwave(Canvas canvas, Size size, Offset center) {
    final wavePaint = Paint()
      ..shader = AppColors.accentGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw active dynamic soundwave oscillation via path
    final wavePath = Path();
    wavePath.moveTo(0, center.dy);

    const int barCount = 48;
    final double barSpacing = size.width / barCount;

    for (int i = 0; i <= barCount; i++) {
      final double x = i * barSpacing;
      
      // Calculate dynamic sine heights pulsing according to index and animationValue
      final amplitudeMultiplier = sin(i * 0.4 + animationValue * 2 * pi);
      final envelope = sin((i / barCount) * pi); // taper soundwave ends
      final height = 75 * amplitudeMultiplier * envelope;
      
      wavePath.lineTo(x, center.dy + height);
    }
    canvas.drawPath(wavePath, wavePaint);

    // Glowing neon dot particles on wave peaks
    final ptPaint = Paint()
      ..color = AppColors.neonPink
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - 50, center.dy + 35 * sin(animationValue * 2 * pi)),
      4,
      ptPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 60, center.dy + 25 * cos(animationValue * 2 * pi)),
      5,
      ptPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerVisualizerPainter oldDelegate) => true;
}
