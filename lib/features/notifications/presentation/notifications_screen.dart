import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/status_states/presentation/empty_error_screens.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];

  final List<NotificationItem> _mockNotifications = [
    NotificationItem(
      title: "Scan Completed",
      description: "portrait_photo.jpg: Analysis completed successfully.",
      timestamp: "2m ago",
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.successGreen,
    ),
    NotificationItem(
      title: "Report Saved",
      description: "deepfake_report.pdf has been saved successfully.",
      timestamp: "10m ago",
      icon: Icons.article_outlined,
      color: AppColors.neonBlue,
    ),
    NotificationItem(
      title: "Subscription Updated",
      description: "You are now a Premium user. Enjoy unlimited features!",
      timestamp: "1h ago",
      icon: Icons.stars_rounded,
      color: AppColors.electricViolet,
    ),
    NotificationItem(
      title: "Scan Completed",
      description: "video_interview.mp4: Analysis completed successfully.",
      timestamp: "2h ago",
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.successGreen,
    ),
    NotificationItem(
      title: "New Feature Available",
      description: "Check out our new AI detection engine. Accuracy increased by 4.2%.",
      timestamp: "1d ago",
      icon: Icons.rocket_launch_outlined,
      color: AppColors.neonPink,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _notifications = List.from(_mockNotifications);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Notifications",
                style: AppTextStyles.getHeadingMedium(isDark),
              ),
              if (_notifications.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    // Trigger Empty State Preview
                    setState(() {
                      _notifications.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neonPink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Clear All",
                      style: TextStyle(
                        color: AppColors.neonPink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Notifications List or Empty notifications state
        Expanded(
          child: _notifications.isEmpty
              ? EmptyErrorScreens(
                  stateIndex: 1, // No Notifications state index
                  onActionTap: () {
                    setState(() {
                      _notifications = List.from(_mockNotifications);
                    });
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(_notifications[index], isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 14),

          // Notification texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.timestamp,
                      style: AppTextStyles.getLabelSmall(isDark).copyWith(
                        color: AppColors.textSecondary(isDark).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String description;
  final String timestamp;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}
