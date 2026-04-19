import 'package:discover_herceg_novi/models/location_model.dart';
import 'package:discover_herceg_novi/services/location_service.dart';
import 'package:flutter/material.dart';

class EditLocationScreen extends StatefulWidget {
  final LocationModel location;
  const EditLocationScreen({super.key, required this.location});

  @override
  State<EditLocationScreen> createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'title': TextEditingController(text: widget.location.title),
      'description': TextEditingController(text: widget.location.description),
      'imageUrl': TextEditingController(text: widget.location.imageUrl),
      'category': TextEditingController(text: widget.location.category),
    };
  }

  void _update() async {
    if (_formKey.currentState!.validate()) {
      LocationModel updatedLoc = LocationModel(
        id: widget.location.id,
        title: _controllers['title']!.text,
        description: _controllers['description']!.text,
        imageUrl: _controllers['imageUrl']!.text,
        category: _controllers['category']!.text,
      );

      await LocationService().updateLocation(updatedLoc);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Izmeni lokaciju")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput('title', 'Naziv'),
              _buildInput('category', 'Kategorija'),
              _buildInput('imageUrl', 'URL slike'),
              _buildInput('description', 'Opis', maxLines: 4),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _update,
                child: const Text("SAČUVAJ IZMENE"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String key, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: _controllers[key],
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}
