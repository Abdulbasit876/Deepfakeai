import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/shared/widgets/custom_button.dart';
import 'package:deepfake_ai/shared/widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.bgGradient(isDark),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
                const SizedBox(height: 36),

                Text(
                  "Forgot Password",
                  style: AppTextStyles.getHeadingLarge(isDark).copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your registered email address and we'll send you reset instructions.",
                  style: AppTextStyles.getBodyMedium(isDark),
                ),
                const SizedBox(height: 48),

                // High-Tech glowing mail emblem in center
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.neonPink.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonPink.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPink.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.mail_lock_rounded,
                        color: AppColors.neonPink,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Form items
                CustomTextField(
                  hintText: "Email or Phone",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 36),

                // Action CTA
                CustomButton(
                  text: "Send Reset Link",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Reset link dispatched to your email!"),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 36),

                // Back to Login link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Back to Login",
                      style: TextStyle(
                        color: AppColors.neonBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
