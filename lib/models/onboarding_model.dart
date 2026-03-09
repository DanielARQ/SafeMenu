// En onboarding_model.dart
import 'package:flutter/material.dart';

class OnboardingStep {
  final IconData icon; // Cambiado de String imagePath a IconData icon
  final String title;
  final String description;

  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}
/*class OnboardingStep {
  final String imagePath;
  final String title;
  final String description;

  OnboardingStep({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}*/