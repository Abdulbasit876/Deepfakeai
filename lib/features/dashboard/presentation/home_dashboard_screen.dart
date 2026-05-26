import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/constants/app_assets.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/dashboard/presentation/widgets/custom_donut_chart.dart';
import 'package:deepfake_ai/features/analysis/presentation/processing_screen.dart';
import 'package:image_picker/image_picker.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _activeMediaTab = 0; // 0 = Image, 1 = Video, 2 = Audio

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110), // extra padding for floating nav bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Greeting Header Container
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Hello, Alex",
                        style: AppTextStyles.getHeadingMedium(isDark),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "👋",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Detect AI. Trust Reality.",
                    style: AppTextStyles.getBodyMedium(isDark),
                  ),
                ],
              ),

              // Glowing Premium Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "Premium",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Upload & Analyze Interactive Container
          GestureDetector(
            onTap: () async {
              XFile? file;
              if (_activeMediaTab == 1) {
                // Video selection
                file = await ImagePicker().pickVideo(source: ImageSource.gallery);
              } else {
                // Image selection
                file = await ImagePicker().pickImage(source: ImageSource.gallery);
              }
              if (file != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProcessingScreen(mediaType: _activeMediaTab),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.cardBg(isDark),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder(isDark), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.neonBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonBlue.withOpacity(0.3), width: 1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.neonBlue,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Upload & Analyze",
                    style: AppTextStyles.getHeadingSmall(isDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Drag & drop or tap to upload files",
                    style: AppTextStyles.getBodySmall(isDark),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Media Sub-Tabs Selector Grid
          Row(
            children: [
              Expanded(child: _buildMediaTab(0, "Image", Icons.image_rounded, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMediaTab(1, "Video", Icons.videocam_rounded, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMediaTab(2, "Audio", Icons.mic_rounded, isDark)),
            ],
          ),
          const SizedBox(height: 28),

          // AI Detection Overview Donut Card
          Text(
            "AI Detection Overview",
            style: AppTextStyles.getHeadingSmall(isDark),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder(isDark), width: 1.5),
            ),
            child: const CustomDonutChart(),
          ),
          const SizedBox(height: 28),

          // Bottom statistical summary grid counters
          Row(
            children: [
              Expanded(
                child: _buildStatCard("Total Scans", "128", Icons.analytics_outlined, AppColors.neonBlue, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard("Accuracy", "97.4%", Icons.verified_outlined, AppColors.successGreen, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab(int index, String label, IconData icon, bool isDark) {
    final isActive = _activeMediaTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeMediaTab = index;
        });
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? AppColors.neonBlue.withOpacity(0.12) : AppColors.cardBg(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.neonBlue : AppColors.cardBorder(isDark),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.neonBlue : AppColors.textSecondary(isDark),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.neonBlue : AppColors.textSecondary(isDark),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color iconColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder(isDark), width: 1),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
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
              const SizedBox(height: 4),
              Text(
                count,
                style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
