import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safemenu/models/scan_result_model.dart';
import 'package:safemenu/daos/scan_history_dao.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final ScanHistoryDao _historyDao = ScanHistoryDao();

  // Obtenemos el ID real de Firebase.
  // Si por alguna razón no hay sesión, usamos un fallback vacío o "guest"
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  final String? userEmail =
      FirebaseAuth.instance.currentUser?.email; // Por si necesitas su correo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text(
          "Mi Historial",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<DishResult>>(
        future: _historyDao.fetchUserHistory(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyHistory();
          }

          // Usamos una variable local para poder manipular la lista al borrar
          final history = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final dish = history[index];

              // IMPLEMENTACIÓN DEL BORRADO POR DESLIZAMIENTO
              return Dismissible(
                key: Key(dish.name + index.toString()), // Clave única
                direction:
                    DismissDirection.endToStart, // Solo deslizar a la izquierda
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  // Borrar de la base de datos
                  await _historyDao.deleteHistoryItem(dish.name, currentUserId);

                  // Opcional: Mostrar un mensaje de confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${dish.name} eliminado del historial"),
                    ),
                  );
                },
                child: _buildHistoryCard(dish),
              );
            },
          );
        },
      ),
    );
  }

  // Tu función _buildHistoryCard se mantiene casi igual
  Widget _buildHistoryCard(DishResult dish) {
    Color statusColor = _getStatusColor(dish.status);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            dish.status == 'SEGURO' ? Icons.check : Icons.priority_high,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          dish.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          dish.status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: () => Navigator.pushNamed(context, '/detail', arguments: dish),
      ),
    );
  }

  // Widget que se muestra cuando el historial está vacío
  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Aún no tienes platos guardados",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tus escaneos aparecerán aquí.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'SEGURO') return Colors.green;
    if (status == 'RIESGO') return Colors.orange;
    return Colors.red;
  }
}
