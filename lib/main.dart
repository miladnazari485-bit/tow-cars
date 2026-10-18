import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'collision.dart';

const Color forest = Color(0xff1b8c4a);
const Color leaf = Color(0xff7bd36a);
const Color orange = Color(0xffff7a18);
const Color amber = Color(0xffffc15a);
const Color night = Color(0xff12140f);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const TwoCarsApp());
}

class TwoCarsApp extends StatelessWidget {
  const TwoCarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Cars',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          brightness: Brightness.dark,
          primary: orange,
          secondary: forest,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const GameScreen(),
    );
  }
}

enum GameStatus { ready, running, gameOver }

class FallingObject {
  FallingObject({
    required this.road,
    required this.track,
    required this.isCircle,
  });

  final int road;
  final int track;
  final bool isCircle;
  double y = -0.08;
  bool collected = false;
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const _bestKey = 'two_cars_best_score';
  static const _fallSpeed = 0.32;

  final Random _random = Random();
  final FocusNode _focusNode = FocusNode();
  final List<FallingObject> _objects = [];
  late final AnimationController _clock;

  GameStatus _status = GameStatus.ready;
  Duration _lastElapsed = Duration.zero;
  double _leftSpawnTimer = 0;
  double _rightSpawnTimer = 0.45;
  int _leftTrack = 0;
  int _rightTrack = 1;
  int _leftScore = 0;
  int _rightScore = 0;
  int _bestScore = 0;

  int get _score => _leftScore + _rightScore;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_tick);
    _focusNode.requestFocus();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _bestScore = prefs.getInt(_bestKey) ?? 0);
  }

  Future<void> _saveBest() async {
    if (_score <= _bestScore) return;
    _bestScore = _score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestKey, _bestScore);
  }

  @override
  void dispose() {
    _clock
      ..removeListener(_tick)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _status = GameStatus.running;
      _objects.clear();
      _leftTrack = 0;
      _rightTrack = 1;
      _leftScore = 0;
      _rightScore = 0;
      _leftSpawnTimer = 0;
      _rightSpawnTimer = 0.45;
      _lastElapsed = Duration.zero;
    });
    _clock
      ..reset()
      ..forward();
    _focusNode.requestFocus();
  }

  void _tick() {
    if (_status != GameStatus.running) return;

    final elapsed = _clock.lastElapsedDuration ?? Duration.zero;
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = min(0.05, (elapsed - _lastElapsed).inMicroseconds / 1000000.0);
    _lastElapsed = elapsed;
    if (dt <= 0) return;

    var crashed = false;
    setState(() {
      _leftSpawnTimer -= dt;
      _rightSpawnTimer -= dt;
      if (_leftSpawnTimer <= 0) {
        _spawnObject(0);
        _leftSpawnTimer = 0.85 + _random.nextDouble() * 0.5;
      }
      if (_rightSpawnTimer <= 0) {
        _spawnObject(1);
        _rightSpawnTimer = 0.85 + _random.nextDouble() * 0.5;
      }

      for (final object in _objects) {
        final previousY = object.y;
        object.y += _fallSpeed * dt;
        if (object.collected) continue;
        final carTrack = object.road == 0 ? _leftTrack : _rightTrack;
        if (!objectHitsCar(
          objectY: object.y,
          previousY: previousY,
          objectTrack: object.track,
          carTrack: carTrack,
        )) {
          continue;
        }
        object.collected = true;
        if (object.isCircle) {
          if (object.road == 0) {
            _leftScore++;
          } else {
            _rightScore++;
          }
        } else {
          crashed = true;
          break;
        }
      }
      _objects.removeWhere(
        (object) => object.collected || object.y > 1.12,
      );
      if (crashed) {
        _endGame();
      }
    });
  }

  void _spawnObject(int road) {
    _objects.add(
      FallingObject(
        road: road,
        track: _random.nextInt(2),
        isCircle: _random.nextDouble() < 0.68,
      ),
    );
  }

  void _endGame() {
    _status = GameStatus.gameOver;
    _clock.stop();
    _saveBest();
  }

  void _toggleCar(int road) {
    if (_status != GameStatus.running) return;
    setState(() {
      if (road == 0) {
        _leftTrack = toggleTrack(_leftTrack);
      } else {
        _rightTrack = toggleTrack(_rightTrack);
      }
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
      case LogicalKeyboardKey.keyD:
        _toggleCar(0);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
        _toggleCar(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        if (_status != GameStatus.running) _startGame();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  void _onPointerDown(PointerDownEvent event, double width) {
    if (_status != GameStatus.running) return;
    _toggleCar(sideFromX(event.localPosition.dx, width));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: night,
      body: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: _handleKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) =>
                  _onPointerDown(event, constraints.maxWidth),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: GamePainter(
                      objects: _objects,
                      leftTrack: _leftTrack,
                      rightTrack: _rightTrack,
                      leftScore: _leftScore,
                      rightScore: _rightScore,
                      bestScore: _bestScore,
                      showHints: _status == GameStatus.running,
                    ),
                  ),
                  if (_status != GameStatus.running)
                    _GameOverlay(
                      isGameOver: _status == GameStatus.gameOver,
                      score: _score,
                      bestScore: _bestScore,
                      onStart: _startGame,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GameOverlay extends StatelessWidget {
  const _GameOverlay({
    required this.isGameOver,
    required this.score,
    required this.bestScore,
    required this.onStart,
  });

  final bool isGameOver;
  final int score;
  final int bestScore;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xdd12140f),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TWO CARS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                    color: amber,
                  ),
                ),
                const SizedBox(height: 18),
                Icon(
                  isGameOver ? Icons.warning_rounded : Icons.sports_esports,
                  size: 68,
                  color: isGameOver ? orange : leaf,
                ),
                const SizedBox(height: 14),
                Text(
                  isGameOver ? 'CRASH!' : 'READY?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isGameOver
                      ? 'Score $score   •   Best $bestScore'
                      : 'Left thumb moves the green car.\n'
                          'Right thumb moves the orange car.\n'
                          'Grab circles. Skip squares.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(isGameOver ? 'PLAY AGAIN' : 'START GAME'),
                  style: FilledButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: night,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  GamePainter({
    required this.objects,
    required this.leftTrack,
    required this.rightTrack,
    required this.leftScore,
    required this.rightScore,
    required this.bestScore,
    required this.showHints,
  });

  final List<FallingObject> objects;
  final int leftTrack;
  final int rightTrack;
  final int leftScore;
  final int rightScore;
  final int bestScore;
  final bool showHints;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = night);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width / 2, size.height),
      Paint()..color = const Color(0xff172317),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
      Paint()..color = const Color(0xff24180f),
    );

    _drawRoadLines(canvas, size);
    _drawScores(canvas, size);

    for (final object in objects) {
      _drawObject(canvas, size, object);
    }
    _drawCar(canvas, size, 0, leftTrack, forest);
    _drawCar(canvas, size, 1, rightTrack, orange);

    if (showHints) {
      _drawThumbPad(canvas, size, true);
      _drawThumbPad(canvas, size, false);
    }
  }

  void _drawThumbPad(Canvas canvas, Size size, bool left) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(left ? size.width * 0.25 : size.width * 0.75, size.height - 46),
        width: size.width * 0.38,
        height: 56,
      ),
      const Radius.circular(28),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = (left ? forest : orange).withValues(alpha: 0.22),
    );
    _drawText(
      canvas,
      left ? 'TAP LEFT' : 'TAP RIGHT',
      Offset(left ? size.width * 0.25 : size.width * 0.75, size.height - 56),
      Colors.white70,
      13,
    );
  }

  void _drawRoadLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..color = amber.withValues(alpha: 0.55);
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    paint
      ..strokeWidth = 2
      ..color = Colors.white24;
    for (final x in [size.width / 4, size.width * 3 / 4]) {
      for (double y = 0; y < size.height; y += 40) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 18), paint);
      }
    }
  }

  void _drawScores(Canvas canvas, Size size) {
    _drawText(canvas, '$leftScore', Offset(size.width * 0.14, 52), leaf, 34);
    _drawText(canvas, '$rightScore', Offset(size.width * 0.86, 52), amber, 34);
    _drawText(
      canvas,
      'BEST $bestScore',
      Offset(size.width / 2, 52),
      Colors.white70,
      16,
    );
  }

  void _drawObject(Canvas canvas, Size size, FallingObject object) {
    final center = Offset(
      _trackX(size, object.road, object.track),
      object.y * size.height,
    );
    final radius = min(size.width / 16, 28.0);
    final color = object.road == 0 ? leaf : amber;
    final paint = Paint()..color = color;
    if (object.isCircle) {
      canvas.drawCircle(center, radius, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: radius * 1.7,
            height: radius * 1.7,
          ),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  void _drawCar(
    Canvas canvas,
    Size size,
    int road,
    int track,
    Color color,
  ) {
    final center = Offset(_trackX(size, road, track), carY * size.height);
    final width = min(size.width / 8.2, 50.0);
    final height = width * 1.55;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      Radius.circular(width * 0.28),
    );
    canvas.drawRRect(body, Paint()..color = color);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -height * 0.1),
          width: width * 0.62,
          height: height * 0.38,
        ),
        Radius.circular(width * 0.12),
      ),
      Paint()..color = const Color(0xfff4ffe8),
    );
  }

  double _trackX(Size size, int road, int track) {
    final roadStart = road * size.width / 2;
    return roadStart + size.width / 2 * (track == 0 ? 0.28 : 0.72);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double fontSize,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
