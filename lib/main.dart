import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const TwoCarsApp());

class TwoCarsApp extends StatelessWidget {
  const TwoCarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Cars',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xffef476f),
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
  static const double _carY = 0.82;
  static const double _fallSpeed = 0.34;

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

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_tick);
    _focusNode.requestFocus();
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

    setState(() {
      _leftSpawnTimer -= dt;
      _rightSpawnTimer -= dt;
      if (_leftSpawnTimer <= 0) {
        _spawnObject(0);
        _leftSpawnTimer = 0.8 + _random.nextDouble() * 0.55;
      }
      if (_rightSpawnTimer <= 0) {
        _spawnObject(1);
        _rightSpawnTimer = 0.8 + _random.nextDouble() * 0.55;
      }

      for (final object in _objects) {
        object.y += _fallSpeed * dt;
        final carTrack = object.road == 0 ? _leftTrack : _rightTrack;
        if (!object.collected &&
            object.track == carTrack &&
            (object.y - _carY).abs() < 0.065) {
          object.collected = true;
          if (object.isCircle) {
            if (object.road == 0) {
              _leftScore++;
            } else {
              _rightScore++;
            }
          } else {
            _endGame();
            break;
          }
        }
      }
      _objects.removeWhere(
        (object) => object.collected || object.y > 1.08,
      );
    });
  }

  void _spawnObject(int road) {
    _objects.add(
      FallingObject(
        road: road,
        track: _random.nextInt(2),
        isCircle: _random.nextDouble() < 0.62,
      ),
    );
  }

  void _endGame() {
    _status = GameStatus.gameOver;
    _clock.stop();
  }

  void _selectTrack(int road, int track) {
    if (_status != GameStatus.running) return;
    setState(() {
      if (road == 0) {
        _leftTrack = track;
      } else {
        _rightTrack = track;
      }
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        _selectTrack(0, 0);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.keyD:
        _selectTrack(0, 1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        _selectTrack(1, 0);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _selectTrack(1, 1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        if (_status != GameStatus.running) _startGame();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  void _handleTap(TapDownDetails details, double width) {
    final quarter =
        (details.localPosition.dx / (width / 4)).floor().clamp(0, 3);
    _selectTrack(quarter < 2 ? 0 : 1, quarter.isEven ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: _handleKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _handleTap(details, constraints.maxWidth),
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
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.paddingOf(context).top + 14,
                    child: const Center(
                      child: Text(
                        'TWO CARS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  if (_status != GameStatus.running)
                    _GameOverlay(
                      isGameOver: _status == GameStatus.gameOver,
                      score: _leftScore + _rightScore,
                      onStart: _startGame,
                    ),
                  if (_status == GameStatus.running)
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 18,
                      child: Text(
                        'A / D                         ← / →\n'
                        'Tap a lane to steer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
    required this.onStart,
  });

  final bool isGameOver;
  final int score;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xcc10121a),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isGameOver ? Icons.warning_rounded : Icons.sports_esports,
                size: 72,
                color: isGameOver
                    ? const Color(0xffffd166)
                    : const Color(0xff06d6a0),
              ),
              const SizedBox(height: 18),
              Text(
                isGameOver ? 'CRASH!' : 'READY?',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isGameOver
                    ? 'Total score: $score'
                    : 'Collect circles. Avoid squares.\n'
                        'Control both cars at the same time.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, height: 1.5),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(isGameOver ? 'PLAY AGAIN' : 'START GAME'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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
  });

  final List<FallingObject> objects;
  final int leftTrack;
  final int rightTrack;
  final int leftScore;
  final int rightScore;

  static const Color leftColor = Color(0xffef476f);
  static const Color rightColor = Color(0xff118ab2);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xff10121a),
    );

    final roadPaint = Paint()..color = const Color(0xff191c27);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width / 2, size.height), roadPaint);
    roadPaint.color = const Color(0xff151924);
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
      roadPaint,
    );

    _drawRoadLines(canvas, size);
    _drawScores(canvas, size);

    for (final object in objects) {
      _drawObject(canvas, size, object);
    }
    _drawCar(canvas, size, 0, leftTrack, leftColor);
    _drawCar(canvas, size, 1, rightTrack, rightColor);
  }

  void _drawRoadLines(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      edgePaint..color = Colors.white30,
    );

    edgePaint.color = Colors.white12;
    for (final x in [size.width / 4, size.width * 3 / 4]) {
      for (double y = 0; y < size.height; y += 42) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 22), edgePaint);
      }
    }
  }

  void _drawScores(Canvas canvas, Size size) {
    _drawText(
      canvas,
      '$leftScore',
      Offset(size.width * 0.13, 58),
      leftColor,
      32,
    );
    _drawText(
      canvas,
      '$rightScore',
      Offset(size.width * 0.87, 58),
      rightColor,
      32,
    );
  }

  void _drawObject(Canvas canvas, Size size, FallingObject object) {
    final center = Offset(
      _trackX(size, object.road, object.track),
      object.y * size.height,
    );
    final radius = min(size.width / 18, 25.0);
    final color = object.road == 0 ? leftColor : rightColor;
    final paint = Paint()..color = color;
    if (object.isCircle) {
      canvas.drawCircle(center, radius, paint);
      canvas.drawCircle(
        center,
        radius * 0.48,
        Paint()..color = const Color(0xff10121a),
      );
    } else {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(pi / 4);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 1.55,
          height: radius * 1.55,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawCar(
    Canvas canvas,
    Size size,
    int road,
    int track,
    Color color,
  ) {
    final center = Offset(_trackX(size, road, track), 0.82 * size.height);
    final width = min(size.width / 9, 44.0);
    final height = width * 1.65;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      Radius.circular(width * 0.26),
    );
    canvas.drawRRect(body, Paint()..color = color);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -height * 0.12),
          width: width * 0.66,
          height: height * 0.42,
        ),
        Radius.circular(width * 0.12),
      ),
      Paint()..color = const Color(0xffd9f0ff),
    );

    final lightPaint = Paint()..color = const Color(0xfffff3b0);
    canvas.drawCircle(
      center.translate(-width * 0.28, -height * 0.39),
      width * 0.07,
      lightPaint,
    );
    canvas.drawCircle(
      center.translate(width * 0.28, -height * 0.39),
      width * 0.07,
      lightPaint,
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
