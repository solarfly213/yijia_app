part of 'training_bloc.dart';

abstract class TrainingState extends Equatable {
  const TrainingState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class TrainingInitial extends TrainingState {}

/// 加载中
class TrainingLoading extends TrainingState {}

/// 已加载
class TrainingLoaded extends TrainingState {
  final List<TrainingRecord> todayRecords;
  final List<TrainingRecord> allRecords;
  final int todayTotalMinutes;
  final int todayTotalScore;

  const TrainingLoaded({
    required this.todayRecords,
    required this.allRecords,
    required this.todayTotalMinutes,
    required this.todayTotalScore,
  });

  /// 今日模块完成情况
  Map<TrainingModule, bool> get todayModuleCompletion {
    final todayModules = todayRecords.map((r) => TrainingModule.fromValue(r.module)).toSet();
    return {
      for (var module in TrainingModule.values)
        module: todayModules.contains(module),
    };
  }

  @override
  List<Object?> get props => [todayRecords, allRecords, todayTotalMinutes, todayTotalScore];
}

/// 加载失败
class TrainingError extends TrainingState {
  final String message;

  const TrainingError(this.message);

  @override
  List<Object?> get props => [message];
}
