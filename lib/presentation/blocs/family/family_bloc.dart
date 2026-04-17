import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/family_member.dart';

part 'family_event.dart';
part 'family_state.dart';

/// 家庭成员 BLoC
class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final _uuid = const Uuid();

  // 模拟数据存储（生产环境应使用 SQLite）
  static final List<FamilyMember> _mockMembers = [
    FamilyMember(
      id: '1',
      name: '张三',
      relationship: '父亲',
      photoUrls: [],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    FamilyMember(
      id: '2',
      name: '李四',
      relationship: '母亲',
      photoUrls: [],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  FamilyBloc() : super(FamilyInitial()) {
    on<LoadFamilyMembers>(_onLoadFamilyMembers);
    on<AddFamilyMember>(_onAddFamilyMember);
    on<UpdateFamilyMember>(_onUpdateFamilyMember);
    on<DeleteFamilyMember>(_onDeleteFamilyMember);
    on<AddPhotoToMember>(_onAddPhotoToMember);
    on<RemovePhotoFromMember>(_onRemovePhotoFromMember);
  }

  Future<void> _onLoadFamilyMembers(
    LoadFamilyMembers event,
    Emitter<FamilyState> emit,
  ) async {
    emit(FamilyLoading());
    try {
      // 模拟加载延迟
      await Future.delayed(const Duration(milliseconds: 300));
      emit(FamilyLoaded(_mockMembers));
    } catch (e) {
      emit(FamilyError(e.toString()));
    }
  }

  Future<void> _onAddFamilyMember(
    AddFamilyMember event,
    Emitter<FamilyState> emit,
  ) async {
    final currentState = state;
    if (currentState is FamilyLoaded) {
      final newMember = FamilyMember(
        id: _uuid.v4(),
        name: event.name,
        relationship: event.relationship,
        photoUrls: event.photoUrls,
        createdAt: DateTime.now(),
      );
      final updatedMembers = [...currentState.members, newMember];
      emit(FamilyLoaded(updatedMembers));
    }
  }

  Future<void> _onUpdateFamilyMember(
    UpdateFamilyMember event,
    Emitter<FamilyState> emit,
  ) async {
    final currentState = state;
    if (currentState is FamilyLoaded) {
      final updatedMembers = currentState.members.map((m) {
        if (m.id == event.member.id) {
          return event.member;
        }
        return m;
      }).toList();
      emit(FamilyLoaded(updatedMembers));
    }
  }

  Future<void> _onDeleteFamilyMember(
    DeleteFamilyMember event,
    Emitter<FamilyState> emit,
  ) async {
    final currentState = state;
    if (currentState is FamilyLoaded) {
      final updatedMembers = currentState.members.where((m) => m.id != event.memberId).toList();
      emit(FamilyLoaded(updatedMembers));
    }
  }

  Future<void> _onAddPhotoToMember(
    AddPhotoToMember event,
    Emitter<FamilyState> emit,
  ) async {
    final currentState = state;
    if (currentState is FamilyLoaded) {
      final updatedMembers = currentState.members.map((m) {
        if (m.id == event.memberId) {
          return m.copyWith(photoUrls: [...m.photoUrls, event.photoUrl]);
        }
        return m;
      }).toList();
      emit(FamilyLoaded(updatedMembers));
    }
  }

  Future<void> _onRemovePhotoFromMember(
    RemovePhotoFromMember event,
    Emitter<FamilyState> emit,
  ) async {
    final currentState = state;
    if (currentState is FamilyLoaded) {
      final updatedMembers = currentState.members.map((m) {
        if (m.id == event.memberId) {
          return m.copyWith(
            photoUrls: m.photoUrls.where((p) => p != event.photoUrl).toList(),
          );
        }
        return m;
      }).toList();
      emit(FamilyLoaded(updatedMembers));
    }
  }
}
