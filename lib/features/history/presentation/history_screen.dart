import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/constants/app_assets.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/status_states/presentation/empty_error_screens.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<HistoryItem> _items = [];

  final List<HistoryItem> _mockItems = [
    HistoryItem(
      fileName: "portrait_photo.jpg",
      mediaType: 0,
      timestamp: "12 May 2026",
      aiPercent: 62,
      realPercent: 38,
      imageUrl: AppAssets.mediaFacePreview,
    ),
    HistoryItem(
      fileName: "video_interview.mp4",
      mediaType: 1,
      timestamp: "11 May 2026",
      aiPercent: 28,
      realPercent: 72,
      imageUrl: AppAssets.mediaPreviewVideo,
    ),
    HistoryItem(
      fileName: "voice_recording.wav",
      mediaType: 2,
      timestamp: "10 May 2026",
      aiPercent: 45,
      realPercent: 55,
      imageUrl: "",
    ),
    HistoryItem(
      fileName: "group_photo.jpg",
      mediaType: 0,
      timestamp: "09 May 2026",
      aiPercent: 12,
      realPercent: 88,
      imageUrl: AppAssets.mediaFacePreview,
    ),
    HistoryItem(
      fileName: "event_video.mp4",
      mediaType: 1,
      timestamp: "08 May 2026",
      aiPercent: 34,
      realPercent: 66,
      imageUrl: AppAssets.mediaPreviewVideo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _items = List.from(_mockItems);
  }

  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _items = List.from(_mockItems);
      } else {
        _items = _mockItems
            .where((item) => item.fileName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "History",
                style: AppTextStyles.getHeadingMedium(isDark),
              ),
              const SizedBox(height: 16),

              // Search Bar & Filter Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg(isDark),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterSearch,
                        style: TextStyle(color: AppColors.textPrimary(isDark), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Search history...",
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary(isDark).withValues(alpha: 0.6),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.cardBorder(isDark)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.cardBorder(isDark)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.neonBlue, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter trigger leading to empty state preview
                  GestureDetector(
                    onTap: () {
                      // Trigger clean state display by clearing list
                      setState(() {
                        _items.clear();
                      });
                    },
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg(isDark),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder(isDark)),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.neonBlue,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // List item cards
        Expanded(
          child: _items.isEmpty
              ? EmptyErrorScreens(
                  stateIndex: 0, // No History state index
                  onActionTap: () {
                    setState(() {
                      _items = List.from(_mockItems);
                    });
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(_items[index], isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(HistoryItem item, bool isDark) {
    final mediaLabel = item.mediaType == 0 ? "Image" : (item.mediaType == 1 ? "Video" : "Audio");

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder(isDark)),
      ),
      child: Row(
        children: [
          // Media Thumbnail preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.mediaType == 2
                ? Container(
                    height: 54,
                    width: 54,
                    color: AppColors.neonPink.withValues(alpha: 0.1),
                    child: const Icon(Icons.audiotrack_rounded, color: AppColors.neonPink, size: 22),
                  )
                : Image.network(
                    item.imageUrl,
                    height: 54,
                    width: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(
                      height: 54,
                      width: 54,
                      color: AppColors.neonBlue,
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // File meta details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName,
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$mediaLabel • ${item.timestamp}",
                  style: AppTextStyles.getBodySmall(isDark),
                ),
              ],
            ),
          ),

          // Confidence scores alignment
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.aiPercent}% AI",
                style: const TextStyle(
                  color: AppColors.neonPink,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${item.realPercent}% Real",
                style: const TextStyle(
                  color: AppColors.successGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HistoryItem {
  final String fileName;
  final int mediaType;
  final String timestamp;
  final int aiPercent;
  final int realPercent;
  final String imageUrl;

  HistoryItem({
    required this.fileName,
    required this.mediaType,
    required this.timestamp,
    required this.aiPercent,
    required this.realPercent,
    required this.imageUrl,
  });
}
