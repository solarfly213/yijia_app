import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/training_record.dart';

part 'training_event.dart';
part 'training_state.dart';

/// 训练记录 BLoC
class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  final _uuid = const Uuid();

  // 模拟数据存储
  static final List<TrainingRecord> _allRecords = [];

  TrainingBloc() : super(TrainingInitial()) {
    on<LoadTodayTraining>(_onLoadTodayTraining);
    on<LoadAllTraining>(_onLoadAllTraining);
    on<AddTrainingRecord>(_onAddTrainingRecord);
    on<ClearTrainingRecords>(_onClearTrainingRecords);
  }

  Future<void> _onLoadTodayTraining(
    LoadTodayTraining event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final todayRecords = _getTodayRecords();
      final todayMinutes = _calculateTodayMinutes(todayRecords);
      final todayScore = _calculateTodayScore(todayRecords);
      emit(TrainingLoaded(
        todayRecords: todayRecords,
        allRecords: _allRecords,
        todayTotalMinutes: todayMinutes,
        todayTotalScore: todayScore,
      ));
    } catch (e) {
      emit(TrainingError(e.toString()));
    }
  }

  Future<void> _onLoadAllTraining(
    LoadAllTraining event,
    Emitter<TrainingState> emit,
  ) async {
    final currentState = state;
    if (currentState is TrainingLoaded) {
      emit(TrainingLoaded(
        todayRecords: _getTodayRecords(),
        allRecords: _allRecords,
        todayTotalMinutes: currentState.todayTotalMinutes,
        todayTotalScore: currentState.todayTotalScore,
      ));
    }
  }

  Future<void> _onAddTrainingRecord(
    AddTrainingRecord event,
    Emitter<TrainingState> emit,
  ) async {
    final newRecord = TrainingRecord(
      id: _uuid.v4(),
      module: event.module,
      activity: event.activity,
      score: event.score,
      durationSeconds: event.durationSeconds,
      completedAt: DateTime.now(),
    );
    _allRecords.add(newRecord);

    final todayRecords = _getTodayRecords();
    final todayMinutes = _calculateTodayMinutes(todayRecords);
    final todayScore = _calculateTodayScore(todayRecords);

    emit(TrainingLoaded(
      todayRecords: todayRecords,
      allRecords: _allRecords,
      todayTotalMinutes: todayMinutes,
      todayTotalScore: todayScore,
    ));
  }

  Future<void> _onClearTrainingRecords(
    ClearTrainingRecords event,
    Emitter<TrainingState> emit,
  ) async {
    _allRecords.clear();
    emit(const TrainingLoaded(
      todayRecords: [],
      allRecords: [],
      todayTotalMinutes: 0,
      todayTotalScore: 0,
    ));
  }

  List<TrainingRecord> _getTodayRecords() {
    final today = DateTime.now();
    return _allRecords.where((r) {
      return r.completedAt.year == today.year &&
          r.completedAt.month == today.month &&
          r.completedAt.day == today.day;
    }).toList();
  }

  int _calculateTodayMinutes(List<TrainingRecord> records) {
    final totalSeconds = records.fold<int>(
      0,
      (sum, r) => sum + r.durationSeconds,
    );
    return (totalSeconds / 60).ceil();
  }

  int _calculateTodayScore(List<TrainingRecord> records) {
    return records.fold<int>(0, (sum, r) => sum + r.score);
  }
}
