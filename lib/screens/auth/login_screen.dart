import 'package:discover_herceg_novi/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Unutar tvog _LoginScreenState-a

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final Map<String, TextEditingController> _controllers = {
    'email': TextEditingController(),
    'password': TextEditingController(),
  };

  void _handleLogin() async {
    String email = _controllers['email']!.text.trim();
    String password = _controllers['password']!.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Molimo unesite email i lozinku");
      return;
    }

    setState(() => _isLoading = true);

    User? user = await _authService.loginUser(email, password);

    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      _showError("Neuspešna prijava. Proverite podatke.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1FA2B1), Color(0xFFEAD5C3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login with Email",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),

                _buildTextField(
                  'email',
                  'Email adresa',
                  Icons.email,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'password',
                  'Lozinka',
                  Icons.lock,
                  isObscure: true,
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot your password?",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleLogin();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text("OR"),
                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have account? ",
                      children: [
                        TextSpan(
                          text: "Register Now",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
