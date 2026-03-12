import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- IMPORTANTE
import 'package:safemenu/controller/allergy_controller.dart';
import 'package:safemenu/models/user_model.dart';
import 'package:safemenu/service/user_service.dart';

class AllergySetupView extends StatefulWidget {
  const AllergySetupView({super.key});

  @override
  State<AllergySetupView> createState() => _AllergySetupViewState();
}

class _AllergySetupViewState extends State<AllergySetupView> {
  final AllergyController _controller = AllergyController();
  final UserService _userService = UserService();

  Future<void> _handleSaveProfile() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // Recuperamos el perfil actual para no perder el nombre real
      final existingProfile = await _userService.getUserProfile(
        firebaseUser.uid,
      );

      UserModel updatedUser = UserModel(
        id: firebaseUser.uid,
        fullName: existingProfile?.fullName ?? "Usuario SafeMenu",
        email: firebaseUser.email ?? existingProfile?.email ?? "",
        allergies: _controller.selectedAllergies.map((a) => a.nombre).toList(),
      );

      await _userService.saveUserProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil de alergias actualizado")),
        );

        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "¿A qué eres alérgico?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: Text(
              "Escanearemos los menús y te avisaremos sobre estos ingredientes.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _controller.allAllergies.length,
              itemBuilder: (context, index) {
                final allergy = _controller.allAllergies[index];

                return GestureDetector(
                  onTap: () => setState(() => _controller.toggleAllergy(index)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: allergy.isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F4F1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  allergy.icono,
                                  color: const Color(0xFF4CAF50),
                                  size: 30,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                allergy.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (allergy.isSelected)
                          const Positioned(
                            top: 12,
                            right: 12,
                            child: Icon(
                              Icons.check_circle,
                              color: Color(0xFF4CAF50),
                              size: 22,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Panel inferior
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),

            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_controller.selectedAllergies.length} seleccionadas",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      TextButton(
                        onPressed: () => setState(() {
                          for (var a in _controller.allAllergies) {
                            a.isSelected = false;
                          }
                        }),
                        child: const Text(
                          "LIMPIAR TODO",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _controller.selectedAllergies.isEmpty
                        ? null
                        : _handleSaveProfile,
                    child: const Text(
                      "Guardar Perfil",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
