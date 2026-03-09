import 'package:flutter/material.dart';
import '../models/allergy_model.dart';
import '../daos/allergy_dao.dart';

class AllergyController {
  final AllergyDAO _dao = AllergyDAO();

  final List<Allergy> allAllergies = [
    Allergy(id: '1', nombre: 'Cacahuetes', icono: Icons.spa),
    Allergy(id: '2', nombre: 'Lácteos', icono: Icons.water_drop),
    Allergy(id: '3', nombre: 'Gluten', icono: Icons.grain),
    Allergy(id: '4', nombre: 'Mariscos', icono: Icons.set_meal),
    Allergy(id: '5', nombre: 'Frutos Secos', icono: Icons.eco),
    Allergy(id: '6', nombre: 'Pescado', icono: Icons.phishing),
    Allergy(id: '7', nombre: 'Soja', icono: Icons.grass),
    Allergy(id: '8', nombre: 'Huevo', icono: Icons.egg),
    Allergy(id: '9', nombre: 'Sésamo', icono: Icons.scatter_plot),
    Allergy(id: '10', nombre: 'Mostaza', icono: Icons.restaurant),
  ];

  List<Allergy> get selectedAllergies => 
      allAllergies.where((a) => a.isSelected).toList();

  void toggleAllergy(int index) {
    allAllergies[index].isSelected = !allAllergies[index].isSelected;
  }

  Future<void> saveProfile(Function onSaved) async {
    List<String> ids = selectedAllergies.map((a) => a.id).toList();
    await _dao.saveSelectedAllergies(ids);
    onSaved();
  }
}