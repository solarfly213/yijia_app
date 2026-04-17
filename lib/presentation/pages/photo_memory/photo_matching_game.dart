import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/training/training_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 照片配对游戏
class PhotoMatchingGame extends StatefulWidget {
  final List<String> photos;

  const PhotoMatchingGame({super.key, required this.photos});

  @override
  State<PhotoMatchingGame> createState() => _PhotoMatchingGameState();
}

class _PhotoMatchingGameState extends State<PhotoMatchingGame> {
  late List<_CardItem> _cards;
  int _pairsFound = 0;
  int _attempts = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _isLocked = false;
  _CardItem? _firstCard;
  _CardItem? _secondCard;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    // 选择最多6对照片
    final selectedPhotos = widget.photos.take(6).toList();
    final cardItems = <_CardItem>[];

    for (int i = 0; i < selectedPhotos.length; i++) {
      // 每张照片创建两张卡牌
      cardItems.add(_CardItem(
        id: i * 2,
        pairId: i,
        photoPath: selectedPhotos[i],
      ));
      cardItems.add(_CardItem(
        id: i * 2 + 1,
        pairId: i,
        photoPath: selectedPhotos[i],
      ));
    }

    // 打乱顺序
    cardItems.shuffle(Random());
    _cards = cardItems;

    // 开始计时
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _onCardTap(int index) {
    if (_isLocked) return;
    if (_cards[index].isFlipped) return;
    if (_cards[index].isMatched) return;

    HapticFeedback.lightImpact();

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstCard == null) {
      _firstCard = _cards[index];
    } else {
      _secondCard = _cards[index];
      _attempts++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isLocked = true;

    if (_firstCard!.pairId == _secondCard!.pairId) {
      // 匹配成功
      HapticFeedback.mediumImpact();
      setState(() {
        _firstCard!.isMatched = true;
        _secondCard!.isMatched = true;
        _pairsFound++;
        _firstCard = null;
        _secondCard = null;
        _isLocked = false;
      });

      if (_pairsFound == widget.photos.length.clamp(1, 6)) {
        _onGameComplete();
      }
    } else {
      // 匹配失败，延迟翻转回去
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _firstCard!.isFlipped = false;
          _secondCard!.isFlipped = false;
          _firstCard = null;
          _secondCard = null;
          _isLocked = false;
        });
      });
    }
  }

  void _onGameComplete() {
    _stopTimer();

    // 计算得分
    final baseScore = 100;
    final timeBonus = max(0, 50 - _seconds);
    final attemptPenalty = max(0, (_attempts - _pairsFound) * 2);
    final finalScore = baseScore + timeBonus - attemptPenalty;

    // 保存训练记录
    context.read<TrainingBloc>().add(AddTrainingRecord(
      module: 'photo',
      activity: 'photo_matching',
      score: finalScore,
      durationSeconds: _seconds,
    ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 80,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.congratulations,
              style: AppTheme.scaledTextStyle(const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              )),
            ),
            const SizedBox(height: 24),
            _buildResultRow(AppStrings.score, '$finalScore'),
            const SizedBox(height: 8),
            _buildResultRow(AppStrings.time, _formatTime(_seconds)),
            const SizedBox(height: 8),
            _buildResultRow('尝试次数', '$_attempts'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 返回列表
            },
            child: const Text(AppStrings.done),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pairsFound = 0;
                _attempts = 0;
                _seconds = 0;
                _initGame();
              });
            },
            child: const Text(AppStrings.restart),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.photoMatching),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 状态栏
          _buildStatusBar(),

          // 游戏区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return _buildCard(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(Icons.timer, _formatTime(_seconds)),
          _buildStatusItem(Icons.touch_app, '$_attempts'),
          _buildStatusItem(Icons.check_circle, '$_pairsFound/${widget.photos.length.clamp(1, 6)}'),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildCardContent(card),
        ),
      ),
    );
  }

  Widget _buildCardContent(_CardItem card) {
    if (card.isFlipped || card.isMatched) {
      // 显示照片
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(card.photoPath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.primary,
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              );
            },
          ),
          if (card.isMatched)
            Container(
              color: AppColors.success.withOpacity(0.3),
              child: const Center(
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
            ),
        ],
      );
    } else {
      // 显示背面
      return Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: const Center(
          child: Icon(
            Icons.question_mark,
            color: Colors.white,
            size: 40,
          ),
        ),
      );
    }
  }
}

class _CardItem {
  final int id;
  final int pairId;
  final String photoPath;
  bool isFlipped;
  bool isMatched;

  _CardItem({
    required this.id,
    required this.pairId,
    required this.photoPath,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
