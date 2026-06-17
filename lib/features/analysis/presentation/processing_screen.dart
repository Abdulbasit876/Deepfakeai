import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // kIsWeb ke liye
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // XFile
import 'package:provider/provider.dart';

import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/analysis/presentation/result_screen.dart';
import 'package:deepfake_ai/providers/auth_provider.dart';

class ProcessingScreen extends StatefulWidget {
  final int mediaType;
  final XFile selectedFile; // ✅ File() ki jagah XFile — Web + Mobile dono support karta hai

  const ProcessingScreen({
    super.key,
    required this.mediaType,
    required this.selectedFile,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  double _scanProgress = 0.0;
  Timer? _progressTimer;
  late AnimationController _waveController;
  int _currentStepIndex = 0;
  late List<String> _checklistSteps;

  bool _isApiDone = false;
  Map<String, dynamic>? _apiResultData;

  // ✅ Backend URL — Web aur Mobile ke liye alag
  // Web: localhost seedha kaam karta hai
  // Android Emulator: 10.0.2.2
  // Real Device: apna PC ka WiFi IP (e.g. 192.168.1.5)
  String get _baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000/api/v1/detect";
    } else {
      // Android emulator ke liye 10.0.2.2, real device ke liye apna IP
      return "http://192.168.137.84:5000/api/v1/detect";
    }
  }

  @override
  void initState() {
    super.initState();

    _waveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();

    if (widget.mediaType == 0) {
      _checklistSteps = ["Scanning pixels", "Detecting patterns", "Comparing database", "Finalizing results"];
    } else if (widget.mediaType == 1) {
      _checklistSteps = ["Extracting frames", "Analyzing frames", "Checking inconsistencies", "Finalizing results"];
    } else {
      _checklistSteps = ["Reading waveform", "Analyzing frequency", "Matching patterns", "Finalizing results"];
    }

    _startProgressSimulation();
    WidgetsBinding.instance.addPostFrameCallback((_) => _uploadAndAnalyzeMedia());
  }

  // ✅ MAIN FIX: XFile se bytes read karke multipart request bhejna
  // Yeh Web + Mobile dono pe kaam karta hai
  Future<void> _uploadAndAnalyzeMedia() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.session?.accessToken;

      if (token == null) {
        _handleFailure("Session expired. Please log in again.");
        return;
      }

      // Endpoint mediaType ke hisaab se
      String endpoint;
      String fieldName;
      if (widget.mediaType == 0) {
        endpoint = "$_baseUrl/image";
        fieldName = "image";
      } else if (widget.mediaType == 1) {
        endpoint = "$_baseUrl/video";
        fieldName = "video";
      } else {
        endpoint = "$_baseUrl/audio";
        fieldName = "audio";
      }

      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest("POST", uri);

      // Auth header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // ✅ XFile se bytes padhna — Web + Mobile dono pe kaam karta hai
      final bytes = await widget.selectedFile.readAsBytes();
      final fileName = widget.selectedFile.name;

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: fileName,
        ),
      );

      print('API Request URL: $uri');
      print('API Request field: $fieldName, filename: $fileName');
      // Request bhejo
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 180), // Video ke liye zyada time
        onTimeout: () {
          throw TimeoutException("Server ne response nahi diya.");
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
       print("API Response Status: ${response.statusCode}");
       print("API Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          if (!mounted) return;
          setState(() {
            // ✅ data + media_url dono merge karke pass karo
            _apiResultData = {
              ...jsonResponse['data'],
              'media_url': jsonResponse['media_url'],
            };
            _isApiDone = true;
          });
        } else {
          _handleFailure(jsonResponse['error'] ?? "Detection failed on server.");
        }
      } else {
        _handleFailure("Server Error ${response.statusCode}: ${response.body}");
      }
    } on TimeoutException {
      _handleFailure("Timeout: Server se connection nahi hua.");
    } catch (e) {
      // ✅ Exact error print karo — F12 Console mein dekho
      debugPrint("❌ API Error: $e");
      _handleFailure("Connection error: $e");
    }
  }

  void _startProgressSimulation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) return;
      setState(() {
        if (_scanProgress < 0.90) {
          _scanProgress += 0.01;
          _updateChecklistIndex();
        } else if (_isApiDone && _scanProgress < 1.0) {
          _scanProgress += 0.02;
          _updateChecklistIndex();
        } else if (_scanProgress >= 1.0) {
          _progressTimer?.cancel();
          _navigateToResult();
        }
      });
    });
  }

  void _updateChecklistIndex() {
    if (_scanProgress >= 0.75) {
      _currentStepIndex = 3;
    } else if (_scanProgress >= 0.50) {
      _currentStepIndex = 2;
    } else if (_scanProgress >= 0.25) {
      _currentStepIndex = 1;
    } else {
      _currentStepIndex = 0;
    }
  }

  void _handleFailure(String errorMsg) {
    _progressTimer?.cancel();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $errorMsg"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToResult() {
    if (_apiResultData == null) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ResultScreen(mediaType: widget.mediaType, resultData: _apiResultData!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaLabel = widget.mediaType == 0 ? "Image" : (widget.mediaType == 1 ? "Video" : "Audio");

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient(isDark)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 40, width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg(isDark),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardBorder(isDark)),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Text("Analyzing $mediaLabel", style: AppTextStyles.getHeadingMedium(isDark)),
                const SizedBox(height: 6),
                Text(
                  widget.mediaType == 0
                      ? "Our AI is scanning the image pixels..."
                      : (widget.mediaType == 1 ? "Scanning frames sequence..." : "Processing audio waveforms..."),
                  style: AppTextStyles.getBodyMedium(isDark),
                ),
                const SizedBox(height: 36),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Scanning Progress", style: AppTextStyles.getLabelMedium(isDark)),
                    Text(
                      "${(_scanProgress * 100).toInt()}%",
                      style: const TextStyle(color: AppColors.neonBlue, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 6, width: double.infinity,
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
                Column(
                  children: List.generate(
                    _checklistSteps.length,
                    (index) => _buildChecklistItem(index, isDark),
                  ),
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
      iconColor = AppColors.textSecondary(isDark).withOpacity(0.4);
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
                  : (isCurrent ? AppColors.neonBlue : AppColors.textSecondary(isDark).withOpacity(0.5)),
              fontSize: 14,
              fontWeight: isCurrent || isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Painter (unchanged) ----
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

    final laserY = size.height * progress;
    final laserPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, AppColors.neonBlue, Colors.transparent],
      ).createShader(Rect.fromLTRB(0, laserY - 10, size.width, laserY + 10))
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, laserY), Offset(size.width, laserY), laserPaint);

    final glowPaint = Paint()
      ..color = AppColors.neonBlue.withOpacity(0.12)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRect(Rect.fromLTRB(0, laserY - 14, size.width, laserY + 14), glowPaint);
  }

  void _paintFaceScan(Canvas canvas, Size size, Offset center) {
    final facePaint = Paint()
      ..color = AppColors.neonBlue.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), facePaint);
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), facePaint);
    }

    final path = Path();
    path.moveTo(center.dx, center.dy - 100);
    path.quadraticBezierTo(center.dx + 70, center.dy - 90, center.dx + 70, center.dy - 30);
    path.quadraticBezierTo(center.dx + 80, center.dy + 20, center.dx + 40, center.dy + 70);
    path.quadraticBezierTo(center.dx + 25, center.dy + 95, center.dx, center.dy + 100);
    path.quadraticBezierTo(center.dx - 25, center.dy + 95, center.dx - 40, center.dy + 70);
    path.quadraticBezierTo(center.dx - 80, center.dy + 20, center.dx - 70, center.dy - 30);
    path.quadraticBezierTo(center.dx - 70, center.dy - 90, center.dx, center.dy - 100);
    path.close();

    final outlinePaint = Paint()
      ..color = AppColors.neonBlue.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, outlinePaint);

    final ptPaint = Paint()..color = AppColors.neonPink..style = PaintingStyle.fill;
    final nodesScale = 1.0 + 0.15 * sin(animationValue * 2 * pi);
    canvas.drawCircle(Offset(center.dx - 25, center.dy - 20), 4 * nodesScale, ptPaint);
    canvas.drawCircle(Offset(center.dx + 25, center.dy - 20), 4 * nodesScale, ptPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 10), 3 * nodesScale, ptPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 45), 4 * nodesScale, ptPaint);
  }

  void _paintVideoTimeline(Canvas canvas, Size size, Offset center) {
    final stripPaint = Paint()
      ..color = AppColors.cardBorder(isDark)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final stripHeight = size.height * 0.4;
    final topY = center.dy - stripHeight / 2;
    final bottomY = center.dy + stripHeight / 2;

    canvas.drawLine(Offset(0, topY), Offset(size.width, topY), stripPaint);
    canvas.drawLine(Offset(0, bottomY), Offset(size.width, bottomY), stripPaint);

    final sprocketPaint = Paint()
      ..color = AppColors.textSecondary(isDark).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    for (double x = 10; x < size.width; x += 25) {
      canvas.drawRect(Rect.fromLTWH(x, topY + 4, 12, 10), sprocketPaint);
      canvas.drawRect(Rect.fromLTWH(x, bottomY - 14, 12, 10), sprocketPaint);
    }

    final checkLens = Paint()..color = AppColors.neonPink.withOpacity(0.1)..style = PaintingStyle.fill;
    final checkLensStroke = Paint()..color = AppColors.neonPink..strokeWidth = 2..style = PaintingStyle.stroke;
    final shiftX = animationValue * (size.width - 120);
    final frameRect = Rect.fromLTWH(shiftX, topY + 20, 110, stripHeight - 40);

    canvas.drawRect(frameRect, checkLens);
    canvas.drawRect(frameRect, checkLensStroke);

    final gridPaint = Paint()..color = AppColors.neonPink.withOpacity(0.3)..strokeWidth = 1;
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
    final wavePath = Path();
    wavePath.moveTo(0, center.dy);

    const int barCount = 48;
    final double barSpacing = size.width / barCount;
    for (int i = 0; i <= barCount; i++) {
      final double x = i * barSpacing;
      final amplitudeMultiplier = sin(i * 0.4 + animationValue * 2 * pi);
      final envelope = sin((i / barCount) * pi);
      final height = 75 * amplitudeMultiplier * envelope;
      wavePath.lineTo(x, center.dy + height);
    }
    canvas.drawPath(wavePath, wavePaint);

    final ptPaint = Paint()..color = AppColors.neonPink..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 50, center.dy + 35 * sin(animationValue * 2 * pi)), 4, ptPaint);
    canvas.drawCircle(Offset(center.dx + 60, center.dy + 25 * cos(animationValue * 2 * pi)), 5, ptPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerVisualizerPainter oldDelegate) => true;
}