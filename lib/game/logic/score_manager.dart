import 'package:blickgame/utils/storage.dart';

class ScoreManager {
  int currentScore = 0;
  int highScore = 0;
  int currentCombo = 0;
  int maxCombo = 0;
  
  final GameStorage storage;
  bool _isInitialized = false;
  
  ScoreManager(this.storage) {
    // ❌ لا تستدعي loadHighScore() هنا
    // لأن storage قد لا يكون مهيئاً بعد
  }
  
  // ✅ دالة منفصلة للتهيئة
  Future<void> init() async {
    if (!_isInitialized) {
      await storage.init(); // تأكد من تهيئة storage أولاً
      await loadHighScore();
      _isInitialized = true;
    }
  }
  
  void addScore(int points) {
    currentScore += points;
    if (points > 0) {
      currentCombo++;
      maxCombo = currentCombo > maxCombo ? currentCombo : maxCombo;
    } else {
      resetCombo();
    }
    
    // Update high score if needed
    if (currentScore > highScore) {
      highScore = currentScore;
      saveHighScore();
    }
  }
  
  void resetCombo() {
    currentCombo = 0;
  }
  
  Future<void> loadHighScore() async {
    highScore = await storage.getHighScore();
  }
  
  Future<void> saveHighScore() async {
    await storage.saveHighScore(highScore);
  }
  
  void reset() {
    currentScore = 0;
    currentCombo = 0;
    maxCombo = 0;
  }
}