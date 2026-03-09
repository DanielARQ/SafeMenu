import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:safemenu/models/scan_result_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('safemenu.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Definimos la tabla con todos los campos que configuramos para la IA
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        dish_name TEXT NOT NULL,
        status TEXT NOT NULL,
        ingredients TEXT,
        traces TEXT,
        reason TEXT,
        suggestion TEXT,
        scan_date DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // Función para guardar un plato (Se usará después del escaneo)
  Future<int> insertScan(DishResult dish, String userId) async {
    final db = await instance.database;
    return await db.insert('scan_history', {
      'user_id': userId, // Identificador único del usuario
      'dish_name': dish.name,
      'status': dish.status,
      'ingredients': dish.ingredients,
      'traces': dish.traces, // Guardamos las trazas corregidas
      'reason': dish.reason,
      'suggestion': dish.suggestion, // Guardamos la sugerencia de la IA
    });
  }

  // Función para obtener el historial filtrado por usuario
  Future<List<Map<String, dynamic>>> getUserHistory(String userId) async {
    final db = await instance.database;
    return await db.query(
      'scan_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'scan_date DESC',
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}