part of 'training_bloc.dart';

abstract class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object?> get props => [];
}

/// 加载今日训练数据
class LoadTodayTraining extends TrainingEvent {}

/// 加载所有训练记录
class LoadAllTraining extends TrainingEvent {}

/// 添加训练记录
class AddTrainingRecord extends TrainingEvent {
  final String module;
  final String activity;
  final int score;
  final int durationSeconds;

  const AddTrainingRecord({
    required this.module,
    required this.activity,
    required this.score,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [module, activity, score, durationSeconds];
}

/// 清除训练记录
class ClearTrainingRecords extends TrainingEvent {}
