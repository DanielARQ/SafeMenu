import 'package:flutter/material.dart';
import 'package:safemenu/models/onboarding_model.dart';

class OnboardingController {
  // 1. La lista maestra con todos tus tips
  final List<OnboardingStep> _allTips = [
    const OnboardingStep(icon: Icons.wash, title: "Higiene", description: "Lava tus manos siempre."),
    const OnboardingStep(icon: Icons.restaurant, title: "Menú", description: "Revisa los iconos de alérgenos."),
    const OnboardingStep(icon: Icons.warning, title: "Trazas", description: "Cuidado con la contaminación cruzada."),
    const OnboardingStep(icon: Icons.search, title: "Etiquetas", description: "Lee siempre los ingredientes."),
  ];

  // 2. Variable privada para guardar los tips de la sesión actual
  List<OnboardingStep>? _currentSessionSteps;

  // 3. El getter ahora solo mezcla si la lista está vacía
  List<OnboardingStep> get steps {
    if (_currentSessionSteps == null) {
      // Mezclamos TODA la lista una sola vez
      List<OnboardingStep> shuffled = List<OnboardingStep>.from(_allTips)..shuffle();
      // Tomamos 3 únicos
      _currentSessionSteps = shuffled.take(3).toList();
    }
    return _currentSessionSteps!;
  }
}