
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/quote.dart';


class DatabaseHelper {
  static final _databaseName = "quotes.db";
  static final _databaseVersion = 1;
  static final table = 'quotes_table';
  static final columnId = '_id';
  static final columnQuote = 'quote';
  static final columnCategory = 'category';
  static final columnDateTime = 'dateTime';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnQuote TEXT NOT NULL,
        $columnCategory TEXT NOT NULL,
        $columnDateTime TEXT
      );
    ''');
    await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY,
            name TEXT
          );
        ''');
  }

  // Insert a new quote
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Fetch all quotes
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Fetch quotes by category
  Future<List<Map<String, dynamic>>> queryByCategory(String category) async {
    Database db = await instance.database;
    return await db.query(table, where: "$columnCategory LIKE ?", whereArgs: ['%$category%']);
  }

  // Fetch quotes by text (for searching within the quote itself)
  Future<List<Map<String, dynamic>>> queryByText(String text) async {
    Database db = await instance.database;
    return await db.query(table, where: "$columnQuote LIKE ?", whereArgs: ['%$text%']);
  }

  // Update a quote
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: "$columnId = ?", whereArgs: [id]);
  }

  // Delete a quote
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: "$columnId = ?", whereArgs: [id]);
  }




  Future<List<Quote>> getAllReminders() async {
    final db = await database;
    final maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Quote.fromMap(maps[i]);
    });
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update('categories', category.toMap(),
        where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });

  }

}
