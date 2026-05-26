import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';

class EmptyErrorScreens extends StatelessWidget {
  final int stateIndex; // 0 = No History, 1 = No Notifications, 2 = Something Went Wrong, 3 = No Results Found
  final VoidCallback? onActionTap;

  const EmptyErrorScreens({
    Key? key,
    required this.stateIndex,
    this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Set configuration parameters based on state index
    IconData icon;
    Color color;
    String heading;
    String description;
    String? buttonText;

    if (stateIndex == 0) {
      icon = Icons.cloud_off_rounded;
      color = AppColors.neonBlue;
      heading = "No History Yet";
      description = "You haven't analyzed any content. Upload files to get started.";
      buttonText = "Upload Now";
    } else if (stateIndex == 1) {
      icon = Icons.notifications_none_rounded;
      color = AppColors.electricViolet;
      heading = "No Notifications";
      description = "You're all caught up! We will notify you when something happens.";
      buttonText = null;
    } else if (stateIndex == 2) {
      icon = Icons.smart_toy_outlined;
      color = AppColors.neonPink;
      heading = "Oops! Something Went Wrong";
      description = "We couldn't complete the request. Please check connection and try again.";
      buttonText = "Try Again";
    } else {
      icon = Icons.saved_search_rounded;
      color = AppColors.neonBlue;
      heading = "No Results Found";
      description = "Try adjusting your search terms or clear query filter tags.";
      buttonText = "Clear Filters";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing circular neon icon
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.12),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Heading Text
            Text(
              heading,
              textAlign: TextAlign.center,
              style: AppTextStyles.getHeadingSmall(isDark),
            ),
            const SizedBox(height: 10),

            // Description Text
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary(isDark).withOpacity(0.7),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Secondary Action Button (if any)
            if (buttonText != null)
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
