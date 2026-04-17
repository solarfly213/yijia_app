part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class SettingsInitial extends SettingsState {}

/// 加载中
class SettingsLoading extends SettingsState {}

/// 已加载
class SettingsLoaded extends SettingsState {
  final UserSettings settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// 加载失败
class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
