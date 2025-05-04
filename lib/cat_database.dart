import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class CatDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "cat_images.db");
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Cats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  static Future<void> saveCats(List<String> paths) async {
    final db = await getDatabase();
    await db.delete('Cats');
    for (String path in paths) {
      await db.insert('Cats', {'url': path});
    }
  }

  static Future<List<String>> getSavedCats() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('Cats');
    return List.generate(maps.length, (i) => maps[i]['url'] as String);
  }

  static Future<String> downloadAndSaveImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last.split('?').first;
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path; // возвращаем путь к файлу
    } else {
      throw Exception('Не удалось загрузить изображение');
    }
  }
}
