import 'package:equatable/equatable.dart';

/// 用户设置实体
class UserSettings extends Equatable {
  final double fontScale;      // 字体缩放 1.0-1.5
  final double soundVolume;    // 音量 0.0-1.0
  final bool hapticFeedback;  // 触感反馈
  final String userName;       // 用户名
  final String userAvatar;     // 用户头像路径

  const UserSettings({
    this.fontScale = 1.0,
    this.soundVolume = 0.8,
    this.hapticFeedback = true,
    this.userName = '',
    this.userAvatar = '',
  });

  UserSettings copyWith({
    double? fontScale,
    double? soundVolume,
    bool? hapticFeedback,
    String? userName,
    String? userAvatar,
  }) {
    return UserSettings(
      fontScale: fontScale ?? this.fontScale,
      soundVolume: soundVolume ?? this.soundVolume,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  /// 获取字体大小描述
  String get fontSizeLabel {
    if (fontScale <= 1.0) return '标准';
    if (fontScale <= 1.2) return '中等';
    return '大';
  }

  @override
  List<Object?> get props => [fontScale, soundVolume, hapticFeedback, userName, userAvatar];
}
