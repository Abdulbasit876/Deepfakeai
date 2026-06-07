import 'package:flutter/material.dart';
import 'dart:async';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/splash_onboarding/presentation/onboarding_screen.dart';
import 'package:deepfake_ai/features/auth/presentation/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:deepfake_ai/providers/auth_provider.dart';
import 'package:deepfake_ai/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _loadProgress = 0.0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for the glowing logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate loading progress
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_loadProgress < 1.0) {
          _loadProgress += 0.01;
        } else {
          _timer?.cancel();
          _navigateToNext();
        }
      });
    });
  }

  Future<void> _navigateToNext() async {
    final auth = context.read<AuthProvider>();
    
    // Check if session has expired
    await auth.checkSessionExpiry();

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainAppContainer(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              hasSeenOnboarding ? const LoginScreen() : const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
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
          child: Stack(
            children: [
              // Cosmic background glows
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.neonBlue.withValues(alpha: isDark ? 0.25 : 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.neonPink.withValues(alpha: isDark ? 0.25 : 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Central Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing logo emblem using CustomPainter
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                      ),
                      child: CustomPaint(
                        size: const Size(160, 160),
                        painter: LogoGlowPainter(isDark: isDark),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      "DeepFake AI",
                      style: AppTextStyles.getHeadingLarge(isDark).copyWith(
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: AppColors.neonBlue.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "AI-Powered Deepfake Detection",
                      style: AppTextStyles.getBodyMedium(isDark).copyWith(
                        color: AppColors.textSecondary(isDark).withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Loading Progress
              Positioned(
                bottom: 60,
                left: 40,
                right: 40,
                child: Column(
                  children: [
                    // Loading bar
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
                            widthFactor: _loadProgress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonBlue.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Loading...",
                      style: AppTextStyles.getLabelSmall(isDark).copyWith(
                        color: AppColors.textSecondary(isDark).withValues(alpha: 0.6),
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
}

// Custom Painter to paint a high-fidelity glowing DF emblem
class LogoGlowPainter extends CustomPainter {
  final bool isDark;
  LogoGlowPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Glowing Neon Blue aura
    final auraPaint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: isDark ? 0.25 : 0.1)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(center, radius - 10, auraPaint);

    // Glowing Pink outer boundary glow
    final neonPinkPaint = Paint()
      ..color = AppColors.neonPink.withValues(alpha: isDark ? 0.2 : 0.08)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius - 20, neonPinkPaint);

    // Circular gradient ring border
    final rect = Rect.fromCircle(center: center, radius: radius - 15);
    const gradient = SweepGradient(
      colors: [AppColors.neonBlue, AppColors.electricViolet, AppColors.neonPink, AppColors.neonBlue],
      stops: [0.0, 0.35, 0.7, 1.0],
    );
    final ringPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 15, ringPaint);

    // Dynamic inner circuit points
    final pointPaint = Paint()
      ..color = AppColors.neonBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, center.dy - radius + 15), 4, pointPaint);
    canvas.drawCircle(Offset(center.dx + radius - 15, center.dy), 4, pointPaint);

    // Text "DF" painting in the center
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'DF',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
