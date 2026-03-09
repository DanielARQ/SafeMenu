class UserModel {
  final String id;
  final String fullName;
  final String email;
  final List<String> allergies; // <--- Añadimos esto

  UserModel({
    required this.id, 
    required this.fullName, 
    required this.email, 
    this.allergies = const [],
  });

  // Para convertir los datos que vienen de la base de datos (JSON) a objeto
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      allergies: List<String>.from(map['allergies'] ?? []),
    );
  }

  // Para enviar los datos a la base de datos
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'allergies': allergies,
    };
  }
}

//clase modificada 26/02/2026
/*class User {
  final String? id;
  final String fullName;
  final String email;

  User({this.id, required this.fullName, required this.email});
}*/