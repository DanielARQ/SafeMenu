import 'package:firebase_auth/firebase_auth.dart'; // Importante para el ID real
import 'package:flutter/material.dart';
import 'package:safemenu/models/scan_result_model.dart';
import 'package:safemenu/daos/scan_history_dao.dart';

class ScanResultsView extends StatefulWidget {
  const ScanResultsView({super.key});

  @override
  State<ScanResultsView> createState() => _ScanResultsViewState();
}

class _ScanResultsViewState extends State<ScanResultsView> {
  String _activeFilter = 'Todos';
  final ScanHistoryDao _historyDao = ScanHistoryDao();
  bool _hasSaved = false;

  // 1. EL PARSER: Extrae la información del texto de la IA
  List<DishResult> _parseAIResponse(String response) {
    List<DishResult> dishes = [];
    List<String> sections = response.split('---');

    for (var section in sections) {
      if (section.trim().isEmpty) continue;

      try {
        String name = _extractField(section, 'PLATO:');
        String ingredients = _extractField(section, 'INGREDIENTES:');
        String traces = _extractField(section, 'TRAZAS:');
        String status = _extractField(section, 'RIESGO:');
        String reason = _extractField(section, 'RAZON:');
        String suggestion = _extractField(section, 'SUGERENCIA:');

        if (name.isNotEmpty) {
          dishes.add(
            DishResult(
              name: name,
              ingredients: ingredients,
              traces: traces,
              status: status.toUpperCase(),
              reason: reason,
              suggestion: suggestion,
            ),
          );
        }
      } catch (e) {
        debugPrint("Error parseando sección: $e");
      }
    }
    return dishes;
  }

  String _extractField(String text, String label) {
    if (!text.contains(label)) return "";
    final start = text.indexOf(label) + label.length;
    int end = text.indexOf('\n', start);
    if (end == -1) end = text.length;
    return text.substring(start, end).trim();
  }

  // 2. FUNCIÓN DE GUARDADO: Usa el UID real de Firebase
  void _saveResultsToHistory(List<DishResult> results) async {
    if (_hasSaved) return;

    // Obtenemos el ID único del usuario autenticado con Google
    final String? realUserId = FirebaseAuth.instance.currentUser?.uid;

    if (realUserId != null && results.isNotEmpty) {
      try {
        await _historyDao.saveAllDishes(results, realUserId!);
        if (mounted) {
          setState(() => _hasSaved = true);
        }
        debugPrint("Historial guardado para el UID: $realUserId");
      } catch (e) {
        debugPrint("Error al guardar historial: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String aiRawText = ModalRoute.of(context)!.settings.arguments as String;
    List<DishResult> allResults = _parseAIResponse(aiRawText);

    // Guardado automático al cargar la vista
    if (!_hasSaved && allResults.isNotEmpty) {
      _saveResultsToHistory(allResults);
    }

    List<DishResult> filteredResults = allResults.where((dish) {
      if (_activeFilter == 'Todos') return true;
      return dish.status == _activeFilter.toUpperCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text("Resultados del Menú", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // BARRA DE FILTROS
          Container(
            height: 60,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _buildFilterChip('Todos'),
                _buildFilterChip('Seguro'),
                _buildFilterChip('Riesgo'),
                _buildFilterChip('Peligro'),
              ],
            ),
          ),

          Expanded(
            child: filteredResults.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final dish = filteredResults[index];
                      return _buildDishCard(dish);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() => _activeFilter = label);
        },
        selectedColor: _getStatusColor(label.toUpperCase()),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDishCard(DishResult dish) {
    Color statusColor = _getStatusColor(dish.status);
    IconData statusIcon = _getStatusIcon(dish.status);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(dish.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  subtitle: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        dish.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => Navigator.pushNamed(context, '/detail', arguments: dish),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No hay platos marcados como '$_activeFilter'",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'SEGURO') return Colors.green;
    if (status == 'RIESGO') return Colors.orange;
    if (status == 'PELIGRO') return Colors.red;
    return Colors.blueGrey;
  }

  IconData _getStatusIcon(String status) {
    if (status == 'SEGURO') return Icons.check_circle_outline;
    if (status == 'RIESGO') return Icons.warning_amber_rounded;
    return Icons.dangerous_outlined;
  }
}

/*import 'package:flutter/material.dart';
import 'package:safemenu/models/scan_result_model.dart';

class ScanResultsView extends StatefulWidget {
  const ScanResultsView({super.key});

  @override
  State<ScanResultsView> createState() => _ScanResultsViewState();
}

class _ScanResultsViewState extends State<ScanResultsView> {
  // El filtro activo actualmente
  String _activeFilter = 'Todos';

  List<DishResult> _parseAIResponse(String response) {
    List<DishResult> dishes = [];
    List<String> sections = response.split('---');

    for (var section in sections) {
      if (section.trim().isEmpty) continue;

      try {
        String name = _extractField(section, 'PLATO:');
        String ingredients = _extractField(section, 'INGREDIENTES:');
        String traces = _extractField(section, 'TRAZAS:');
        String status = _extractField(section, 'RIESGO:');
        String reason = _extractField(section, 'RAZON:');
        String suggestion = _extractField(section, 'SUGERENCIA:');

        if (name.isNotEmpty) {
          dishes.add(
            DishResult(
              name: name,
              ingredients: ingredients,
              traces: traces,
              status: status.toUpperCase(),
              reason: reason,
              suggestion: suggestion,
            ),
          );
        }
      } catch (e) {
        debugPrint("Error parseando sección: $e");
      }
    }
    return dishes;
  }

  String _extractField(String text, String label) {
    if (!text.contains(label)) return "";
    final start = text.indexOf(label) + label.length;
    int end = text.indexOf('\n', start);
    if (end == -1) end = text.length;
    return text.substring(start, end).trim();
  }

  @override
  Widget build(BuildContext context) {
    final String aiRawText = ModalRoute.of(context)!.settings.arguments as String;
    List<DishResult> allResults = _parseAIResponse(aiRawText);

    // --- LÓGICA DE FILTRADO DINÁMICO ---
    List<DishResult> filteredResults = allResults.where((dish) {
      if (_activeFilter == 'Todos') return true;
      return dish.status == _activeFilter.toUpperCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text("Resultados del Menú", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // --- BARRA DE FILTROS (CHIPS) ---
          Container(
            height: 60,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _buildFilterChip('Todos'),
                _buildFilterChip('Seguro'),
                _buildFilterChip('Riesgo'),
                _buildFilterChip('Peligro'),
              ],
            ),
          ),
          
          // --- LISTA DE RESULTADOS ---
          Expanded(
            child: filteredResults.isEmpty 
              ? _buildEmptyState() // Si no hay platos en ese filtro
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final dish = filteredResults[index];
                    return _buildDishCard(dish);
                  },
                ),
          ),
        ],
      ),
    );
  }

  // Widget para cada botón de filtro
  Widget _buildFilterChip(String label) {
    bool isSelected = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _activeFilter = label;
          });
        },
        selectedColor: _getStatusColor(label.toUpperCase()),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget de la Tarjeta del Platillo
  Widget _buildDishCard(DishResult dish) {
    Color statusColor = _getStatusColor(dish.status);
    IconData statusIcon = _getStatusIcon(dish.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    dish.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        dish.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => Navigator.pushNamed(context, '/detail', arguments: dish),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Si un filtro no tiene resultados
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No hay platos marcados como '$_activeFilter'",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Funciones de utilidad para colores e iconos
  Color _getStatusColor(String status) {
    if (status == 'SEGURO') return Colors.green;
    if (status == 'RIESGO') return Colors.orange;
    if (status == 'PELIGRO') return Colors.red;
    return Colors.blueGrey; // Para 'Todos'
  }

  IconData _getStatusIcon(String status) {
    if (status == 'SEGURO') return Icons.check_circle_outline;
    if (status == 'RIESGO') return Icons.warning_amber_rounded;
    return Icons.dangerous_outlined;
  }
}*/
