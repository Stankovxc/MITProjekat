import 'package:discover_herceg_novi/models/user_model.dart';
import 'package:discover_herceg_novi/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Grupisanje kontrolera radi preglednosti
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'phone': TextEditingController(),
  };

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    // Obavezno čišćenje kontrolera
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Osnovna validacija
    if (_controllers.values.any((c) => c.text.isEmpty)) {
      _showSnackBar("Molimo popunite sva polja");
      return;
    }

    setState(() => _isLoading = true);

    // Kreiranje objekta na osnovu tvog modela
    UserModel newUser = UserModel(
      id: '', // Biće dodeljen u AuthService-u preko UID-a
      email: _controllers['email']!.text.trim(),
      name: _controllers['name']!.text.trim(),
      profileImageUrl: '', // Za sada prazno
      phoneNumber: _controllers['phone']!.text.trim(),
      role: 'user',
    );

    User? user = await _authService.registerUser(
      newUser,
      _controllers['password']!.text.trim(),
    );

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showSnackBar("Greška pri registraciji. Pokušajte ponovo.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pridruži se HN Explore"),
        backgroundColor: const Color(0xFF004D40),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.explore, size: 80, color: Color(0xFF004D40)),
                  const SizedBox(height: 32),

                  _buildTextField('name', 'Ime i prezime', Icons.person),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'email',
                    'Email adresa',
                    Icons.email,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'phone',
                    'Broj telefona',
                    Icons.phone,
                    inputType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'password',
                    'Lozinka',
                    Icons.lock,
                    isObscure: true,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "KREIRAJ NALOG",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String key,
    String label,
    IconData icon, {
    bool isObscure = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: _controllers[key],
      obscureText: isObscure,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF004D40)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF004D40), width: 2),
        ),
      ),
    );
  }
}
