import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'crud_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto TEXT,
        valor REAL,
        cliente TEXT,
        metodoDePago TEXT,
        fecha TEXT
      )
    ''');
  }

  Future<int> insertProducto(Map<String, dynamic> producto) async {
    Database db = await database;
    return await db.insert('productos', producto);
  }

  Future<List<Map<String, dynamic>>> getProductos() async {
    Database db = await database;
    return await db.query('productos');
  }

  Future<int> updateProducto(Map<String, dynamic> producto) async {
    Database db = await database;
    int id = producto['id'];
    return await db
        .update('productos', producto, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProducto(int id) async {
    Database db = await database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }
}
