import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'cat_database.dart';

class CatGalleryScreen extends StatefulWidget {
  @override
  _CatGalleryScreenState createState() => _CatGalleryScreenState();
}

class _CatGalleryScreenState extends State<CatGalleryScreen> {
  List<String> _catImages = [];

  Future<void> _fetchCatImages() async {
    final loc = S.of(context)!;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      final savedCats = await CatDatabase.getSavedCats();
      if (savedCats.isNotEmpty) {
        setState(() => _catImages = savedCats);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.loadedFromDb)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.noInternetNoData)),
        );
      }
      return;
    }

    final url = Uri.parse('https://api.thecatapi.com/v1/images/search?limit=10');
    final response = await http.get(
      url,
      headers: {
        'x-api-key': 'your-api-key',
      },
    );

    try {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        final urls = decoded.map<String>((item) => item['url'] as String).toList();
        final localPaths = <String>[];
        for (final url in urls) {
          final localPath = await CatDatabase.downloadAndSaveImage(url);
          localPaths.add(localPath);
        }
        setState(() => _catImages = localPaths);
        await CatDatabase.saveCats(localPaths);
      } else {
        throw Exception('Expected a list, got: $decoded');
      }
    } catch (e) {
      print('Parsing error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.catLoadError)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCatImages();
  }

  void _openFullScreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatFullScreen(
          images: _catImages,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context)!;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final buttonColor = isLightTheme ? Colors.grey : Colors.blueGrey.shade800;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.catGallery),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _fetchCatImages,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 24, color: Colors.white),
                backgroundColor: buttonColor,
              ),
              child: Text(loc.loadCats),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _catImages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _catImages.length,
                itemBuilder: (context, index) {
                  final imagePath = _catImages[index];
                  return GestureDetector(
                    onTap: () => _openFullScreen(index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imagePath.startsWith('http')
                          ? Image.network(imagePath, fit: BoxFit.cover)
                          : Image.file(File(imagePath), fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CatFullScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const CatFullScreen({required this.images, required this.initialIndex});

  @override
  _CatFullScreenState createState() => _CatFullScreenState();
}

class _CatFullScreenState extends State<CatFullScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _next() {
    if (_currentIndex < widget.images.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context)!;
    final imagePath = widget.images[_currentIndex];
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final buttonColor = isLightTheme ? Colors.grey : Colors.blueGrey.shade800;

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isLightTheme ? Colors.blue.shade600 : Colors.black,
        title: Text('${loc.photo} ${_currentIndex + 1}/${widget.images.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: imagePath.startsWith('http')
                    ? Image.network(imagePath, fit: BoxFit.contain)
                    : Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _previous,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('←', style: TextStyle(fontSize: 28, color: Colors.blue)),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('→', style: TextStyle(fontSize: 28, color: Colors.blue)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
