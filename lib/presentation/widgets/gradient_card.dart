import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// 渐变色卡片组件
class GradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Gradient gradient;
  final double borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.onTap,
    required this.gradient,
    this.borderRadius = 20,
  });

  /// 工厂方法：从颜色创建渐变
  factory GradientCard.fromColor({
    required Widget child,
    VoidCallback? onTap,
    required Color color,
    Color? endColor,
    double borderRadius = 20,
  }) {
    return GradientCard(
      onTap: onTap,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          endColor ?? color.withOpacity(0.7),
        ],
      ),
      borderRadius: borderRadius,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
