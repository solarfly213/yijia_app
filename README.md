# 忆家 (YiJia) - 老年人认知训练 App

一款帮助老年人维持和提升认知能力的 Android 应用，通过照片回忆、益智游戏、音乐互动等方式进行认知训练。

## 功能特点

### 🏠 首页
- 每日问候语
- 大字号日期显示
- 今日训练概览（时长、得分）
- 模块快捷入口

### 📸 照片回忆
- **家庭成员管理** - 添加家人信息（姓名、关系、照片）
- **照片墙** - 照片网格展示，点击放大
- **照片配对游戏** - 记忆配对，锻炼短期记忆
- **照片故事** - 讲述照片背后的故事，锻炼语言表达能力

### 🧩 益智游戏
- **记忆卡牌** - 翻牌记忆游戏
- **数字认知** - 数字排序、简单加减法
- **拼图游戏** - 滑块拼图（开发中）
- **认识时钟** - 看时钟说时间（开发中）

### 📅 时间定向
- 今日日期显示
- 星期、季节识别
- 节日认知

### 🎵 音乐回忆
- 经典老歌播放（开发中）
- 节奏游戏（开发中）

### ⚙️ 设置
- 字体大小调节（1.0x - 1.5x）
- 音量控制
- 触感反馈开关
- 训练记录查看
- 数据备份

## 技术栈

- **框架**: Flutter 3.x
- **状态管理**: flutter_bloc (BLoC 模式)
- **架构**: Clean Architecture
- **本地存储**: SharedPreferences
- **图片选择**: image_picker

## 项目结构

```
yijia_app/
├── lib/
│   ├── main.dart                    # 入口文件
│   ├── core/
│   │   ├── constants/               # 常量定义
│   │   │   ├── colors.dart          # 色彩系统
│   │   │   └── strings.dart         # 字符串资源
│   │   └── theme/
│   │       └── app_theme.dart       # 主题配置
│   ├── domain/
│   │   └── entities/                # 业务实体
│   │       ├── family_member.dart
│   │       ├── training_record.dart
│   │       └── user_settings.dart
│   └── presentation/
│       ├── blocs/                   # 状态管理
│       │   ├── family/
│       │   ├── settings/
│       │   └── training/
│       ├── pages/                   # 页面
│       │   ├── home/
│       │   ├── photo_memory/
│       │   ├── puzzles/
│       │   └── settings/
│       └── widgets/                 # 公共组件
│           ├── gradient_card.dart
│           └── date_display.dart
├── android/                         # Android 配置
└── pubspec.yaml                     # 依赖配置
```

## 快速开始

### 环境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK

### 安装步骤

1. **克隆项目**
```bash
cd yijia_app
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
flutter run
```

### 构建 APK

```bash
# Debug 版本
flutter build apk --debug

# Release 版本
flutter build apk --release
```

APK 文件会生成在 `build/app/outputs/flutter-apk/` 目录

## 设计规范

### 老年人友好设计原则

1. **大触摸目标** - 所有按钮/卡片最小 56dp
2. **高对比度** - 文字与背景对比度 >= 4.5:1
3. **大字体** - 默认 18sp，可调节至 24sp
4. **简洁界面** - 每个页面一个主要动作
5. **明确反馈** - 操作后有视觉/声音提示
6. **操作简单** - 避免复杂手势，支持点击

### 色彩系统

| 用途 | 颜色 |
|------|------|
| 主色（镇定） | #4A90A4 |
| 次色（温暖） | #F5A623 |
| 背景 | #FAFAFA |
| 文字 | #333333 |
| 成功 | #7CB342 |
| 提示 | #FF8A65 |

## 开发说明

### 添加新模块

1. 在 `domain/entities/` 添加实体
2. 在 `data/` 添加仓库实现
3. 在 `presentation/blocs/` 添加 BLoC
4. 在 `presentation/pages/` 添加页面
5. 更新 `main_page.dart` 底部导航

### 添加新游戏

1. 在 `presentation/pages/puzzles/` 创建游戏页面
2. 使用 BLoC 管理游戏状态
3. 游戏完成后调用 `TrainingBloc` 记录成绩

## TODO

- [ ] SQLite 数据库集成（替代模拟数据）
- [ ] 照片本地存储优化
- [ ] 音乐播放功能
- [ ] 录音功能（照片故事）
- [ ] 数据导出/导入
- [ ] 平板适配 UI
- [ ] 多语言支持

## 许可证

MIT License

## 联系方式

如有问题或建议，欢迎提出 Issue。
