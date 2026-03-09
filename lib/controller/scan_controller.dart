import '../models/allergy_model.dart';

class ScanController {
  // Simulación de análisis de IA
  Future<Map<String, dynamic>> analyzeDish(String imagePath, List<String> userAllergies) async {
    // Aquí iría la llamada a la API de IA
    // Por ahora simulamos una respuesta basada en lo que "ve" la IA
    await Future.delayed(const Duration(seconds: 2)); // Simulando procesamiento

    return {
      "dishName": "Thai Coconut Curry",
      "ingredients": ["Leche de coco", "Pollo", "Especias", "Trazas de mariscos"],
      "status": "warning", // 'safe', 'warning', 'danger'
      "foundAllergens": ["Mariscos"],
    };
  }
}