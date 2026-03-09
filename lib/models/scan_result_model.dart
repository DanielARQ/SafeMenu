import 'package:flutter/material.dart';

class DishResult {
  final String name;
  final String ingredients;
  final String traces;      // <--- NUEVO: Para "Podría contener"
  final String status;      // 'SEGURO', 'RIESGO', 'PELIGRO'
  final String reason;
  final String suggestion;

  DishResult({
    required this.name, 
    required this.ingredients, 
    required this.traces,     // <--- Añadido al constructor
    required this.status, 
    required this.reason, 
    required this.suggestion, 
  });

  factory DishResult.fromJson(Map<String, dynamic> json) {
    return DishResult(
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      ingredients: json['ingredients'] ?? '',
      traces: json['traces'] ?? '',           // <--- Mapeo de la nueva etiqueta
      reason: json['reason'] ?? '',
      suggestion: json['suggestion'] ?? '', 
    );
  }

  // Lógica visual basada en el estado
  Color get statusColor {
    if (status.contains('PELIGRO')) return Colors.red;
    if (status.contains('RIESGO')) return Colors.orange;
    return Colors.green;
  }

  IconData get statusIcon {
    if (status.contains('PELIGRO')) return Icons.cancel;
    if (status.contains('RIESGO')) return Icons.warning;
    return Icons.check_circle;
  }
}