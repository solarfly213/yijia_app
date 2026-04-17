part of 'family_bloc.dart';

abstract class FamilyEvent extends Equatable {
  const FamilyEvent();

  @override
  List<Object?> get props => [];
}

/// 加载家庭成员列表
class LoadFamilyMembers extends FamilyEvent {}

/// 添加家庭成员
class AddFamilyMember extends FamilyEvent {
  final String name;
  final String relationship;
  final List<String> photoUrls;

  const AddFamilyMember({
    required this.name,
    required this.relationship,
    required this.photoUrls,
  });

  @override
  List<Object?> get props => [name, relationship, photoUrls];
}

/// 更新家庭成员
class UpdateFamilyMember extends FamilyEvent {
  final FamilyMember member;

  const UpdateFamilyMember(this.member);

  @override
  List<Object?> get props => [member];
}

/// 删除家庭成员
class DeleteFamilyMember extends FamilyEvent {
  final String memberId;

  const DeleteFamilyMember(this.memberId);

  @override
  List<Object?> get props => [memberId];
}

/// 添加照片到成员
class AddPhotoToMember extends FamilyEvent {
  final String memberId;
  final String photoUrl;

  const AddPhotoToMember({
    required this.memberId,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [memberId, photoUrl];
}

/// 从成员删除照片
class RemovePhotoFromMember extends FamilyEvent {
  final String memberId;
  final String photoUrl;

  const RemovePhotoFromMember({
    required this.memberId,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [memberId, photoUrl];
}
