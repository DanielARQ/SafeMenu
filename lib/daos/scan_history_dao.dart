import 'package:safemenu/database/database_helper.dart';
import 'package:safemenu/models/scan_result_model.dart';

class ScanHistoryDao {
  final dbHelper = DatabaseHelper.instance;

  // Guarda un plato individualmente vinculándolo al usuario
  Future<void> saveDishResult(DishResult dish, String userId) async {
    await dbHelper.insertScan(dish, userId);
  }

  // Guarda una lista completa de platos de un solo golpe (Batch)
  Future<void> saveAllDishes(List<DishResult> dishes, String userId) async {
    for (var dish in dishes) {
      await saveDishResult(dish, userId);
    }
  }

  // Recupera el historial y lo convierte de Map a objetos DishResult para tu UI
  Future<List<DishResult>> fetchUserHistory(String userId) async {
    final List<Map<String, dynamic>> maps = await dbHelper.getUserHistory(
      userId,
    );

    return List.generate(maps.length, (i) {
      return DishResult(
        name: maps[i]['dish_name'],
        ingredients: maps[i]['ingredients'],
        traces: maps[i]['traces'], // Recuperamos las trazas limpias
        status: maps[i]['status'],
        reason: maps[i]['reason'], // Recuperamos la explicación detallada
        suggestion: maps[i]['suggestion'],
      );
    });
  }

  // Opcional: Borrar un elemento específico del historial
  // En lib/daos/scan_history_dao.dart

  // Agrega este método si no lo tenías exactamente así
  Future<void> deleteHistoryItem(String dishName, String userId) async {
    final db = await dbHelper.database;
    await db.delete(
      'scan_history',
      where: 'dish_name =  ? AND user_id = ?',
      whereArgs: [dishName, userId],
    );
  }
}
