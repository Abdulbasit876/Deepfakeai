import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/constants/app_assets.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/shared/widgets/custom_button.dart';

class ResultScreen extends StatelessWidget {
  final int mediaType; // 0 = Image, 1 = Video, 2 = Audio

  const ResultScreen({super.key, required this.mediaType});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final fileName = mediaType == 0 
        ? "portrait_photo.jpg" 
        : (mediaType == 1 ? "interview_clip.mp4" : "voice_note.wav");
    
    final fileSize = mediaType == 0 ? "2.4 MB" : (mediaType == 1 ? "18.6 MB" : "1.2 MB");
    final fileDate = "12 May 2026";
    final mediaLabel = mediaType == 0 ? "Image" : (mediaType == 1 ? "Video" : "Audio");

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.bgGradient(isDark),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header back action and Share link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.cardBg(isDark),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder(isDark)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
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
                        border: Border.all(color: AppColors.cardBorder(isDark)),
                      ),
                      child: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Profile-header media preview box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg(isDark),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder(isDark)),
                  ),
                  child: Row(
                    children: [
                      // Circular / Rounded Media preview thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: mediaType == 2
                            ? Container(
                                height: 64,
                                width: 64,
                                color: AppColors.neonPink.withValues(alpha: 0.1),
                                child: const Icon(Icons.audiotrack_rounded, color: AppColors.neonPink, size: 28),
                              )
                            : Image.network(
                                mediaType == 0 ? AppAssets.mediaFacePreview : AppAssets.mediaPreviewVideo,
                                height: 64,
                                width: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(
                                  height: 64,
                                  width: 64,
                                  color: AppColors.neonBlue,
                                  child: const Icon(Icons.image, color: Colors.white),
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Meta details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neonBlue.withValues(alpha: 0.12),
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

                // High-fidelity Side-by-side color-coded percentage metrics bars
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.neonPink.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.neonPink.withValues(alpha: 0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPink.withValues(alpha: 0.04),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          "Likely AI Generated",
                          style: TextStyle(
                            color: AppColors.neonPink,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Duel Percentage Gauges Side-by-Side
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "62%",
                                  style: TextStyle(
                                    color: AppColors.neonPink,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "AI Generated",
                                  style: AppTextStyles.getBodySmall(isDark),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.accentGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 1.5,
                            color: AppColors.cardBorder(isDark),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "38%",
                                  style: TextStyle(
                                    color: AppColors.successGreen,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Realistic",
                                  style: AppTextStyles.getBodySmall(isDark),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.successGreen, AppColors.neonBlue],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
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

                // Explicit Risk Level and Confidence telemetry readouts
                Row(
                  children: [
                    Expanded(
                      child: _buildTelemetryCard(
                        "Risk Level",
                        "High Risk",
                        AppColors.neonPink,
                        true,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTelemetryCard(
                        "Confidence Score",
                        "89%",
                        AppColors.neonBlue,
                        false,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // AI Explanation Card
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
                    border: Border.all(color: AppColors.cardBorder(isDark)),
                  ),
                  child: Text(
                    "Our AI scanned multiple complex patterns across the uploaded $mediaLabel file. "
                    "We detected synthetic texture inconsistencies and structural lighting imbalances "
                    "that strongly deviate from authentic patterns, suggesting a 62% likelihood of deepfake alteration.",
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Bottom Action buttons row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: "Download Report",
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("PDF Report downloaded successfully!"),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Save",
                        isSecondary: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Scan successfully saved to History!"),
                              backgroundColor: AppColors.neonBlue,
                            ),
                          );
                        },
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

  Widget _buildTelemetryCard(String label, String value, Color color, bool isRisk, bool isDark) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                            widthFactor: 0.89,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
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
