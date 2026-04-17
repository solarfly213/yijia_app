import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/training/training_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 数字认知训练页面
class NumberQuizPage extends StatefulWidget {
  const NumberQuizPage({super.key});

  @override
  State<NumberQuizPage> createState() => _NumberQuizPageState();
}

class _NumberQuizPageState extends State<NumberQuizPage> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 10;
  int _seconds = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  late _QuizQuestion _currentQuestion;

  // 记录每个问题的回答时间
  final List<int> _answerTimes = [];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    final questionTypes = ['ordering', 'addition', 'subtraction'];
    final type = questionTypes[random.nextInt(questionTypes.length)];

    switch (type) {
      case 'ordering':
        _currentQuestion = _generateOrderingQuestion(random);
        break;
      case 'addition':
        _currentQuestion = _generateAdditionQuestion(random);
        break;
      case 'subtraction':
        _currentQuestion = _generateSubtractionQuestion(random);
        break;
    }
  }

  _QuizQuestion _generateOrderingQuestion(Random random) {
    final size = random.nextInt(2) + 3; // 3-4个数
    final numbers = <int>[];
    while (numbers.length < size) {
      final num = random.nextInt(20) + 1;
      if (!numbers.contains(num)) numbers.add(num);
    }

    final ascending = random.nextBool();
    final sorted = List<int>.from(numbers)..sort();
    final target = ascending ? sorted.first : sorted.last;
    final answerIndex = numbers.indexOf(target);

    return _QuizQuestion(
      type: 'ordering',
      question: ascending ? '以下数字中，最小的是哪个？' : '以下数字中，最大的是哪个？',
      numbers: numbers,
      options: numbers,
      correctAnswer: target,
      displayNumbers: numbers,
      isAscending: ascending,
    );
  }

  _QuizQuestion _generateAdditionQuestion(Random random) {
    final a = random.nextInt(20) + 1;
    final b = random.nextInt(20) + 1;
    final correct = a + b;

    // 生成干扰选项
    final options = <int>{correct};
    while (options.length < 4) {
      final wrong = correct + random.nextInt(11) - 5;
      if (wrong > 0 && wrong != correct) options.add(wrong);
    }
    final optionList = options.toList()..shuffle(random);

    return _QuizQuestion(
      type: 'addition',
      question: '$a + $b = ?',
      numbers: [a, b],
      options: optionList,
      correctAnswer: correct,
    );
  }

  _QuizQuestion _generateSubtractionQuestion(Random random) {
    final a = random.nextInt(15) + 10; // 10-24
    final b = random.nextInt(a); // 确保不出现负数
    final correct = a - b;

    // 生成干扰选项
    final options = <int>{correct};
    while (options.length < 4) {
      final wrong = correct + random.nextInt(7) - 3;
      if (wrong >= 0 && wrong != correct) options.add(wrong);
    }
    final optionList = options.toList()..shuffle(random);

    return _QuizQuestion(
      type: 'subtraction',
      question: '$a - $b = ?',
      numbers: [a, b],
      options: optionList,
      correctAnswer: correct,
    );
  }

  void _selectAnswer(int answer) {
    if (_showResult) return;

    HapticFeedback.selectionClick();
    setState(() {
      _selectedAnswer = answer;
      _isCorrect = answer == _currentQuestion.correctAnswer;
      _showResult = true;

      if (_isCorrect) {
        _correctAnswers++;
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showResult = false;
        _generateQuestion();
      });
    } else {
      _showFinalResult();
    }
  }

  void _showFinalResult() {
    final score = (_correctAnswers / _totalQuestions * 100).round();

    context.read<TrainingBloc>().add(AddTrainingRecord(
      module: 'puzzle',
      activity: 'number_quiz',
      score: score,
      durationSeconds: _seconds,
    ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              score >= 80 ? Icons.celebration : Icons.emoji_events,
              color: score >= 80 ? AppColors.secondary : AppColors.primary,
              size: 36,
            ),
            const SizedBox(width: 12),
            Text(
              score >= 80 ? AppStrings.congratulations : '继续加油！',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score分',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: score >= 80 ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '答对 $_correctAnswers / $_totalQuestions 题',
              style: const TextStyle(fontSize: 18),
            ),
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
              setState(() {
                _currentQuestionIndex = 0;
                _correctAnswers = 0;
                _selectedAnswer = null;
                _showResult = false;
                _generateQuestion();
              });
            },
            child: const Text(AppStrings.restart),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.numberQuiz),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 进度和状态
          _buildStatusBar(),

          // 问题区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 问题卡片
                  _buildQuestionCard(),

                  const SizedBox(height: 24),

                  // 选项
                  _buildOptions(),
                ],
              ),
            ),
          ),

          // 下一题按钮
          if (_showResult) _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final progress = (_currentQuestionIndex + 1) / _totalQuestions;
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '第 ${_currentQuestionIndex + 1} / $_totalQuestions 题',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                  const SizedBox(width: 4),
                  Text(
                    '$_correctAnswers',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.success.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 问题类型标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getQuestionTypeLabel(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 问题文字
          Text(
            _currentQuestion.question,
            style: AppTheme.scaledTextStyle(const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
            textAlign: TextAlign.center,
          ),

          // 数字展示（如果有）
          if (_currentQuestion.displayNumbers != null) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _currentQuestion.displayNumbers!.map((num) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success, width: 2),
                  ),
                  child: Text(
                    '$num',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _getQuestionTypeLabel() {
    switch (_currentQuestion.type) {
      case 'ordering':
        return '数字排序';
      case 'addition':
        return '加法';
      case 'subtraction':
        return '减法';
      default:
        return '';
    }
  }

  Widget _buildOptions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: _currentQuestion.options.map((option) {
        return _buildOptionButton(option);
      }).toList(),
    );
  }

  Widget _buildOptionButton(int option) {
    Color backgroundColor = AppColors.surface;
    Color borderColor = AppColors.primary;
    Color textColor = AppColors.textPrimary;
    IconData? icon;

    if (_showResult) {
      if (option == _currentQuestion.correctAnswer) {
        backgroundColor = AppColors.success.withOpacity(0.2);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        icon = Icons.check_circle;
      } else if (option == _selectedAnswer && !_isCorrect) {
        backgroundColor = AppColors.error.withOpacity(0.2);
        borderColor = AppColors.error;
        textColor = AppColors.error;
        icon = Icons.cancel;
      }
    } else if (option == _selectedAnswer) {
      backgroundColor = AppColors.primary.withOpacity(0.1);
      borderColor = AppColors.primary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showResult ? null : () => _selectAnswer(option),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$option',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: textColor, size: 28),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _nextQuestion,
          icon: const Icon(Icons.arrow_forward, size: 28),
          label: Text(
            _currentQuestionIndex < _totalQuestions - 1 ? '下一题' : '查看结果',
            style: const TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 64),
            backgroundColor: _isCorrect ? AppColors.success : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String type;
  final String question;
  final List<int> numbers;
  final List<int> options;
  final int correctAnswer;
  final List<int>? displayNumbers;
  final bool? isAscending;

  _QuizQuestion({
    required this.type,
    required this.question,
    required this.numbers,
    required this.options,
    required this.correctAnswer,
    this.displayNumbers,
    this.isAscending,
  });
}
