import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/shared/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultScreen extends StatelessWidget {
  final int mediaType;
  final Map<String, dynamic> resultData;

  const ResultScreen({
    super.key,
    required this.mediaType,
    required this.resultData,
  });

  double get _aiPercentage =>
      (resultData['ai_percentage'] ?? 0.0).toDouble();
  double get _humanPercentage =>
      (resultData['human_percentage'] ?? 0.0).toDouble();
  String get _detectedSource =>
      resultData['detected_source'] ?? 'Unknown';
  String? get _mediaUrl => resultData['media_url'] as String?;

  String get _verdict {
    if (_aiPercentage >= 70) return "Likely AI Generated";
    if (_aiPercentage >= 40) return "Possibly AI Generated";
    return "Likely Authentic";
  }

  String get _riskLevel {
    if (_aiPercentage >= 70) return "High Risk";
    if (_aiPercentage >= 40) return "Medium Risk";
    return "Low Risk";
  }

  Color get _verdictColor {
    if (_aiPercentage >= 70) return AppColors.neonPink;
    if (_aiPercentage >= 40) return Colors.orange;
    return AppColors.successGreen;
  }

  String _getExplanation(String mediaLabel) {
    if (_aiPercentage >= 70) {
      return "Our AI scanned multiple complex patterns across the uploaded $mediaLabel file. "
          "We detected synthetic texture inconsistencies and structural lighting imbalances "
          "that strongly deviate from authentic patterns, suggesting a ${_aiPercentage.toStringAsFixed(1)}% likelihood of deepfake alteration"
          "${_detectedSource != 'Unknown' ? ' (Source: $_detectedSource)' : ''}.";
    } else if (_aiPercentage >= 40) {
      return "Our AI found some patterns in the uploaded $mediaLabel that may suggest partial AI involvement. "
          "The analysis shows ${_aiPercentage.toStringAsFixed(1)}% AI-generated likelihood, "
          "which falls in an ambiguous range. Further verification is recommended.";
    } else {
      return "Our AI analyzed the uploaded $mediaLabel and found no significant signs of artificial generation. "
          "The content appears authentic with only ${_aiPercentage.toStringAsFixed(1)}% AI-generated likelihood.";
    }
  }

  Future<void> _saveToDatabase(BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) throw "User not logged in!";

      await supabase.from('detection_reports').insert({
        'user_id': user.id,
        'media_type': mediaType.toString(),
        'media_url': _mediaUrl ?? '',
        'ai_percentage': _aiPercentage,
        'human_percentage': _humanPercentage,
        'detected_source': _detectedSource,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Scan successfully saved to History!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _downloadReport(BuildContext context) async {
    try {
      final mediaLabel =
          mediaType == 0 ? "Image" : (mediaType == 1 ? "Video" : "Audio");

      // PDF document banao
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                "AI Detection Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Text("Media Type: $mediaLabel",
                style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Text("Verdict: $_verdict",
                style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Text("Risk Level: $_riskLevel",
                style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Text(
              "AI Generated: ${_aiPercentage.toStringAsFixed(1)}%",
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              "Human / Realistic: ${_humanPercentage.toStringAsFixed(1)}%",
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text("Detected Source: $_detectedSource",
                style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Text(
              "AI Explanation",
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              _getExplanation(mediaLabel),
              style: const pw.TextStyle(fontSize: 13, lineSpacing: 4),
            ),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text(
              "Generated On: ${DateTime.now().toLocal()}",
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();
      final fileName =
          "AI_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";

      String savePath;

      if (Platform.isAndroid) {
        // Android: seedha Downloads folder mein save karo
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        savePath = '${downloadsDir.path}/$fileName';
      } else {
        // iOS: Documents folder mein save karo
        final docsDir = await getApplicationDocumentsDirectory();
        savePath = '${docsDir.path}/$fileName';
      }

      final file = File(savePath);
      await file.writeAsBytes(pdfBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Platform.isAndroid
                  ? "PDF saved to Downloads: $fileName"
                  : "PDF saved: $fileName",
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fileName = mediaType == 0
        ? "portrait_photo.jpg"
        : (mediaType == 1 ? "interview_clip.mp4" : "voice_note.wav");
    final fileSize = mediaType == 0
        ? "2.4 MB"
        : (mediaType == 1 ? "18.6 MB" : "1.2 MB");
    final fileDate = "12 May 2026";
    final mediaLabel =
        mediaType == 0 ? "Image" : (mediaType == 1 ? "Video" : "Audio");

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.bgGradient(isDark),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.cardBg(isDark),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.cardBorder(isDark)),
                        ),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Colors.white),
                      ),
                    ),
                    Text(
                      "Result",
                      style: AppTextStyles.getHeadingSmall(isDark),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg(isDark),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.cardBorder(isDark)),
                      ),
                      child: const Icon(Icons.share_rounded,
                          size: 18, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg(isDark),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.cardBorder(isDark)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: mediaType == 2
                            ? Container(
                                height: 64,
                                width: 64,
                                color: AppColors.neonPink
                                    .withValues(alpha: 0.1),
                                child: const Icon(
                                    Icons.audiotrack_rounded,
                                    color: AppColors.neonPink,
                                    size: 28),
                              )
                            : (_mediaUrl != null
                                ? Image.network(
                                    _mediaUrl!,
                                    height: 64,
                                    width: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => Container(
                                      height: 64,
                                      width: 64,
                                      color: AppColors.neonBlue,
                                      child: const Icon(Icons.image,
                                          color: Colors.white),
                                    ),
                                  )
                                : Container(
                                    height: 64,
                                    width: 64,
                                    color: AppColors.neonBlue,
                                    child: const Icon(Icons.image,
                                        color: Colors.white),
                                  )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neonBlue
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                mediaLabel,
                                style: const TextStyle(
                                  color: AppColors.neonBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              fileName,
                              style: TextStyle(
                                color: AppColors.textPrimary(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$fileSize • $fileDate",
                              style: AppTextStyles.getBodySmall(isDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _verdictColor.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: _verdictColor.withValues(alpha: 0.2),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _verdictColor.withValues(alpha: 0.04),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          _verdict,
                          style: TextStyle(
                            color: _verdictColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "${_aiPercentage.toStringAsFixed(1)}%",
                                  style: TextStyle(
                                    color: _verdictColor,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "AI Generated",
                                  style:
                                      AppTextStyles.getBodySmall(isDark),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.accentGradient,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 1.5,
                            color: AppColors.cardBorder(isDark),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 24),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "${_humanPercentage.toStringAsFixed(1)}%",
                                  style: const TextStyle(
                                    color: AppColors.successGreen,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Realistic",
                                  style:
                                      AppTextStyles.getBodySmall(isDark),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.successGreen,
                                        AppColors.neonBlue
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _buildTelemetryCard(
                        "Risk Level",
                        _riskLevel,
                        _verdictColor,
                        true,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTelemetryCard(
                        "Confidence Score",
                        "${_aiPercentage.toStringAsFixed(1)}%",
                        AppColors.neonBlue,
                        false,
                        isDark,
                        widthFactor: _aiPercentage / 100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Text(
                  "AI Explanation",
                  style: AppTextStyles.getHeadingSmall(isDark),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg(isDark),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.cardBorder(isDark)),
                  ),
                  child: Text(
                    _getExplanation(mediaLabel),
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: "Download Report",
                        onTap: () => _downloadReport(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Save",
                        isSecondary: true,
                        onTap: () => _saveToDatabase(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryCard(String label, String value, Color color,
      bool isRisk, bool isDark,
      {double widthFactor = 0.89}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          isRisk
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder(isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor:
                                widthFactor.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}