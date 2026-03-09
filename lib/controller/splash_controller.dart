import 'dart:ui';

class SplashController {
  Future<void> initializeApp({
    required Function(double) onProgressChanged,
    required VoidCallback onFinished, // Cambiado a VoidCallback
  }) async {
    onProgressChanged(0.2);
    await Future.delayed(const Duration(seconds: 2));

    onProgressChanged(0.6);
    await Future.delayed(const Duration(milliseconds: 800));

    onProgressChanged(1.0);
    
    // Avisamos a la vista que ya puede ejecutar _checkNavigation
    onFinished(); 
  }
}