import 'package:flutter/material.dart';

class Allergy {
  final String id;
  final String nombre;
  final IconData icono;
  bool isSelected;

  Allergy({
    required this.id,
    required this.nombre,
    required this.icono,
    this.isSelected = false,
  });
}