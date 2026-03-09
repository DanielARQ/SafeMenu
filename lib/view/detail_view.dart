import 'package:flutter/material.dart';
import 'package:safemenu/models/scan_result_model.dart';

class DetailView extends StatelessWidget {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Recibimos el objeto del platillo con el nuevo campo 'traces'
    final DishResult dish =
        ModalRoute.of(context)!.settings.arguments as DishResult;
    
    final bool isSafe = dish.status.toUpperCase() == 'SEGURO';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detalles del Plato",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABECERA: NOMBRE Y ESTADO ---
            _buildStatusBanner(dish, isSafe),

            // --- SUGERENCIA DINÁMICA DE LA IA ---
            if (dish.suggestion.isNotEmpty) 
              _buildModificationSuggestion(dish.suggestion),

            // --- SECCIÓN 1: INGREDIENTES REALES ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(
                "Ingredientes Detectados e Inferidos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildIngredientsList(dish.ingredients, dish.reason),

            // --- SECCIÓN 2: TRAZAS / CONTAMINACIÓN (Lo que "podría" contener) ---
            if (dish.traces.isNotEmpty && dish.traces.toLowerCase() != "ninguna") ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Riesgo de Contaminación Cruzada",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ],
                ),
              ),
              _buildTracesList(dish.traces, dish.reason),
            ],

            // --- SECCIÓN: ANÁLISIS DE BIENESTAR ---
            _buildHealthNote(dish.reason, isSafe),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(DishResult dish, bool isSafe) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dish.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isSafe ? Icons.check_circle : Icons.warning_amber_rounded,
                color: isSafe ? Colors.green[700] : Colors.red[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSafe ? "Opción segura según tu perfil" : "Atención con este platillo",
                  style: TextStyle(
                    color: isSafe ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModificationSuggestion(String suggestion) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(15),
        border: const Border(left: BorderSide(width: 5, color: Colors.blue)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(String ingredientsText, String reason) {
    List<String> ingredientsList = _splitText(ingredientsText);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: ingredientsList.length,
      itemBuilder: (context, index) {
        String ingredient = ingredientsList[index];
        bool isWarning = reason.toLowerCase().contains(ingredient.toLowerCase());

        return _buildItemRow(ingredient, isWarning, Colors.green);
      },
    );
  }

  // NUEVO: Widget para mostrar las trazas con estilo de advertencia naranja
  Widget _buildTracesList(String tracesText, String reason) {
    List<String> tracesList = _splitText(tracesText);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tracesList.length,
      itemBuilder: (context, index) {
        String trace = tracesList[index];
        // En trazas, casi siempre es una advertencia si el usuario es alérgico
        return _buildItemRow(trace, true, Colors.orange);
      },
    );
  }

  // Función auxiliar para construir las filas de la lista
  Widget _buildItemRow(String text, bool isWarning, Color safeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: isWarning ? Border.all(color: Colors.red[300]!, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.report_problem : Icons.check_circle_outline,
            color: isWarning ? Colors.red[900] : safeColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                color: isWarning ? Colors.red[900] : Colors.black87,
              ),
            ),
          ),
          if (isWarning)
            Text(
              "RIESGO",
              style: TextStyle(color: Colors.red[900], fontSize: 10, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  List<String> _splitText(String text) {
    return text
        .replaceAll('(', '').replaceAll(')', '')
        .split(RegExp(r'[,y\.]'))
        .map((e) => e.trim())
        .where((e) => e.length > 2) // <--- ESTO evita palabras como "en", "y", "a"
        .where((e) => !e.contains('**')) // Limpia posibles negritas sobrantes de la IA
        .toList();
  }

  Widget _buildHealthNote(String dishReason, bool isSafe) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSafe ? Colors.green[200]! : Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSafe ? Icons.info_outline : Icons.health_and_safety,
                color: isSafe ? Colors.green[900] : Colors.orange[900],
              ),
              const SizedBox(width: 10),
              const Text(
                "Análisis de Bienestar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dishReason,
            style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:safemenu/models/scan_result_model.dart';

class DetailView extends StatelessWidget {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Recibimos el objeto del platillo con todos los datos de la IA
    final DishResult dish =
        ModalRoute.of(context)!.settings.arguments as DishResult;
    
    // 2. Determinamos si el plato es seguro basándonos en el status de la IA
    final bool isSafe = dish.status.toUpperCase() == 'SEGURO';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detalles del Plato",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABECERA: NOMBRE Y ESTADO (Rojo o Verde) ---
            _buildStatusBanner(dish, isSafe),

            // --- SUGERENCIA DINÁMICA DE LA IA ---
            // Solo se muestra si no es seguro o si la IA generó un consejo útil
            if (dish.suggestion.isNotEmpty) 
              _buildModificationSuggestion(dish.suggestion),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(
                "Ingredientes Detectados e Inferidos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // --- LISTA DE INGREDIENTES CON ALERTAS VISUALES ---
            _buildIngredientsList(dish.ingredients, dish.reason),

            // --- SECCIÓN: ANÁLISIS DE BIENESTAR (Razón detallada) ---
            _buildHealthNote(dish.reason, isSafe),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Banner superior que indica si el plato es apto o no
  Widget _buildStatusBanner(DishResult dish, bool isSafe) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dish.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isSafe ? Icons.check_circle : Icons.warning_amber_rounded,
                color: isSafe ? Colors.green[700] : Colors.red[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSafe
                      ? "Opción segura según tu perfil"
                      : "Atención con este platillo",
                  style: TextStyle(
                    color: isSafe ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Cuadro azul de sugerencias que ahora usa datos REALES de la IA
  Widget _buildModificationSuggestion(String suggestion) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(15),
        border: const Border(left: BorderSide(width: 5, color: Colors.blue)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: const TextStyle(
                color: Color(0xFF0D47A1),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(String ingredientsText, String reason) {
    List<String> ingredientsList = ingredientsText
        .replaceAll('(', '')
        .replaceAll(')', '')
        .split(RegExp(r'[,y\.]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: ingredientsList.length,
      itemBuilder: (context, index) {
        String ingredient = ingredientsList[index];
        // Comprobamos si este ingrediente específico causa el riesgo
        bool isWarning = reason.toLowerCase().contains(ingredient.toLowerCase());

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isWarning ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: isWarning ? Border.all(color: Colors.red[300]!, width: 1.5) : null,
          ),
          child: Row(
            children: [
              Icon(
                isWarning ? Icons.report_problem : Icons.check_circle_outline,
                color: isWarning ? Colors.red[900] : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ingredient,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                    color: isWarning ? Colors.red[900] : Colors.black87,
                  ),
                ),
              ),
              if (isWarning)
                Text(
                  "PELIGRO",
                  style: TextStyle(color: Colors.red[900], fontSize: 10, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthNote(String dishReason, bool isSafe) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSafe ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSafe ? Icons.info_outline : Icons.health_and_safety,
                color: isSafe ? Colors.green[900] : Colors.orange[900],
              ),
              const SizedBox(width: 10),
              const Text(
                "Análisis de Bienestar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dishReason,
            style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}*/