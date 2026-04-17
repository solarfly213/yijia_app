import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/family_member.dart';
import '../../blocs/family/family_bloc.dart';
import '../../widgets/gradient_card.dart';

/// 照片回忆页面
class PhotoMemoryPage extends StatefulWidget {
  const PhotoMemoryPage({super.key});

  @override
  State<PhotoMemoryPage> createState() => _PhotoMemoryPageState();
}

class _PhotoMemoryPageState extends State<PhotoMemoryPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.photoMemory),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate, size: 28),
            onPressed: _showAddPhotoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab 切换
          _buildTabBar(),

          // Tab 内容
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberDialog,
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.person_add),
        label: const Text(AppStrings.addMember),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(0, Icons.people, AppStrings.familyMembers),
          _buildTabItem(1, Icons.photo_library, AppStrings.photoWall),
          _buildTabItem(2, Icons.extension, AppStrings.photoMatching),
          _buildTabItem(3, Icons.auto_stories, AppStrings.photoStory),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTab = index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildFamilyMembersList();
      case 1:
        return _buildPhotoWall();
      case 2:
        return _buildPhotoMatching();
      case 3:
        return _buildPhotoStory();
      default:
        return _buildFamilyMembersList();
    }
  }

  /// 家庭成员列表
  Widget _buildFamilyMembersList() {
    return BlocBuilder<FamilyBloc, FamilyState>(
      builder: (context, state) {
        if (state is FamilyLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FamilyLoaded) {
          if (state.members.isEmpty) {
            return _buildEmptyState(
              icon: Icons.people_outline,
              message: '还没有添加家庭成员\n点击右下角添加',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: state.members.length,
            itemBuilder: (context, index) {
              return _buildMemberCard(state.members[index]);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildMemberCard(FamilyMember member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primary,
          backgroundImage: member.photoUrls.isNotEmpty
              ? FileImage(_getImageFile(member.photoUrls.first))
              : null,
          child: member.photoUrls.isEmpty
              ? const Icon(Icons.person, color: Colors.white, size: 32)
              : null,
        ),
        title: Text(
          member.name,
          style: AppTheme.scaledTextStyle(const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
        ),
        subtitle: Text(
          '${member.relationship} · ${member.photoUrls.length}张照片',
          style: AppTheme.scaledTextStyle(const TextStyle(fontSize: 16)),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'add_photo') {
              _addPhotoForMember(member);
            } else if (value == 'delete') {
              _deleteMember(member);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'add_photo',
              child: Row(
                children: [
                  Icon(Icons.add_photo_alternate),
                  SizedBox(width: 8),
                  Text(AppStrings.addPhoto),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 照片墙
  Widget _buildPhotoWall() {
    return BlocBuilder<FamilyBloc, FamilyState>(
      builder: (context, state) {
        if (state is FamilyLoaded) {
          final allPhotos = state.allPhotos;
          if (allPhotos.isEmpty) {
            return _buildEmptyState(
              icon: Icons.photo_library_outlined,
              message: '还没有照片\n请先添加家庭成员和照片',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: allPhotos.length,
            itemBuilder: (context, index) {
              return _buildPhotoTile(allPhotos[index]);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildPhotoTile(String photoPath) {
    return GestureDetector(
      onTap: () => _showPhotoViewer(photoPath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _getImageFile(photoPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primary.withOpacity(0.2),
              child: const Icon(
                Icons.broken_image,
                color: AppColors.primary,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  /// 照片配对
  Widget _buildPhotoMatching() {
    return BlocBuilder<FamilyBloc, FamilyState>(
      builder: (context, state) {
        if (state is FamilyLoaded) {
          final photos = state.allPhotos;
          if (photos.length < 2) {
            return _buildEmptyState(
              icon: Icons.extension,
              message: '照片数量不足\n请先添加至少2张照片',
            );
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.extension,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.photoMatching,
                    style: AppTheme.scaledTextStyle(const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '将相同的照片配对\n锻炼记忆力和观察力',
                    textAlign: TextAlign.center,
                    style: AppTheme.scaledTextStyle(const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    )),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoMatchingGame(photos: photos),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(AppStrings.start),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 64),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  /// 照片故事
  Widget _buildPhotoStory() {
    return BlocBuilder<FamilyBloc, FamilyState>(
      builder: (context, state) {
        if (state is FamilyLoaded) {
          final photos = state.allPhotos;
          if (photos.isEmpty) {
            return _buildEmptyState(
              icon: Icons.auto_stories,
              message: '还没有照片\n请先添加照片',
            );
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_stories,
                    size: 80,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.photoStory,
                    style: AppTheme.scaledTextStyle(const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '选择一张照片\n讲述照片背后的故事',
                    textAlign: TextAlign.center,
                    style: AppTheme.scaledTextStyle(const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    )),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoStoryPage(photos: photos),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(AppStrings.start),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 64),
                      backgroundColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTheme.scaledTextStyle(const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            )),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    String selectedRelationship = AppStrings.relationships.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.addMember),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.name,
                hintText: '请输入姓名',
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButtonFormField<String>(
                  value: selectedRelationship,
                  decoration: const InputDecoration(
                    labelText: AppStrings.relationship,
                  ),
                  items: AppStrings.relationships.map((r) {
                    return DropdownMenuItem(value: r, child: Text(r));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedRelationship = value!);
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<FamilyBloc>().add(AddFamilyMember(
                  name: nameController.text,
                  relationship: selectedRelationship,
                  photoUrls: [],
                ));
                Navigator.pop(context);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showAddPhotoDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, size: 28),
              title: const Text('拍照', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 28),
              title: const Text('从相册选择', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addPhotoForMember(FamilyMember member) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<FamilyBloc>().add(AddPhotoToMember(
        memberId: member.id,
        photoUrl: image.path,
      ));
    }
  }

  void _deleteMember(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除${member.name}吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FamilyBloc>().add(DeleteFamilyMember(member.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showPhotoViewer(String photoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(_getImageFile(photoPath)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null && mounted) {
      // 添加到第一个成员或创建新成员
      final familyState = context.read<FamilyBloc>().state;
      if (familyState is FamilyLoaded && familyState.members.isNotEmpty) {
        context.read<FamilyBloc>().add(AddPhotoToMember(
          memberId: familyState.members.first.id,
          photoUrl: image.path,
        ));
      }
    }
  }

  File _getImageFile(String path) => File(path);
}

// 导入需要的类
import 'dart:io';
import 'photo_matching_game.dart';
import 'photo_story_page.dart';
