import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/app_theme.dart';

/// 日期显示组件 - 大字号老年人友好
class DateDisplay extends StatelessWidget {
  const DateDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy年MM月dd日');
    final weekFormat = DateFormat('EEEE');
    final weekDay = _getWeekDayChinese(now.weekday);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 年月日
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                dateFormat.format(now),
                style: AppTheme.scaledTextStyle(const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 星期
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              weekDay,
              style: AppTheme.scaledTextStyle(const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekDayChinese(int weekday) {
    const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    return weekdays[weekday - 1];
  }
}
