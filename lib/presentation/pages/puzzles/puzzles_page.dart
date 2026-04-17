import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/gradient_card.dart';
import 'memory_cards_game.dart';
import 'number_quiz_page.dart';

/// 益智游戏页面
class PuzzlesPage extends StatelessWidget {
  const PuzzlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.puzzles),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明文字
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: AppColors.secondary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '每天进行益智训练\n有助于维持认知功能',
                      style: AppTheme.scaledTextStyle(const TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 游戏列表
            Expanded(
              child: ListView(
                children: [
                  _buildGameCard(
                    context,
                    icon: Icons.extension,
                    title: AppStrings.memoryCards,
                    subtitle: '翻牌记忆游戏，锻炼短期记忆',
                    color: AppColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MemoryCardsGame(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGameCard(
                    context,
                    icon: Icons.grid_view,
                    title: AppStrings.jigsawPuzzle,
                    subtitle: '3x3 滑块拼图，锻炼空间认知',
                    color: AppColors.info,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('拼图游戏开发中...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGameCard(
                    context,
                    icon: Icons.calculate,
                    title: AppStrings.numberQuiz,
                    subtitle: '数字排序与简单计算',
                    color: AppColors.success,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NumberQuizPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGameCard(
                    context,
                    icon: Icons.access_time,
                    title: '认识时钟',
                    subtitle: '看时钟说时间',
                    color: AppColors.warning,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('时钟游戏开发中...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GradientCard.fromColor(
      color: color,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.scaledTextStyle(const TextStyle(
                      fontSize: 20,
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
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
