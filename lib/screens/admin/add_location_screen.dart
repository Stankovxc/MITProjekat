import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import '../../services/location_service.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controllers = {
    'title': TextEditingController(),
    'description': TextEditingController(),
    'imageUrl': TextEditingController(),
    'category': TextEditingController(),
  };

  bool _isLoading = false;

  void _saveLocation() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      LocationModel newLoc = LocationModel(
        id: '',
        title: _controllers['title']!.text.trim(),
        description: _controllers['description']!.text.trim(),
        imageUrl: _controllers['imageUrl']!.text.trim(),
        category: _controllers['category']!.text.trim(),
      );

      try {
        await LocationService().addLocation(newLoc);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lokacija uspešno dodata!")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Greška: $e")));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dodaj Novu Lokaciju")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput('title', 'Naziv lokacije', Icons.place),
                    const SizedBox(height: 12),
                    _buildInput(
                      'category',
                      'Kategorija (npr. Plaža, Tvrđava)',
                      Icons.category,
                    ),
                    const SizedBox(height: 12),
                    _buildInput('imageUrl', 'URL slike', Icons.image),
                    const SizedBox(height: 12),
                    _buildInput(
                      'description',
                      'Opis',
                      Icons.description,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text(
                          "SAČUVAJ LOKACIJU",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInput(
    String key,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: _controllers[key],
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val == null || val.isEmpty ? "Obavezno polje" : null,
    );
  }
}
