import 'package:blickgame/utils/storage.dart';

class ScoreManager {
  int score = 0;
  int highScore = 0;
  int combo = 0;
  int maxCombo = 0;

  final GameStorage storage;
  bool _ready = false;

  ScoreManager(this.storage);

  Future<void> init() async {
    if (_ready) return;
    await storage.init();
    highScore = await storage.getHighScore();
    _ready = true;
  }

  void add(int points) {
    score += points;

    if (points > 0) {
      combo++;
      if (combo > maxCombo) maxCombo = combo;
    } else {
      combo = 0;
    }

    if (score > highScore) {
      highScore = score;
      storage.saveHighScore(highScore);
    }
  }

  void reset() {
    score = 0;
    combo = 0;
    maxCombo = 0;
  }
}