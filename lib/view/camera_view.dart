import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:safemenu/service/ai_service.dart';
import 'package:safemenu/service/user_prefs.dart'; // <--- 1. IMPORTA TUS PREFS
import '../controller/camera_controller.dart'; // <--- Añade esto

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final _cameraLogic = SafeMenuCameraController();
  final prefs = UserPrefs(); // <--- 2. INSTANCIA LAS PREFERENCIAS
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _cameraLogic.initialize();
    if (mounted) setState(() => _isReady = true);
  }

  @override
  void dispose() {
    _cameraLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _cameraLogic.controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. El Preview de la cámara
          Positioned.fill(child: CameraPreview(_cameraLogic.controller!)),

          // 2. Capa de diseño (Marco de escaneo)
          Container(
            decoration: ShapeDecoration(
              shape: ColorSecondaryTransparentShape(),
            ),
          ),

          // 3. Botones e instrucciones
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Escaneando menú...",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),

                // Botón de Captura
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GestureDetector(
                    onTap: () async {
                      final photo = await _cameraLogic.takePicture();
                      if (photo != null) {
                        // 1. Mostrar un indicador de carga (puedes usar un Dialog)
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          ),
                        );

                        // 2. Leer los bytes de la imagen
                        final bytes = await photo.readAsBytes();

                        // 3. Llamar a la IA (aquí necesitarás traer las alergias de tu AllergyController)
                        final aiService = AIService();
                        // Ejemplo con alergias quemadas por ahora, luego las traemos del DAO
                        final result = await aiService.analyzeMenuImage(
                          bytes,
                          prefs
                              .allergies, // <--- AQUÍ YA NO ESTÁN "QUEMADAS", SON LAS REALES
                        );
                        // 4. Quitar el cargando y navegar a resultados
                        Navigator.pop(context); // Cierra el loading
                        Navigator.pushNamed(
                          context,
                          '/results',
                          arguments: result,
                        );
                      }
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Clase para crear el efecto de "ventana" en el escaneo
class ColorSecondaryTransparentShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: rect.width * 0.8,
            height: rect.height * 0.5,
          ),
          const Radius.circular(20),
        ),
      )
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
