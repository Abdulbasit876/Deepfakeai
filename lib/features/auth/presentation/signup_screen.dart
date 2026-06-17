import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/shared/widgets/custom_button.dart';
import 'package:deepfake_ai/shared/widgets/custom_textfield.dart';
import 'package:deepfake_ai/main.dart'; // Navigation context
import 'package:provider/provider.dart';
import 'package:deepfake_ai/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                const SizedBox(height: 24),

                Text(
                  "Create Account",
                  style: AppTextStyles.getHeadingLarge(isDark).copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign up to get started scanning files and secure your media assets.",
                  style: AppTextStyles.getBodyMedium(isDark),
                ),
                const SizedBox(height: 36),

                // Form items
                CustomTextField(
                  controller: _nameController,
                  hintText: "Full Name",
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: _emailController,
                  hintText: "Email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm Password",
                  prefixIcon: Icons.lock_reset_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 28),

                // Signup Action
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: auth.isLoading ? "Signing up..." : "Sign Up",
                      onTap: auth.isLoading
                          ? null
                          : () async {
                              final name = _nameController.text.trim();
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;
                              final confirmPassword = _confirmPasswordController.text;

                              if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all fields')),
                                );
                                return;
                              }

                              if (password != confirmPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Passwords do not match')),
                                );
                                return;
                              }

                              final success = await auth.signUpWithEmail(email: email, password: password, fullName: name);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Account created! Please log in.')),
                                );
                                Navigator.of(context).pop();
                              } else if (!success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(auth.errorMessage ?? 'Signup failed')),
                                );
                              }
                            },
                    );
                  }
                ),
                const SizedBox(height: 32),

                // Or divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.cardBorder(isDark))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "or continue with",
                        style: TextStyle(
                          color: AppColors.textSecondary(isDark).withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.cardBorder(isDark))),
                  ],
                ),
                const SizedBox(height: 24),

                // Social authentications buttons
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.g_mobiledata_rounded, Colors.red, isDark, onTap: () async {
                          final success = await auth.signInWithGoogle();
                          if (success && mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const MainAppContainer()),
                              (route) => false,
                            );
                          } else if (!success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(auth.errorMessage ?? 'Google signup failed')),
                            );
                          }
                        }),
                        const SizedBox(width: 20),
                        _buildSocialButton(Icons.apple, Colors.white, isDark, onTap: () {}),
                        const SizedBox(width: 20),
                        _buildSocialButton(Icons.facebook, Colors.blue, isDark, onTap: () {}),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 36),

                // Redirect to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: AppColors.textSecondary(isDark),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        "Login",
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

  Widget _buildSocialButton(IconData icon, Color color, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(isDark), width: 1.5),
      ),
      child: Center(
        child: Icon(
          icon,
          color: isDark && icon == Icons.apple ? Colors.white : (icon == Icons.apple ? Colors.black : color),
          size: icon == Icons.g_mobiledata_rounded ? 38 : 24,
        ),
      ),
      ),
    );
  }
}
