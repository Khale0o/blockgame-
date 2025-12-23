import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Matrix4;
import 'package:google_fonts/google_fonts.dart'; // أضف في pubspec.yaml: google_fonts: ^6.1.0
import '../puzzle_game.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ✅ خلفية جزيئات متحركة
            Positioned.fill(
              child: CustomPaint(
                painter: ParticlePainter(),
              ),
            ),
            
            // ✅ أشعة ضوئية
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.cyan.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF419D78).withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 800),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ اللوجو مع تأثير ثلاثي الأبعاد
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(0.1),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            'BLOCK',
                            style: GoogleFonts.orbitron(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              foreground: Paint()
                                ..style = PaintingStyle.fill
                                ..color = Colors.white
                                ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2),
                              letterSpacing: 6,
                            ),
                          ),
                          
                          Stack(
                            children: [
                              // تأثير الظل
                              Text(
                                'PUZZLE',
                                style: GoogleFonts.orbitron(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black.withOpacity(0.3),
                                  letterSpacing: 6,
                                ),
                              ),
                              // النص الرئيسي مع تدرج لوني
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Color(0xFF00DBDE),
                                      Color(0xFFFC00FF),
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  'PUZZLE',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 10),
                    
                    // ✅ وصف اللعبة
                    Text(
                      'Fit the blocks. Clear the grid. Master the puzzle.',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    
                    SizedBox(height: 60),
                    
                    // ✅ الأزرار مع تأثيرات
                    _buildMenuButton(
                      context,
                      title: '🚀 START GAME',
                      icon: Icons.play_arrow_rounded,
                      color: Color(0xFF00DBDE),
                      onPressed: () {
                        _playButtonSound();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => GameWidget(game: PuzzleGame()),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    _buildMenuButton(
                      context,
                      title: '🏆 LEADERBOARD',
                      icon: Icons.leaderboard_rounded,
                      color: Color(0xFF9C27B0),
                      onPressed: () {
                        _playButtonSound();
                        _showLeaderboard(context);
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    _buildMenuButton(
                      context,
                      title: '⚙️ SETTINGS',
                      icon: Icons.settings_rounded,
                      color: Color(0xFF4CAF50),
                      onPressed: () {
                        _playButtonSound();
                        _showSettings(context);
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    _buildMenuButton(
                      context,
                      title: '❓ HOW TO PLAY',
                      icon: Icons.help_rounded,
                      color: Color(0xFFFF9800),
                      onPressed: () {
                        _playButtonSound();
                        _showTutorial(context);
                      },
                    ),
                    
                    SizedBox(height: 40),
                    
                    // ✅ إحصائيات سريعة
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            icon: Icons.star_rounded,
                            value: '1,247',
                            label: 'Players',
                            color: Colors.yellow,
                          ),
                          _buildStatItem(
                            icon: Icons.games_rounded,
                            value: '50+',
                            label: 'Levels',
                            color: Colors.cyan,
                          ),
                          _buildStatItem(
                            icon: Icons.timer_rounded,
                            value: '∞',
                            label: 'Playtime',
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // ✅ حقوق النشر
                    Text(
                      '© 2026 Block Puzzle Master',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.white30,
                      ),
                    ),
                    Text(
                      'v1.0.0 • Made with ❤️',
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuButton(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 280,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          hoverColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.2),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 15),
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Transform.rotate(
                  angle: 180 * 3.14159 / 180,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
  
  void _playButtonSound() {
    // يمكنك إضافة صوت هنا باستخدام audio_player
    // AudioPlayer().play(AssetSource('sounds/click.mp3'));
  }
  
  void _showLeaderboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF203A43),
                Color(0xFF0F2027),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '🏆 LEADERBOARD',
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: index < 3
                              ? LinearGradient(colors: [
                                  Colors.yellow,
                                  Colors.orange,
                                ])
                              : LinearGradient(colors: [
                                  Colors.grey,
                                  Colors.grey.shade800,
                                ]),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        'Player ${index + 1}',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        '${(1000 - index * 100)} pts',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showSettings(BuildContext context) {
    // إضافة إعدادات اللعبة
  }
  
  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2C5364),
                  Color(0xFF203A43),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎮 HOW TO PLAY',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildTutorialStep(
                  number: 1,
                  title: 'DRAG BLOCKS',
                  description: 'Drag blocks from the bottom panel',
                ),
                _buildTutorialStep(
                  number: 2,
                  title: 'FIT THEM IN',
                  description: 'Place them strategically on the grid',
                ),
                _buildTutorialStep(
                  number: 3,
                  title: 'CLEAR LINES',
                  description: 'Complete rows or columns to score points',
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00DBDE),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'GOT IT!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTutorialStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.cyan,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ رسام الجزيئات المتحركة للخلفية
class ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    final rng = _RandomGenerator();
    
    for (int i = 0; i < 50; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final radius = rng.nextDouble() * 3 + 1;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RandomGenerator {
  static int _seed = DateTime.now().millisecondsSinceEpoch;
  
  double nextDouble() {
    _seed = (_seed * 9301 + 49297) % 233280;
    return _seed / 233280.0;
  }
}