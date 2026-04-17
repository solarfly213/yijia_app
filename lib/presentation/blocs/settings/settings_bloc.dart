import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/user_settings.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// 设置 BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _keyFontScale = 'font_scale';
  static const String _keySoundVolume = 'sound_volume';
  static const String _keyHapticFeedback = 'haptic_feedback';
  static const String _keyUserName = 'user_name';
  static const String _keyUserAvatar = 'user_avatar';

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateFontScale>(_onUpdateFontScale);
    on<UpdateSoundVolume>(_onUpdateSoundVolume);
    on<UpdateHapticFeedback>(_onUpdateHapticFeedback);
    on<UpdateUserName>(_onUpdateUserName);
    on<UpdateUserAvatar>(_onUpdateUserAvatar);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = UserSettings(
        fontScale: prefs.getDouble(_keyFontScale) ?? 1.0,
        soundVolume: prefs.getDouble(_keySoundVolume) ?? 0.8,
        hapticFeedback: prefs.getBool(_keyHapticFeedback) ?? true,
        userName: prefs.getString(_keyUserName) ?? '',
        userAvatar: prefs.getString(_keyUserAvatar) ?? '',
      );
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateFontScale(
    UpdateFontScale event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(fontScale: event.fontScale);
      emit(SettingsLoaded(newSettings));
      await _saveSettings(newSettings);
    }
  }

  Future<void> _onUpdateSoundVolume(
    UpdateSoundVolume event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(soundVolume: event.volume);
      emit(SettingsLoaded(newSettings));
      await _saveSettings(newSettings);
    }
  }

  Future<void> _onUpdateHapticFeedback(
    UpdateHapticFeedback event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(hapticFeedback: event.enabled);
      emit(SettingsLoaded(newSettings));
      await _saveSettings(newSettings);
    }
  }

  Future<void> _onUpdateUserName(
    UpdateUserName event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(userName: event.name);
      emit(SettingsLoaded(newSettings));
      await _saveSettings(newSettings);
    }
  }

  Future<void> _onUpdateUserAvatar(
    UpdateUserAvatar event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newSettings = currentState.settings.copyWith(userAvatar: event.avatarPath);
      emit(SettingsLoaded(newSettings));
      await _saveSettings(newSettings);
    }
  }

  Future<void> _saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontScale, settings.fontScale);
    await prefs.setDouble(_keySoundVolume, settings.soundVolume);
    await prefs.setBool(_keyHapticFeedback, settings.hapticFeedback);
    await prefs.setString(_keyUserName, settings.userName);
    await prefs.setString(_keyUserAvatar, settings.userAvatar);
  }
}
