import 'package:flutter/material.dart';
import 'package:deepfake_ai/core/constants/app_colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final double width;
  final double height;
  final bool isSecondary;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.gradient = AppColors.primaryGradient,
    this.width = double.infinity,
    this.height = 56,
    this.isSecondary = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _controller.forward(); },
      onTapUp: (_) {
        if (widget.onTap != null) {
          _controller.reverse();
          widget.onTap!();
        }
      },
      onTapCancel: () { if (widget.onTap != null) _controller.reverse(); },
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.isSecondary ? null : widget.gradient,
            border: widget.isSecondary 
                ? Border.all(color: AppColors.cardBorder(isDark), width: 1.5) 
                : null,
            color: widget.isSecondary ? AppColors.cardBg(isDark) : null,
            boxShadow: widget.isSecondary 
                ? [] 
                : [
                    BoxShadow(
                      color: widget.gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.isSecondary 
                    ? AppColors.textPrimary(isDark) 
                    : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
