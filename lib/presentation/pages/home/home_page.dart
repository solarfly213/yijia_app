import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/training/training_bloc.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/date_display.dart';

/// 首页
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 问候语
              _buildGreeting(context),
              const SizedBox(height: 24),

              // 日期显示
              const DateDisplay(),
              const SizedBox(height: 24),

              // 今日训练概览
              _buildTodayOverview(context),
              const SizedBox(height: 24),

              // 功能入口
              _buildModuleGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = AppStrings.greetingMorning;
    } else if (hour < 18) {
      greeting = AppStrings.greetingAfternoon;
    } else {
      greeting = AppStrings.greetingEvening;
    }

    final greetingIndex = DateTime.now().day % AppStrings.dailyGreetings.length;
    final dailyTip = AppStrings.dailyGreetings[greetingIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTheme.scaledTextStyle(const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          )),
        ),
        const SizedBox(height: 8),
        Text(
          dailyTip,
          style: AppTheme.scaledTextStyle(const TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          )),
        ),
      ],
    );
  }

  Widget _buildTodayOverview(BuildContext context) {
    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        int minutes = 0;
        int score = 0;
        if (state is TrainingLoaded) {
          minutes = state.todayTotalMinutes;
          score = state.todayTotalScore;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.todayTraining,
                    style: AppTheme.scaledTextStyle(const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.timer,
                      value: '$minutes',
                      label: AppStrings.minutes,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white30,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.star,
                      value: '$score',
                      label: AppStrings.score,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildModuleCard(
              context,
              icon: Icons.photo_library,
              title: AppStrings.photoMemory,
              subtitle: '照片回忆训练',
              color: AppColors.primary,
              onTap: () => Navigator.pushNamed(context, '/photo'),
            ),
            _buildModuleCard(
              context,
              icon: Icons.extension,
              title: AppStrings.puzzles,
              subtitle: '益智游戏',
              color: AppColors.secondary,
              onTap: () => Navigator.pushNamed(context, '/puzzles'),
            ),
            _buildModuleCard(
              context,
              icon: Icons.access_time,
              title: AppStrings.orientation,
              subtitle: '时间定向',
              color: AppColors.info,
              onTap: () => Navigator.pushNamed(context, '/orientation'),
            ),
            _buildModuleCard(
              context,
              icon: Icons.music_note,
              title: AppStrings.musicRecall,
              subtitle: '音乐回忆',
              color: AppColors.success,
              onTap: () => Navigator.pushNamed(context, '/music'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GradientCard(
      onTap: onTap,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, color.withOpacity(0.7)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTheme.scaledTextStyle(const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.scaledTextStyle(const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            )),
          ),
        ],
      ),
    );
  }
}
