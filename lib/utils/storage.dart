import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  GameStorage._internal();
  static final GameStorage instance = GameStorage._internal();

  static const String _highScoreKey = 'high_score';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ---------------- High Score ----------------
  Future<int> getHighScore() async {
    await init();
    return _prefs!.getInt(_highScoreKey) ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    await init();
    await _prefs!.setInt(_highScoreKey, score);
  }

  // ---------------- Settings ----------------
  Future<bool> getSoundEnabled() async {
    await init();
    return _prefs!.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await init();
    await _prefs!.setBool(_soundEnabledKey, enabled);
  }

  Future<bool> getMusicEnabled() async {
    await init();
    return _prefs!.getBool(_musicEnabledKey) ?? true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await init();
    await _prefs!.setBool(_musicEnabledKey, enabled);
  }

  Future<bool> getVibrationEnabled() async {
    await init();
    return _prefs!.getBool(_vibrationEnabledKey) ?? true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await init();
    await _prefs!.setBool(_vibrationEnabledKey, enabled);
  }

  // ---------------- Clear ----------------
  Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }
}
