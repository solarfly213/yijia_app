import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/training/training_bloc.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = state.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 用户信息卡片
              _buildUserCard(context, settings.userName),
              const SizedBox(height: 24),

              // 显示设置
              _buildSectionTitle('显示设置'),
              _buildSettingsCard([
                _buildFontSizeItem(context, settings.fontScale),
              ]),
              const SizedBox(height: 24),

              // 声音与反馈
              _buildSectionTitle('声音与反馈'),
              _buildSettingsCard([
                _buildSoundVolumeItem(context, settings.soundVolume),
                const Divider(height: 1),
                _buildHapticItem(context, settings.hapticFeedback),
              ]),
              const SizedBox(height: 24),

              // 训练记录
              _buildSectionTitle('数据管理'),
              _buildSettingsCard([
                _buildNavigationItem(
                  icon: Icons.history,
                  title: AppStrings.trainingRecords,
                  subtitle: '查看训练历史',
                  onTap: () => _showTrainingRecords(context),
                ),
                const Divider(height: 1),
                _buildNavigationItem(
                  icon: Icons.backup,
                  title: '数据备份',
                  subtitle: '导出训练数据',
                  onTap: () => _showBackupDialog(context),
                ),
              ]),
              const SizedBox(height: 24),

              // 关于
              _buildSectionTitle(AppStrings.about),
              _buildSettingsCard([
                _buildInfoItem(
                  icon: Icons.info_outline,
                  title: AppStrings.version,
                  value: '1.0.0',
                ),
                const Divider(height: 1),
                _buildNavigationItem(
                  icon: Icons.help_outline,
                  title: '使用帮助',
                  subtitle: '了解各功能的使用方法',
                  onTap: () => _showHelpDialog(context),
                ),
              ]),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, String userName) {
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showAvatarPicker(context),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.isEmpty ? '设置用户名' : userName,
                  style: AppTheme.scaledTextStyle(const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
                ),
                const SizedBox(height: 4),
                Text(
                  '点击头像修改',
                  style: AppTheme.scaledTextStyle(const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  )),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditNameDialog(context, userName),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildFontSizeItem(BuildContext context, double fontScale) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields, color: AppColors.primary, size: 28),
              const SizedBox(width: 16),
              Text(
                AppStrings.fontSize,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getFontSizeLabel(fontScale),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              Expanded(
                child: Slider(
                  value: fontScale,
                  min: 1.0,
                  max: 1.5,
                  divisions: 5,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(UpdateFontScale(value));
                  },
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 24, color: AppColors.textSecondary)),
            ],
          ),
          // 预览
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '预览文字大小',
              style: TextStyle(
                fontSize: 16 * fontScale,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFontSizeLabel(double fontScale) {
    if (fontScale <= 1.0) return '标准';
    if (fontScale <= 1.15) return '中等';
    if (fontScale <= 1.3) return '大';
    return '特大';
  }

  Widget _buildSoundVolumeItem(BuildContext context, double volume) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up, color: AppColors.primary, size: 28),
              const SizedBox(width: 16),
              Text(
                AppStrings.sound,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${(volume * 100).round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: volume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: (value) {
              context.read<SettingsBloc>().add(UpdateSoundVolume(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHapticItem(BuildContext context, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.vibration, color: AppColors.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.hapticFeedback,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '操作时提供触感反馈',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: AppColors.primary,
            onChanged: (value) {
              context.read<SettingsBloc>().add(UpdateHapticFeedback(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.primary, size: 28),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.primary, size: 28),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改用户名'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '用户名',
            hintText: '请输入用户名',
          ),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(UpdateUserName(controller.text));
              Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('头像功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showTrainingRecords(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrainingRecordsPage(),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup, color: AppColors.primary),
            SizedBox(width: 12),
            Text('数据备份'),
          ],
        ),
        content: const Text(
          '是否导出所有训练数据？\n导出的数据可以用于备份或迁移。',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('备份功能开发中...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('导出'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help, color: AppColors.primary),
            SizedBox(width: 12),
            Text('使用帮助'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpItem(
                title: '照片回忆',
                content: '添加家人照片，通过配对游戏和讲述故事来锻炼记忆和语言能力。',
              ),
              SizedBox(height: 16),
              _HelpItem(
                title: '益智游戏',
                content: '记忆卡牌、数字认知等游戏，帮助锻炼注意力和计算能力。',
              ),
              SizedBox(height: 16),
              _HelpItem(
                title: '时间定向',
                content: '认识当前日期、季节、时间等，提升时间感知能力。',
              ),
              SizedBox(height: 16),
              _HelpItem(
                title: '音乐回忆',
                content: '通过老歌和节奏游戏，唤起美好回忆，锻炼听觉感知。',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String title;
  final String content;

  const _HelpItem({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// 训练记录页面
class TrainingRecordsPage extends StatelessWidget {
  const TrainingRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.trainingRecords),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TrainingBloc, TrainingState>(
        builder: (context, state) {
          if (state is! TrainingLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.allRecords.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text(
                    '暂无训练记录\n开始训练后记录会显示在这里',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.allRecords.length,
            itemBuilder: (context, index) {
              final record = state.allRecords[state.allRecords.length - 1 - index];
              return _buildRecordCard(record);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(dynamic record) {
    final moduleLabel = {
      'photo': '照片回忆',
      'puzzle': '益智游戏',
      'orientation': '时间定向',
      'music': '音乐回忆',
      'language': '语言训练',
    }[record.module] ?? record.module;

    final activityLabel = {
      'photo_matching': '照片配对',
      'photo_story': '照片故事',
      'memory_cards': '记忆卡牌',
      'number_quiz': '数字认知',
    }[record.activity] ?? record.activity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moduleLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activityLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${record.score}分',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  record.formattedDuration,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
