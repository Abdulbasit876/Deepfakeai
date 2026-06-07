import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/shared/widgets/custom_button.dart';
import 'package:deepfake_ai/shared/widgets/custom_textfield.dart';
import 'package:deepfake_ai/main.dart'; // Navigation context
import 'package:provider/provider.dart';
import 'package:deepfake_ai/providers/auth_provider.dart';
import 'package:toastification/toastification.dart';
import 'package:deepfake_ai/features/auth/presentation/forgot_password_screen.dart';
import 'package:deepfake_ai/features/auth/presentation/signup_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  controller: _emailController,
                  hintText: "Email or Phone",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
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
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: auth.isLoading ? "Logging in..." : "Login",
                      onTap: auth.isLoading
                          ? null
                          : () async {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;
                              
                              if (email.isEmpty || password.isEmpty) {
                                toastification.show(
                                  context: context,
                                  title: const Text('Please fill all fields'),
                                  type: ToastificationType.warning,
                                  style: ToastificationStyle.flatColored,
                                  autoCloseDuration: const Duration(seconds: 3),
                                );
                                return;
                              }
                              
                              final success = await auth.signInWithEmail(email: email, password: password);
                              if (success && mounted) {
                                toastification.show(
                                  context: context,
                                  title: const Text('Login Successful'),
                                  type: ToastificationType.success,
                                  style: ToastificationStyle.flatColored,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const MainAppContainer()),
                                  (route) => false,
                                );
                              } else if (!success && mounted) {
                                toastification.show(
                                  context: context,
                                  title: Text(auth.errorMessage ?? 'Login failed'),
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.flatColored,
                                  autoCloseDuration: const Duration(seconds: 4),
                                );
                              }
                            },
                    );
                  }
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
                          color: AppColors.textSecondary(isDark).withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.cardBorder(isDark))),
                  ],
                ),
                const SizedBox(height: 32),

                // Social authentications buttons
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.g_mobiledata_rounded, Colors.red, isDark, onTap: () async {
                          final success = await auth.signInWithGoogle();
                          if (success && mounted) {
                            toastification.show(
                              context: context,
                              title: const Text('Login Successful'),
                              type: ToastificationType.success,
                              style: ToastificationStyle.flatColored,
                              autoCloseDuration: const Duration(seconds: 2),
                            );
                            // Supabase oauth might redirect to browser and then back to app
                            // Listen to auth state changes from auth provider in the app level, but for now we push:
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const MainAppContainer()),
                              (route) => false,
                            );
                          } else if (!success && mounted) {
                            toastification.show(
                              context: context,
                              title: Text(auth.errorMessage ?? 'Google login failed'),
                              type: ToastificationType.error,
                              style: ToastificationStyle.flatColored,
                              autoCloseDuration: const Duration(seconds: 4),
                            );
                          }
                        }),
                        const SizedBox(width: 24),
                        _buildSocialButton(Icons.apple, Colors.white, isDark, onTap: () {}),
                        const SizedBox(width: 24),
                        _buildSocialButton(Icons.facebook, Colors.blue, isDark, onTap: () {}),
                      ],
                    );
                  }
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

  Widget _buildSocialButton(IconData icon, Color color, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
