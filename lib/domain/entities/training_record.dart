import 'package:equatable/equatable.dart';

/// 训练记录实体
class TrainingRecord extends Equatable {
  final String id;
  final String module;       // 模块：photo, puzzle, orientation, music, language
  final String activity;     // 活动类型
  final int score;           // 得分
  final int durationSeconds; // 用时（秒）
  final DateTime completedAt;

  const TrainingRecord({
    required this.id,
    required this.module,
    required this.activity,
    required this.score,
    required this.durationSeconds,
    required this.completedAt,
  });

  TrainingRecord copyWith({
    String? id,
    String? module,
    String? activity,
    int? score,
    int? durationSeconds,
    DateTime? completedAt,
  }) {
    return TrainingRecord(
      id: id ?? this.id,
      module: module ?? this.module,
      activity: activity ?? this.activity,
      score: score ?? this.score,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// 获取格式化的用时字符串
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [id, module, activity, score, durationSeconds, completedAt];
}

/// 模块类型
enum TrainingModule {
  photo('照片回忆', 'photo'),
  puzzle('益智游戏', 'puzzle'),
  orientation('时间定向', 'orientation'),
  music('音乐回忆', 'music'),
  language('语言训练', 'language');

  final String label;
  final String value;

  const TrainingModule(this.label, this.value);

  static TrainingModule fromValue(String value) {
    return TrainingModule.values.firstWhere(
      (m) => m.value == value,
      orElse: () => TrainingModule.puzzle,
    );
  }
}
