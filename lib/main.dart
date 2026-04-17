import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/strings.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/family/family_bloc.dart';
import 'presentation/blocs/training/training_bloc.dart';
import 'presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置系统UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 锁定竖屏方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const YiJiaApp());
}

/// 忆家 App 根组件
class YiJiaApp extends StatelessWidget {
  const YiJiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc()..add(LoadSettings()),
        ),
        BlocProvider<FamilyBloc>(
          create: (context) => FamilyBloc()..add(LoadFamilyMembers()),
        ),
        BlocProvider<TrainingBloc>(
          create: (context) => TrainingBloc()..add(LoadTodayTraining()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          // 应用字体缩放
          if (state is SettingsLoaded) {
            AppTheme.fontScale = state.settings.fontScale;
          }

          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const MainPage(),
          );
        },
      ),
    );
  }
}
