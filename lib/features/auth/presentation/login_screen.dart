import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/shared/widgets/custom_button.dart';
import 'package:deepfake_ai/shared/widgets/custom_textfield.dart';
import 'package:deepfake_ai/features/auth/presentation/signup_screen.dart';
import 'package:deepfake_ai/features/auth/presentation/forgot_password_screen.dart';
import 'package:deepfake_ai/main.dart'; // Navigation context

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                const SizedBox(height: 20),
                // Heading area
                Text(
                  "Welcome Back",
                  style: AppTextStyles.getHeadingLarge(isDark).copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  "Login to continue scanning files and detecting AI anomalies.",
                  style: AppTextStyles.getBodyMedium(isDark),
                ),
                const SizedBox(height: 48),

                // Form elements
                CustomTextField(
                  hintText: "Email or Phone",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: "Password",
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 14),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppColors.neonBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Login action button
                CustomButton(
                  text: "Login",
                  onTap: () {
                    // Navigate to primary shell (main App container which mounts bottom nav bar)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainAppContainer()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 36),

                // Or divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.cardBorder(isDark))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "or continue with",
                        style: TextStyle(
                          color: AppColors.textSecondary(isDark).withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.cardBorder(isDark))),
                  ],
                ),
                const SizedBox(height: 32),

                // Social authentications buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(Icons.g_mobiledata_rounded, Colors.red, isDark),
                    const SizedBox(width: 24),
                    _buildSocialButton(Icons.apple, Colors.white, isDark),
                    const SizedBox(width: 24),
                    _buildSocialButton(Icons.facebook, Colors.blue, isDark),
                  ],
                ),
                const SizedBox(height: 48),

                // Redirect to Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.textSecondary(isDark),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        );
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: AppColors.neonBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildSocialButton(IconData icon, Color color, bool isDark) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(isDark), width: 1.5),
      ),
      child: Center(
        child: Icon(
          icon,
          color: isDark && icon == Icons.apple ? Colors.white : (icon == Icons.apple ? Colors.black : color),
          size: icon == Icons.g_mobiledata_rounded ? 42 : 26,
        ),
      ),
    );
  }
}
