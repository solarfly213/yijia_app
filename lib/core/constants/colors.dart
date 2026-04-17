import 'package:flutter/material.dart';

/// 忆家 App 色彩系统 - 老年人友好设计
class AppColors {
  AppColors._();

  // 主色调 - 沉稳蓝绿，带来镇定感
  static const Color primary = Color(0xFF4A90A4);
  static const Color primaryLight = Color(0xFF7AB5C5);
  static const Color primaryDark = Color(0xFF2D6B7A);

  // 次色调 - 暖橙，温暖亲切
  static const Color secondary = Color(0xFFF5A623);
  static const Color secondaryLight = Color(0xFFFFB84D);
  static const Color secondaryDark = Color(0xFFCC8500);

  // 背景色
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // 文字色 - 高对比度
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // 功能色
  static const Color success = Color(0xFF7CB342);
  static const Color warning = Color(0xFFFF8A65);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);

  // 导航栏
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navSelected = Color(0xFF4A90A4);
  static const Color navUnselected = Color(0xFF999999);

  // 卡片阴影
  static const Color shadow = Color(0x1A000000);

  // 游戏配色
  static const Color gameCardFront = Color(0xFF4A90A4);
  static const Color gameCardBack = Color(0xFFF5A623);
  static const Color gameCorrect = Color(0xFF7CB342);
  static const Color gameWrong = Color(0xFFE57373);

  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
}
