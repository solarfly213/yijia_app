part of 'family_bloc.dart';

abstract class FamilyState extends Equatable {
  const FamilyState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class FamilyInitial extends FamilyState {}

/// 加载中
class FamilyLoading extends FamilyState {}

/// 已加载
class FamilyLoaded extends FamilyState {
  final List<FamilyMember> members;

  const FamilyLoaded(this.members);

  /// 获取所有照片
  List<String> get allPhotos {
    return members.expand((m) => m.photoUrls).toList();
  }

  /// 根据ID获取成员
  FamilyMember? getMemberById(String id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [members];
}

/// 加载失败
class FamilyError extends FamilyState {
  final String message;

  const FamilyError(this.message);

  @override
  List<Object?> get props => [message];
}
