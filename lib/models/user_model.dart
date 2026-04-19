class UserModel {
  final String id;
  final String email;
  final String name;
  final String profileImageUrl;
  final String phoneNumber;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.profileImageUrl,
    required this.phoneNumber,
    required this.role,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }
}
