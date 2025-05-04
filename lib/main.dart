import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'second_screen.dart';
import 'cat_gallery_screen.dart';
import 'animated_object_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.dark);

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Text Transfer',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
          ],
          home: FirstScreen(themeNotifier: _themeNotifier),
        );
      },
    );
  }
}

class FirstScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  FirstScreen({required this.themeNotifier});

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateWithSlide(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
                .animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _buildMenuButton(String label, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blueGrey.shade900,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.lightBlueAccent),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleTheme() {
    final currentTheme = widget.themeNotifier.value;
    widget.themeNotifier.value =
    currentTheme == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.mainScreen),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: _toggleTheme,
            tooltip: loc.lightTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 120,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: loc.enterText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              loc.sendText,
              Icons.arrow_forward,
                  () {
                final text = _controller.text;
                _navigateWithSlide(SecondScreen(text: text));
              },
            ),
            _buildMenuButton(
              loc.catGallery,
              Icons.photo_library,
                  () {
                _navigateWithSlide(CatGalleryScreen());
              },
            ),
            _buildMenuButton(
              loc.animatedScreen,
              Icons.animation,
                  () {
                _navigateWithSlide(AnimatedObjectScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
