import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/dashboard/presentation/widgets/custom_donut_chart.dart';
import 'package:deepfake_ai/features/analysis/presentation/processing_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});
  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _activeMediaTab = 0; // 0 = Image, 1 = Video, 2 = Audio

  // ✅ Web + Mobile dono ke liye XFile use kiya — File() nahi
  Future<void> _onUploadTap() async {
    XFile? pickedFile;

    if (_activeMediaTab == 1) {
      // Video
      pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    } else if (_activeMediaTab == 0) {
      // Image
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    } else if (_activeMediaTab == 2) {
      // Audio
      // Request permissions first on Android
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Storage permission is required to pick audio files."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        pickedFile = XFile(result.files.first.path!);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to pick audio file. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }
    if (pickedFile != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcessingScreen(
            mediaType: _activeMediaTab,
            selectedFile: pickedFile!, // ✅ XFile directly pass — File() nahi
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Hello, Alex", style: AppTextStyles.getHeadingMedium(isDark)),
                      const SizedBox(width: 6),
                      const Text("👋", style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("Detect AI. Trust Reality.", style: AppTextStyles.getBodyMedium(isDark)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.neonBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text("Premium", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Upload Card
          GestureDetector(
            onTap: _onUploadTap, // ✅ Clean function call
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.cardBg(isDark),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder(isDark), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.neonBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.3), width: 1),
                    ),
                    child: const Center(child: Icon(Icons.cloud_upload_outlined, color: AppColors.neonBlue, size: 32)),
                  ),
                  const SizedBox(height: 18),
                  Text("Upload & Analyze", style: AppTextStyles.getHeadingSmall(isDark)),
                  const SizedBox(height: 6),
                  Text("Drag & drop or tap to upload files", style: AppTextStyles.getBodySmall(isDark)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Media Tabs
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

          // Donut Chart
          Text("AI Detection Overview", style: AppTextStyles.getHeadingSmall(isDark)),
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

          // Stats
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Scans", "128", Icons.analytics_outlined, AppColors.neonBlue, isDark)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Accuracy", "97.4%", Icons.verified_outlined, AppColors.successGreen, isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab(int index, String label, IconData icon, bool isDark) {
    final isActive = _activeMediaTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeMediaTab = index),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? AppColors.neonBlue.withValues(alpha: 0.12) : AppColors.cardBg(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? AppColors.neonBlue : AppColors.cardBorder(isDark), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? AppColors.neonBlue : AppColors.textSecondary(isDark), size: 18),
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
            height: 40, width: 40,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppColors.textSecondary(isDark), fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(count, style: TextStyle(color: AppColors.textPrimary(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}