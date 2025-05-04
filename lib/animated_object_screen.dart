import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class AnimatedObjectScreen extends StatefulWidget {
  @override
  _AnimatedObjectScreenState createState() => _AnimatedObjectScreenState();
}

class _AnimatedObjectScreenState extends State<AnimatedObjectScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _moveController;
  late AnimationController _blinkController;

  Offset _position = Offset.zero;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      lowerBound: 0.5,
      upperBound: 1.5,
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _moveController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _moveController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _startFade() {
    _fadeController.forward(from: 0).then((_) => _fadeController.reverse());
  }

  void _startSlide() {
    if (_slideController.status == AnimationStatus.dismissed || _slideController.value == 0.0) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  void _startScale() {
    _scaleController.forward(from: 0.5).then((_) => _scaleController.reverse());
  }

  void _startRotation() {
    _rotationController.forward(from: 0);
  }

  void _startMove() {
    setState(() {
      _position = _position == Offset.zero ? Offset(100, 100) : Offset.zero;
    });
    _moveController.forward(from: 0);
  }

  void _startBlink() async {
    for (int i = 0; i < 3; i++) {
      await _blinkController.forward(from: 0);
      await _blinkController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context); // Check if the localization is available
    if (s == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'), // Fallback title
        ),
        body: Center(child: CircularProgressIndicator()), // Loading or error UI
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.animations),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _fadeController,
                  _slideController,
                  _scaleController,
                  _rotationController,
                  _moveController,
                  _blinkController,
                ]),
                builder: (context, child) {
                  return Opacity(
                    opacity: 1.0 - _fadeController.value - _blinkController.value,
                    child: Transform.translate(
                      offset: _position + Offset(0, -100 * _slideController.value),
                      child: Transform.rotate(
                        angle: _rotationController.value * 6.28,
                        child: Transform.scale(
                          scale: _scaleController.value == 0.0 ? 1.0 : _scaleController.value,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.pink,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildButton(s.fade, _startFade),
                _buildButton(s.slide, _startSlide),
                _buildButton(s.scale, _startScale),
                _buildButton(s.rotate, _startRotation),
                _buildButton(s.move, _startMove),
                _buildButton(s.blink, _startBlink),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(160, 60),
        textStyle: const TextStyle(fontSize: 20, color: Colors.white),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey.shade800
            : Colors.grey,
      ),
      child: Text(label),
    );
  }
}
