import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AIService {
  final String _apiKey = "AIzaSyBUO5LYs9RXJvoGInCVtmClHXwYrtqILGk";

  Future<String> analyzeMenuImage(
    Uint8List imageBytes,
    List<String> userAllergies,
  ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
    );

    // Hemos movido la lógica de "explicación" al campo RAZON para que TRAZAS sea solo una lista limpia
    final prompt =
        """
    Actúa como un experto en seguridad alimentaria. 
    Analiza esta imagen de un menú. Alergias del usuario: ${userAllergies.join(", ")}.

    REGLAS DE FORMATO (ESTRICTO):
    1. INGREDIENTES: Solo nombres de los ingredientes base separados por comas (ej. Pollo, Tortilla de maíz, Salsa verde).
    2. TRAZAS: Lista SOLO los nombres de alérgenos con riesgo de contaminación cruzada o sospecha (ej. Cacahuates, Sésamo, Lácteos). 
       *PROHIBIDO*: No escribas oraciones, explicaciones o conectores como "en", "podría", "debido a". Solo palabras clave separadas por comas.
    3. RIESGO: Usa SEGURO, RIESGO o PELIGRO.
    4. RAZON: Aquí DEBES poner toda la explicación detallada que justifica el riesgo (ej. "Las salsas regionales pueden contener cacahuate oculto"). Aquí es donde van los párrafos largos.
    5. SUGERENCIA: Un consejo corto y práctico.

    Formato de respuesta por cada plato:
    PLATO: [Nombre]
    INGREDIENTES: [Lista limpia]
    TRAZAS: [Lista limpia de alérgenos]
    RIESGO: [Estado]
    RAZON: [Explicación técnica completa]
    SUGERENCIA: [Consejo]
    ---
    """;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Encode(imageBytes),
                  },
                },
              ],
            },
          ],
          "generationConfig": {
            "temperature":
                0.1, // Bajamos la temperatura para que sea menos "creativo" y más estructurado
            "topK": 32,
            "topP": 1,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "PLATO: Error de IA\nINGREDIENTES: N/A\nTRAZAS: N/A\nRIESGO: PELIGRO\nRAZON: Error ${response.statusCode}\nSUGERENCIA: Reintentar";
      }
    } catch (e) {
      return "PLATO: Error de Conexión\nINGREDIENTES: N/A\nTRAZAS: N/A\nRIESGO: PELIGRO\nRAZON: $e\nSUGERENCIA: Revisar internet";
    }
  }
  // En tu clase AIService, añade este método:

  Future<List<Map<String, String>>> getDynamicSecurityTips(
    List<String> userAllergies,
  ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
    );

    final prompt =
        """
  Usuario con alergias a: ${userAllergies.join(", ")}.
  Genera 2 consejos de seguridad alimentaria cortos y profesionales para este usuario cuando sale a comer.
  
  FORMATO DE RESPUESTA (JSON ESTRICTO):
  [
    {"titulo": "Frase corta", "descripcion": "Explicación breve"},
    {"titulo": "Frase corta", "descripcion": "Explicación breve"}
  ]
  """;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        // Limpiamos el texto por si la IA añade markdown de bloque de código
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        List<dynamic> jsonList = jsonDecode(text);
        return jsonList
            .map(
              (e) => {
                "titulo": e['titulo'].toString(),
                "descripcion": e['descripcion'].toString(),
              },
            )
            .toList();
      }
    } catch (e) {
      print("Error al obtener tips dinámicos: $e");
    }

    // Fallback si la IA falla
    return [
      {
        "titulo": "Verifica siempre",
        "descripcion": "Informa al mesero sobre tus alergias antes de pedir.",
      },
      {
        "titulo": "Contaminación Cruzada",
        "descripcion": "Pregunta si usan utensilios separados.",
      },
    ];
  }
}

/*import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AIService {
  // Nota: Mantén tu API Key segura.
  final String _apiKey = "AIzaSyA3tpqm5SSdlf4Qs5v6vrEP19VwNFtPQEw";

  Future<String> analyzeMenuImage(
    Uint8List imageBytes,
    List<String> userAllergies,
  ) async {
    // Usamos el modelo flash para mayor velocidad de respuesta
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
    );

    final prompt =
        """
    Actúa como un experto en seguridad alimentaria. 
    Analiza esta imagen de un menú. Alergias: ${userAllergies.join(", ")}.

    REGLAS DE CLASIFICACIÓN:
    1. INGREDIENTES: Solo los ingredientes físicos base del plato (ej. Tortilla, Pollo, Salsa verde).
    2. TRAZAS: Lista SOLO los nombres de ingredientes con riesgo de contaminación o presencia oculta (ej. Cacahuates, Nueces, Lácteos). 
       *IMPORTANTE*: NO escribas frases largas aquí, solo nombres de ingredientes separados por comas.
    3. RIESGO: Si detectas una alergia en cualquiera de las listas, marca como PELIGRO o RIESGO.
    4. RAZON: Aquí es donde DEBES poner toda la explicación detallada (ej. "Aunque la salsa no suele llevar cacahuates, algunas variantes regionales sí...").

    Formato de respuesta por plato (ESTRICTO):
    PLATO: [Nombre]
    INGREDIENTES: [Lista simple separada por comas]
    TRAZAS: [Lista simple de alérgenos sospechosos separados por comas]
    RIESGO: [SEGURO, RIESGO o PELIGRO]
    RAZON: [Explicación detallada de los riesgos y bienestar]
    SUGERENCIA: [Consejo corto]
    ---
    """;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Encode(imageBytes),
                  },
                },
              ],
            },
          ],
          // Opcional: Ajustar la temperatura para que sea más preciso y menos "creativo"
          "generationConfig": {"temperature": 0.2, "topK": 32, "topP": 1},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "PLATO: Error de IA\nINGREDIENTES: N/A\nRIESGO: PELIGRO\nRAZON: Error ${response.statusCode}";
      }
    } catch (e) {
      return "PLATO: Error de Conexión\nINGREDIENTES: N/A\nRIESGO: PELIGRO\nRAZON: Revisa tu conexión a internet. $e";
    }
  }
}*/
