import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  static const String _highScoreKey = 'high_score';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  
  // ❌ المشكلة: _prefs هو late لكن init() لا يُستدعى قبل استخدامه
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  
  // ✅ دالة تهيئة يجب استدعاؤها أولاً
  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }
  
  // ✅ دالة مساعدة للتأكد من التهيئة
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }
  
  // High Score
  Future<int> getHighScore() async {
    await _ensureInitialized();
    return _prefs.getInt(_highScoreKey) ?? 0;
  }
  
  Future<void> saveHighScore(int score) async {
    await _ensureInitialized();
    await _prefs.setInt(_highScoreKey, score);
  }
  
  // Settings
  Future<bool> getSoundEnabled() async {
    await _ensureInitialized();  // ✅ أضف هذا
    return _prefs.getBool(_soundEnabledKey) ?? true;
  }
  
  Future<void> setSoundEnabled(bool enabled) async {
    await _ensureInitialized();  // ✅ أضف هذا
    await _prefs.setBool(_soundEnabledKey, enabled);
  }
  
  Future<bool> getMusicEnabled() async {
    await _ensureInitialized();  // ✅ أضف هذا
    return _prefs.getBool(_musicEnabledKey) ?? true;
  }
  
  Future<void> setMusicEnabled(bool enabled) async {
    await _ensureInitialized();  // ✅ أضف هذا
    await _prefs.setBool(_musicEnabledKey, enabled);
  }
  
  Future<bool> getVibrationEnabled() async {
    await _ensureInitialized();  // ✅ أضف هذا
    return _prefs.getBool(_vibrationEnabledKey) ?? true;
  }
  
  Future<void> setVibrationEnabled(bool enabled) async {
    await _ensureInitialized();  // ✅ أضف هذا
    await _prefs.setBool(_vibrationEnabledKey, enabled);
  }
  
  // Clear all data
  Future<void> clearAll() async {
    await _ensureInitialized();  // ✅ أضف هذا
    await _prefs.clear();
  }
}