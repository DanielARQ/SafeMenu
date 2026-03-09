import 'package:camera/camera.dart';

class SafeMenuCameraController {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  // Inicializar la cámara trasera
  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0], // Usamos la cámara trasera por defecto
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
    }
  }

  // Capturar la fotografía
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    return await _controller!.takePicture();
  }

  // Obtener el controlador para la vista (Preview)
  CameraController? get controller => _controller;

  // Limpiar memoria al cerrar
  void dispose() {
    _controller?.dispose();
  }
}