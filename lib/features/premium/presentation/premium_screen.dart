import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';
import 'package:deepfake_ai/core/theme/text_styles.dart';
import 'package:deepfake_ai/shared/widgets/custom_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isYearly = true; // Default to Yearly (Save 40%)

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
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
                    child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),

                // Crown Header Upgrade Info
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: AppColors.warningOrange.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.4), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.warningOrange.withValues(alpha: 0.2),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.warningOrange,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Upgrade to Premium",
                        style: AppTextStyles.getHeadingMedium(isDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Unlock advanced neural AI scans and full detailed telemetry.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.getBodyMedium(isDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Interactive Toggle Tabs: Monthly vs Yearly
                Container(
                  height: 56,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder(isDark)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isYearly = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_isYearly ? AppColors.darkCardBorder : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: !_isYearly ? AppColors.darkCardBorder : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Monthly",
                                style: TextStyle(
                                  color: !_isYearly ? Colors.white : AppColors.textSecondary(isDark),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isYearly = true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isYearly ? AppColors.neonBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isYearly ? AppColors.neonBlue : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Yearly",
                                  style: TextStyle(
                                    color: _isYearly ? Colors.white : AppColors.textSecondary(isDark),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Save 40%",
                                    style: TextStyle(
                                      color: AppColors.neonBlue,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Subscription Plan Cards Side-by-Side / List Comparison
                _buildPlanCard(
                  "Basic Plan",
                  _isYearly ? "\$2.99" : "\$4.99",
                  [
                    "100 neural scans / month",
                    "Basic pattern reports",
                    "Standard email support",
                  ],
                  false,
                  isDark,
                ),
                const SizedBox(height: 18),
                _buildPlanCard(
                  "Pro Neural Plan",
                  _isYearly ? "\$5.99" : "\$9.99",
                  [
                    "Unlimited deep neural scans",
                    "Detailed pixel anomaly reports",
                    "24/7 Priority support access",
                    "Early access to new models",
                  ],
                  true, // Highlighted card
                  isDark,
                ),
                const SizedBox(height: 36),

                // Emphasized CTA Free Trial Button
                CustomButton(
                  text: "Start 7-Day Free Trial",
                  gradient: AppColors.accentGradient,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Subscription activated! Enjoy Premium benefits."),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Cancel anytime in settings. Terms apply.",
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark).withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    String title,
    String price,
    List<String> benefits,
    bool isHighlighted,
    bool isDark,
  ) {
    final cardBorderColor = isHighlighted 
        ? AppColors.neonBlue 
        : AppColors.cardBorder(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? AppColors.neonBlue.withValues(alpha: 0.04) 
            : AppColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorderColor, width: isHighlighted ? 2.0 : 1.0),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.neonBlue.withValues(alpha: 0.1),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isHighlighted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Most Popular",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "/month",
                style: TextStyle(
                  color: AppColors.textSecondary(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.cardBorder(isDark)),
          const SizedBox(height: 16),

          // Benefits checklists
          Column(
            children: List.generate(benefits.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        color: isHighlighted 
                            ? AppColors.neonBlue.withValues(alpha: 0.12) 
                            : AppColors.textSecondary(isDark).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: isHighlighted ? AppColors.neonBlue : AppColors.textSecondary(isDark),
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefits[index],
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark).withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
