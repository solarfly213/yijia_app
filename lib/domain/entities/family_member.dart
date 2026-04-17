import 'package:equatable/equatable.dart';

/// 家庭成员实体
class FamilyMember extends Equatable {
  final String id;
  final String name;
  final String relationship;
  final List<String> photoUrls;
  final DateTime createdAt;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.photoUrls,
    required this.createdAt,
  });

  FamilyMember copyWith({
    String? id,
    String? name,
    String? relationship,
    List<String>? photoUrls,
    DateTime? createdAt,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, relationship, photoUrls, createdAt];
}
