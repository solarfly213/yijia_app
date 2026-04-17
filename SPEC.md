# 「忆家」— 老年人认知训练 App

## 1. 项目概述

- **项目名称**：忆家 (YiJia)
- **类型**：Android 认知训练与回忆疗法应用
- **核心功能**：通过家人照片回忆、益智游戏、音乐互动等方式，帮助老年人维持和提升认知能力
- **目标用户**：轻中度认知障碍老年人及其照护者
- **平台**：Android 手机（主），可扩展至平板

---

## 2. 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter 3.x |
| 语言 | Dart |
| 状态管理 | flutter_bloc (BLoC pattern) |
| 本地数据库 | sqflite + path_provider |
| 图片存储 | 用户相册目录（应用私有目录） |
| 架构 | Clean Architecture（presentation/domain/data） |

---

## 3. UI/UX 设计规范

### 3.1 视觉风格
- **风格**：简洁、温暖、老年友好
- **设计语言**：Material Design 3，大圆角，扁平化图标
- **字体**：系统默认粗体，中文字体优先

### 3.2 色彩系统
```
主色（Primary）：#4A90A4（沉稳蓝绿，镇定感）
次色（Secondary）：#F5A623（暖橙，温暖亲切）
背景色：#FAFAFA（淡灰白，减少眼睛疲劳）
文字色：#333333（深灰，高对比度）
卡片色：#FFFFFF
成功色：#7CB342（柔和绿）
提示色：#FF8A65（柔和橙）
```

### 3.3 布局规范
- **大触摸目标**：最小 56dp，所有按钮/卡片
- **间距宽松**：16dp 基础间距，24dp 模块间距
- **底部导航**：4个主要入口，图标+文字
- **卡片圆角**：16dp
- **阴影柔和**：elevation 2-4

### 3.4 老年人友好设计
- 字体大小：标题 24sp，正文 18sp，最小 16sp
- 按钮高度：最低 56dp
- 操作简单：每个页面一个主要动作
- 明确反馈：操作后有视觉/声音提示
- 可调节设置：字体大小、音量

---

## 4. 功能模块

### 4.1 首页 (Home)
- 今日日期显示（大字号）
- 每日一句话/问候语
- 4个主要模块快捷入口（大卡片）
- 今日训练时长统计

### 4.2 照片回忆 (Photo Memory)
**4.2.1 家庭成员管理**
- 添加家庭成员（姓名、关系、照片）
- 成员列表展示
- 照片按成员分类

**4.2.2 照片墙**
- 照片网格展示
- 点击看大图
- 长按删除

**4.2.3 照片配对游戏**
- 两张相似照片匹配
- 难度可选：2对/4对/6对
- 计时+得分

**4.2.4 照片故事**
- 随机选一张照片
- 引导用户讲述照片中的故事
- 录音保存（可选）

### 4.3 益智游戏 (Puzzles)
**4.3.1 记忆卡牌**
- 翻牌记忆游戏
- 图案为家庭成员照片/简单图形
- 可选难度：4张/8张/12张

**4.3.2 拼图游戏**
- 简单滑块拼图（3x3）
- 数字/图形认知

**4.3.3 数字认知**
- 数字排序（从小到大/从大到小）
- 简单加减法
- 认识时间（指针时钟）

### 4.4 时间定向 (Orientation)
- 今日日期（大字显示年月日星期）
- 当前时间（实时更新）
- 季节识别（配图）
- 节日认知（传统节日介绍）
- 早上/下午/晚上区分

### 4.5 音乐回忆 (Music)
**4.5.1 老歌播放**
- 内置经典老歌列表（需联网或本地MP3）
- 播放控制简单（大按钮）

**4.5.2 音乐互动**
- 跟唱/打拍子节奏游戏
- 简单节拍点击

### 4.6 语言训练 (Language)
**4.6.1 看图说词**
- 展示图片，说出物品名称
- 语音反馈（如有TTS）

**4.6.2 造句练习**
- 简单句式模板
- 填词游戏

### 4.7 个人中心 (Settings)
- 头像/用户名设置
- 字体大小调节
- 训练记录查看
- 数据备份/导出
- 关于/帮助

---

## 5. 数据模型

### 5.1 核心实体

```dart
// 家庭成员
class FamilyMember {
  String id;
  String name;          // 姓名
  String relationship;  // 关系（父亲、母亲、儿子...）
  List<String> photoUrls;  // 照片路径列表
  DateTime createdAt;
}

// 训练记录
class TrainingRecord {
  String id;
  String module;        // 模块名
  String activity;     // 活动类型
  int score;           // 得分
  int durationSeconds; // 时长
  DateTime completedAt;
}

// 用户设置
class UserSettings {
  double fontScale;     // 字体缩放 1.0-1.5
  double soundVolume;  // 音量 0.0-1.0
  bool hapticFeedback; // 触感反馈
}
```

### 5.2 本地存储
- **数据库**：SQLite（训练记录、成员信息、设置）
- **文件存储**：应用私有目录（照片副本）

---

## 6. 项目结构 (Clean Architecture)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   └── strings.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── date_utils.dart
├── data/
│   ├── models/
│   │   ├── family_member_model.dart
│   │   ├── training_record_model.dart
│   │   └── user_settings_model.dart
│   ├── repositories/
│   │   ├── family_repository_impl.dart
│   │   ├── training_repository_impl.dart
│   │   └── settings_repository_impl.dart
│   └── datasources/
│       └── local_database.dart
├── domain/
│   ├── entities/
│   │   ├── family_member.dart
│   │   ├── training_record.dart
│   │   └── user_settings.dart
│   ├── repositories/
│   │   ├── family_repository.dart
│   │   ├── training_repository.dart
│   │   └── settings_repository.dart
│   └── usecases/
│       ├── family/
│       ├── training/
│       └── settings/
└── presentation/
    ├── blocs/
    │   ├── family/
    │   ├── training/
    │   └── settings/
    ├── pages/
    │   ├── home/
    │   ├── photo_memory/
    │   ├── puzzles/
    │   ├── orientation/
    │   ├── music/
    │   ├── language/
    │   └── settings/
    └── widgets/
        ├── common/
        ├── cards/
        └── buttons/
```

---

## 7. 依赖 (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3
  image_picker: ^1.0.4
  permission_handler: ^11.0.1
  audioplayers: ^5.2.1
  shared_preferences: ^2.2.2
  uuid: ^4.2.1
  intl: ^0.18.1
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

---

## 8. 开发计划

### Phase 1：基础框架 ✅
- [x] 项目创建与依赖配置
- [x] Clean Architecture 目录结构
- [x] 主题与常量定义
- [x] 底部导航框架

### Phase 2：核心功能
- [ ] 家庭成员管理（CRUD）
- [ ] 照片上传与展示
- [ ] SQLite 数据库集成

### Phase 3：训练模块
- [ ] 照片配对游戏
- [ ] 记忆卡牌游戏
- [ ] 时间定向页面
- [ ] 简单拼图

### Phase 4：完善
- [ ] 音乐播放（本地）
- [ ] 语言训练
- [ ] 设置与数据管理

---

*最后更新：2026-04-17*
