import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/constants/app_assets.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/features/auth/presentation/login_screen.dart';
import 'package:deepfake_ai/main.dart'; 
import 'package:deepfake_ai/features/premium/presentation/premium_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Supabase se current user fetch kiya
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? "Alex Johnson";
    final userEmail = user?.email ?? "alex.johnson@gmail.com";

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110), // padding for bottom nav
      child: Column(
        children: [
          // Header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Profile",
              style: AppTextStyles.getHeadingMedium(isDark),
            ),
          ),
          const SizedBox(height: 24),

          // User details card with Avatar and Premium badge
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder(isDark), width: 1.5),
            ),
            child: Row(
              children: [
                // Avatar with glowing ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      AppAssets.userProfileMale,
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(
                        height: 64,
                        width: 64,
                        color: AppColors.neonBlue,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),

                // User name and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName, // Dynamic Name
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail, // Dynamic Email
                        style: AppTextStyles.getBodySmall(isDark),
                      ),
                      const SizedBox(height: 8),

                      // Premium Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.electricViolet.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.electricViolet.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          "Premium User",
                          style: TextStyle(
                            color: AppColors.electricViolet,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Settings list
          _buildSettingsTile(
            Icons.manage_accounts_outlined,
            "Account Settings",
            null,
            () {},
            isDark,
          ),
          _buildSettingsTile(
            Icons.star_outline_rounded,
            "Subscription",
            null,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PremiumScreen()),
              );
            },
            isDark,
          ),
          _buildSettingsTile(
            Icons.tune_rounded,
            "Preferences",
            null,
            () {},
            isDark,
          ),
          
          // Appearance theme toggle switcher
          _buildSettingsTile(
            Icons.dark_mode_outlined,
            "Appearance",
            Switch(
              value: isDark,
              activeThumbColor: AppColors.neonBlue,
              onChanged: (value) {
                // Toggle the theme mode
                themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            null,
            isDark,
          ),

          _buildSettingsTile(
            Icons.language_rounded,
            "Language",
            const Text(
              "English",
              style: TextStyle(color: AppColors.neonBlue, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            () {},
            isDark,
          ),
          _buildSettingsTile(
            Icons.help_outline_rounded,
            "Help & Support",
            null,
            () {},
            isDark,
          ),
          const SizedBox(height: 32),

          // Logout Button
          GestureDetector(
            onTap: () async {
              // Supabase Logout
              await Supabase.instance.client.auth.signOut();
              // Navigate to login screen and clear navigation stack
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neonPink.withValues(alpha: 0.3), width: 1.5),
                color: AppColors.neonPink.withValues(alpha: 0.04),
              ),
              child: const Center(
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: AppColors.neonPink,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData leadingIcon,
    String title,
    Widget? trailingWidget,
    VoidCallback? onTap,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(isDark)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: AppColors.textSecondary(isDark).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(leadingIcon, color: AppColors.textSecondary(isDark), size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailingWidget ?? 
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white24,
            ),
      ),
    );
  }
}