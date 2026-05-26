import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/auth/presentation/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Detect Deepfakes\nWith Advanced AI",
      description: "Our AI analyzes thousands of patterns to detect AI-generated content.",
      illustrationType: IllustrationType.faceScan,
    ),
    OnboardingData(
      title: "Image, Video & Audio\nAnalysis",
      description: "Upload any content and get accurate results instantly.",
      illustrationType: IllustrationType.mediaFolder,
    ),
    OnboardingData(
      title: "Trusted. Accurate.\nPowerful.",
      description: "DeepFake AI gives you reliable insights you can trust.",
      illustrationType: IllustrationType.securityShield,
    ),
  ];

  void _onNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.bgGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Stepper Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "DF",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Icon(
                      Icons.security,
                      color: AppColors.neonBlue,
                      size: 20,
                    ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPageContent(_pages[index], isDark);
                  },
                ),
              ),

              // Bottom Actions Area
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip Button
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          color: AppColors.textSecondary(isDark).withOpacity(0.8),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Stepper Indicator Dots
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => _buildDot(index, isDark),
                      ),
                    ),

                    // Next / Get Started Button
                    GestureDetector(
                      onTap: _onNextPage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonBlue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    final isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.neonBlue : AppColors.cardBorder(isDark),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPageContent(OnboardingData data, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic Illustration Container with CustomPainter
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: CustomPaint(
              painter: OnboardingIllustrationPainter(
                type: data.illustrationType,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          // Stepper Label
          Text(
            "0${_currentPage + 1}",
            style: TextStyle(
              color: AppColors.neonBlue.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.getHeadingMedium(isDark).copyWith(
              fontSize: 24,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.getBodyMedium(isDark).copyWith(
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

enum IllustrationType { faceScan, mediaFolder, securityShield }

class OnboardingData {
  final String title;
  final String description;
  final IllustrationType illustrationType;

  OnboardingData({
    required this.title,
    required this.description,
    required this.illustrationType,
  });
}

// Custom Painter to draw high-tech onboarding shapes natively
class OnboardingIllustrationPainter extends CustomPainter {
  final IllustrationType type;
  final bool isDark;

  OnboardingIllustrationPainter({required this.type, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3.2;

    // Glowing background aura
    final auraPaint = Paint()
      ..color = AppColors.neonBlue.withOpacity(isDark ? 0.08 : 0.03)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius + 20, auraPaint);

    if (type == IllustrationType.faceScan) {
      _drawFaceScan(canvas, size, center, radius);
    } else if (type == IllustrationType.mediaFolder) {
      _drawMediaFolder(canvas, size, center, radius);
    } else if (type == IllustrationType.securityShield) {
      _drawSecurityShield(canvas, size, center, radius);
    }
  }

  void _drawFaceScan(Canvas canvas, Size size, Offset center, double radius) {
    // Background rings
    final ringPaint = Paint()
      ..color = AppColors.neonBlue.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 10, ringPaint);
    canvas.drawCircle(center, radius + 10, ringPaint);

    // Dynamic scanning wireframe facial nodes
    final nodePaint = Paint()
      ..color = AppColors.neonBlue
      ..style = PaintingStyle.fill;
    
    final linePaint = Paint()
      ..color = AppColors.neonBlue.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final nodePoints = [
      Offset(center.dx, center.dy - 50),     // Forehead
      Offset(center.dx - 35, center.dy - 15), // Left eye
      Offset(center.dx + 35, center.dy - 15), // Right eye
      Offset(center.dx, center.dy + 10),      // Nose
      Offset(center.dx - 45, center.dy + 15), // Left cheek
      Offset(center.dx + 45, center.dy + 15), // Right cheek
      Offset(center.dx - 20, center.dy + 45), // Left chin
      Offset(center.dx + 20, center.dy + 45), // Right chin
      Offset(center.dx, center.dy + 60),      // Chin tip
    ];

    // Draw interconnecting grid lines
    canvas.drawLine(nodePoints[0], nodePoints[1], linePaint);
    canvas.drawLine(nodePoints[0], nodePoints[2], linePaint);
    canvas.drawLine(nodePoints[1], nodePoints[2], linePaint);
    canvas.drawLine(nodePoints[1], nodePoints[3], linePaint);
    canvas.drawLine(nodePoints[2], nodePoints[3], linePaint);
    canvas.drawLine(nodePoints[1], nodePoints[4], linePaint);
    canvas.drawLine(nodePoints[2], nodePoints[5], linePaint);
    canvas.drawLine(nodePoints[3], nodePoints[4], linePaint);
    canvas.drawLine(nodePoints[3], nodePoints[5], linePaint);
    canvas.drawLine(nodePoints[4], nodePoints[6], linePaint);
    canvas.drawLine(nodePoints[5], nodePoints[7], linePaint);
    canvas.drawLine(nodePoints[6], nodePoints[7], linePaint);
    canvas.drawLine(nodePoints[6], nodePoints[8], linePaint);
    canvas.drawLine(nodePoints[7], nodePoints[8], linePaint);
    canvas.drawLine(nodePoints[3], nodePoints[8], linePaint);

    // Draw scanning grid nodes
    for (var pt in nodePoints) {
      canvas.drawCircle(pt, 4, nodePaint);
      canvas.drawCircle(pt, 8, Paint()..color = AppColors.neonBlue.withOpacity(0.2)..style = PaintingStyle.stroke);
    }

    // Floating radar sweeps
    final radarPaint = Paint()
      ..color = AppColors.neonPink.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 25),
      -0.8,
      1.6,
      false,
      radarPaint,
    );
  }

  void _drawMediaFolder(Canvas canvas, Size size, Offset center, double radius) {
    // Draw folder overlapping outlines
    final path1 = Path();
    path1.moveTo(center.dx - 50, center.dy - 30);
    path1.lineTo(center.dx - 10, center.dy - 30);
    path1.lineTo(center.dx, center.dy - 20);
    path1.lineTo(center.dx + 50, center.dy - 20);
    path1.lineTo(center.dx + 50, center.dy + 40);
    path1.lineTo(center.dx - 50, center.dy + 40);
    path1.close();

    final fillPaint = Paint()
      ..color = AppColors.neonBlue.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = AppColors.neonBlue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path1, fillPaint);
    canvas.drawPath(path1, strokePaint);

    // Draw floating widgets (Video / Audio emblems)
    final circlePaint = Paint()
      ..color = AppColors.neonPink.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final circleStroke = Paint()
      ..color = AppColors.neonPink
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Video bubble (bottom-left)
    final bubbleCenter = Offset(center.dx - 35, center.dy + 15);
    canvas.drawCircle(bubbleCenter, 22, circlePaint);
    canvas.drawCircle(bubbleCenter, 22, circleStroke);
    
    final videoPath = Path()
      ..moveTo(bubbleCenter.dx - 8, bubbleCenter.dy - 6)
      ..lineTo(bubbleCenter.dx + 4, bubbleCenter.dy)
      ..lineTo(bubbleCenter.dx - 8, bubbleCenter.dy + 6)
      ..close();
    canvas.drawPath(videoPath, Paint()..color = Colors.white..style = PaintingStyle.fill);

    // Audio soundwave indicator inside folder
    final soundWaveCenter = Offset(center.dx + 30, center.dy + 10);
    canvas.drawCircle(soundWaveCenter, 20, Paint()..color = AppColors.neonBlue.withOpacity(0.2)..style = PaintingStyle.fill);
    canvas.drawCircle(soundWaveCenter, 20, Paint()..color = AppColors.neonBlue..strokeWidth = 1.5..style = PaintingStyle.stroke);

    final audioPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(Offset(soundWaveCenter.dx - 6, soundWaveCenter.dy - 6), Offset(soundWaveCenter.dx - 6, soundWaveCenter.dy + 6), audioPaint);
    canvas.drawLine(Offset(soundWaveCenter.dx, soundWaveCenter.dy - 10), Offset(soundWaveCenter.dx, soundWaveCenter.dy + 10), audioPaint);
    canvas.drawLine(Offset(soundWaveCenter.dx + 6, soundWaveCenter.dy - 4), Offset(soundWaveCenter.dx + 6, soundWaveCenter.dy + 4), audioPaint);
  }

  void _drawSecurityShield(Canvas canvas, Size size, Offset center, double radius) {
    // Shield path
    final shieldPath = Path();
    shieldPath.moveTo(center.dx, center.dy - 55);
    shieldPath.quadraticBezierTo(center.dx + 45, center.dy - 50, center.dx + 45, center.dy - 10);
    shieldPath.quadraticBezierTo(center.dx + 45, center.dy + 35, center.dx, center.dy + 60);
    shieldPath.quadraticBezierTo(center.dx - 45, center.dy + 35, center.dx - 45, center.dy - 10);
    shieldPath.quadraticBezierTo(center.dx - 45, center.dy - 50, center.dx, center.dy - 55);
    shieldPath.close();

    final fillPaint = Paint()
      ..color = AppColors.electricViolet.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..shader = AppColors.primaryGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(shieldPath, fillPaint);
    canvas.drawPath(shieldPath, strokePaint);

    // Glowing Checkmark inside Shield
    final checkPaint = Paint()
      ..color = AppColors.successGreen
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final checkPath = Path()
      ..moveTo(center.dx - 16, center.dy - 2)
      ..lineTo(center.dx - 4, center.dy + 10)
      ..lineTo(center.dx + 18, center.dy - 12);
    canvas.drawPath(checkPath, checkPaint);

    // Star sparkles surrounding the shield
    final starPaint = Paint()
      ..color = AppColors.neonBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 60, center.dy - 35), 3, starPaint);
    canvas.drawCircle(Offset(center.dx + 65, center.dy + 25), 4, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
