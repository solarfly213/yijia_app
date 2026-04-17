import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/training/training_bloc.dart';

/// 照片故事页面 - 引导用户讲述照片故事
class PhotoStoryPage extends StatefulWidget {
  final List<String> photos;

  const PhotoStoryPage({super.key, required this.photos});

  @override
  State<PhotoStoryPage> createState() => _PhotoStoryPageState();
}

class _PhotoStoryPageState extends State<PhotoStoryPage> {
  late String _currentPhoto;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPhoto = widget.photos.first;
  }

  void _selectRandomPhoto() {
    final random = Random();
    final index = random.nextInt(widget.photos.length);
    setState(() {
      _currentIndex = index;
      _currentPhoto = widget.photos[index];
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.photoStory),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 照片展示
            _buildPhotoSection(),

            // 引导文字
            _buildGuidanceSection(),

            // 操作按钮
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(_currentPhoto),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              color: AppColors.secondary.withOpacity(0.2),
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 80,
                  color: AppColors.secondary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuidanceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 40,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.tellStory,
            style: AppTheme.scaledTextStyle(const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _getRandomPrompt(),
            style: AppTheme.scaledTextStyle(const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            )),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getRandomPrompt() {
    final prompts = [
      '这张照片是什么时候拍的？',
      '照片里有谁？你们在做什么？',
      '这个地方是哪里？',
      '这张照片有什么特别的意义吗？',
      '讲述一下照片中的场景...',
      '这张照片让你想起了什么？',
    ];
    return prompts[DateTime.now().second % prompts.length];
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectRandomPhoto,
                  icon: const Icon(Icons.shuffle, size: 24),
                  label: const Text('换一张'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 60),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 开始录音讲述
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('录音功能开发中...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mic, size: 24),
                  label: const Text('开始讲述'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 60),
                    backgroundColor: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '讲述完毕后，点击「完成」保存这段回忆',
            style: AppTheme.scaledTextStyle(const TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            )),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              context.read<TrainingBloc>().add(AddTrainingRecord(
                module: 'photo',
                activity: 'photo_story',
                score: 20,
                durationSeconds: 60,
              ));
              Navigator.pop(context);
            },
            child: const Text(AppStrings.done),
          ),
        ],
      ),
    );
  }
}
