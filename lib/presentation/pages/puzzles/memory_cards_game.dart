import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/training/training_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 记忆卡牌游戏
class MemoryCardsGame extends StatefulWidget {
  final int cardCount;

  const MemoryCardsGame({super.key, this.cardCount = 8});

  @override
  State<MemoryCardsGame> createState() => _MemoryCardsGameState();
}

class _MemoryCardsGameState extends State<MemoryCardsGame> {
  late List<_MemoryCard> _cards;
  int _pairsFound = 0;
  int _attempts = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _isLocked = false;
  _MemoryCard? _firstCard;
  _MemoryCard? _secondCard;

  // 内置图案（可用于无照片时）
  static const List<_CardPattern> _patterns = [
    _CardPattern(icon: Icons.star, color: Color(0xFFFFD700)),
    _CardPattern(icon: Icons.favorite, color: Color(0xFFE91E63)),
    _CardPattern(icon: Icons.home, color: Color(0xFF4CAF50)),
    _CardPattern(icon: Icons.pets, color: Color(0xFFFF9800)),
    _CardPattern(icon: Icons.music_note, color: Color(0xFF9C27B0)),
    _CardPattern(icon: Icons.wb_sunny, color: Color(0xFFFFEB3B)),
    _CardPattern(icon: Icons.local_florist, color: Color(0xFF00BCD4)),
    _CardPattern(icon: Icons.cake, color: Color(0xFFEF5350)),
    _CardPattern(icon: Icons.sports_soccer, color: Color(0xFF2196F3)),
    _CardPattern(icon: Icons.weekend, color: Color(0xFF795548)),
    _CardPattern(icon: Icons.local_cafe, color: Color(0xFF607D8B)),
    _CardPattern(icon: Icons.beach_access, color: Color(0xFF00BCD4)),
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final cardCount = widget.cardCount;
    final cardItems = <_MemoryCard>[];
    final usedPatterns = _patterns.take(cardCount ~/ 2).toList();

    for (int i = 0; i < usedPatterns.length; i++) {
      // 每种图案创建两张卡牌
      cardItems.add(_MemoryCard(
        id: i * 2,
        patternIndex: i,
        pattern: usedPatterns[i],
      ));
      cardItems.add(_MemoryCard(
        id: i * 2 + 1,
        patternIndex: i,
        pattern: usedPatterns[i],
      ));
    }

    // 打乱顺序
    cardItems.shuffle(Random());
    _cards = cardItems;
    _pairsFound = 0;
    _attempts = 0;
    _seconds = 0;
    _firstCard = null;
    _secondCard = null;
    _isLocked = false;

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
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

    if (_firstCard!.patternIndex == _secondCard!.patternIndex) {
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

      if (_pairsFound == widget.cardCount ~/ 2) {
        _onGameComplete();
      }
    } else {
      // 匹配失败
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
    final timeBonus = max(0, 60 - _seconds);
    final attemptPenalty = max(0, (_attempts - _pairsFound) * 2);
    final finalScore = baseScore + timeBonus - attemptPenalty;

    // 保存训练记录
    context.read<TrainingBloc>().add(AddTrainingRecord(
      module: 'puzzle',
      activity: 'memory_cards',
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.done),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _initGame());
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

  int _getGridCrossAxisCount() {
    if (widget.cardCount <= 4) return 2;
    if (widget.cardCount <= 8) return 4;
    if (widget.cardCount <= 12) return 4;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.memoryCards),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _initGame()),
          ),
        ],
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getGridCrossAxisCount(),
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
          _buildStatusItem(Icons.check_circle, '$_pairsFound/${widget.cardCount ~/ 2}'),
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

  Widget _buildCardContent(_MemoryCard card) {
    if (card.isFlipped || card.isMatched) {
      return Container(
        decoration: BoxDecoration(
          color: card.pattern.color.withOpacity(0.2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Icon(
                card.pattern.icon,
                size: 48,
                color: card.pattern.color,
              ),
            ),
            if (card.isMatched)
              Container(
                color: AppColors.success.withOpacity(0.3),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ),
          ],
        ),
      );
    } else {
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

class _MemoryCard {
  final int id;
  final int patternIndex;
  final _CardPattern pattern;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.id,
    required this.patternIndex,
    required this.pattern,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class _CardPattern {
  final IconData icon;
  final Color color;

  const _CardPattern({required this.icon, required this.color});
}
