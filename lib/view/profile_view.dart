import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text("Mi Perfil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, size: 50, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 20),
            const Text("Usuario SafeMenu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 40),
            _buildInfoTile("Mis Alergias", "Cacahuetes, Lácteos", Icons.warning_amber_rounded),
            _buildInfoTile("Correo", "usuario@ejemplo.com", Icons.email_outlined),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Aquí podrías dejar que edite, pero solo si él lo decide
                Navigator.pushNamed(context, '/setup'); 
              },
              child: const Text("Editar Alergias", style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}