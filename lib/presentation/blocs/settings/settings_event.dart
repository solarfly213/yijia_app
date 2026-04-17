part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// 加载设置
class LoadSettings extends SettingsEvent {}

/// 更新字体缩放
class UpdateFontScale extends SettingsEvent {
  final double fontScale;

  const UpdateFontScale(this.fontScale);

  @override
  List<Object?> get props => [fontScale];
}

/// 更新音量
class UpdateSoundVolume extends SettingsEvent {
  final double volume;

  const UpdateSoundVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// 更新触感反馈
class UpdateHapticFeedback extends SettingsEvent {
  final bool enabled;

  const UpdateHapticFeedback(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// 更新用户名
class UpdateUserName extends SettingsEvent {
  final String name;

  const UpdateUserName(this.name);

  @override
  List<Object?> get props => [name];
}

/// 更新用户头像
class UpdateUserAvatar extends SettingsEvent {
  final String avatarPath;

  const UpdateUserAvatar(this.avatarPath);

  @override
  List<Object?> get props => [avatarPath];
}
