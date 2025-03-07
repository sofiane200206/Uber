import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart'; // Assure-toi que ce fichier existe

class AddFighterScreen extends StatefulWidget {
  const AddFighterScreen({super.key});

  @override
  _AddFighterScreenState createState() => _AddFighterScreenState();
}

class _AddFighterScreenState extends State<AddFighterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _winsController = TextEditingController();
  final TextEditingController _lossesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _poidsController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();

  Future<void> _addFighter() async {
    final supabase = Supabase.instance.client;

    // URL par défaut pour l'image
    final String defaultImageUrl =
        'https://png.pngtree.com/element_our/20200702/ourmid/pngtree-cartoon-character-icon-free-button-image_2291930.jpg';

    // Vérification si l'utilisateur a renseigné une image ou non
    final String imageUrl = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : defaultImageUrl;

    print("Image URL envoyée: $imageUrl");

    try {
      final response = await supabase.from('Fighters').insert([
        {
          'name': _nameController.text.trim(),
          'wins': int.tryParse(_winsController.text) ?? 0,
          'losses': int.tryParse(_lossesController.text) ?? 0,
          'description': _descriptionController.text.trim(),
          'image_url': imageUrl,
          'poids': double.tryParse(_poidsController.text) ?? 0.0,
          'taille': double.tryParse(_tailleController.text) ?? 0.0,
          'longitude': double.tryParse(_longitudeController.text) ?? 0.0,
          'latitude': double.tryParse(_latitudeController.text) ?? 0.0,
        }
      ]).select();

      // Vérifier la réponse
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Combattant ajouté avec succès !')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Erreur si l'ajout échoue
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout du combattant')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un combattant")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nom')),
              const SizedBox(height: 10),
              TextField(controller: _winsController, decoration: const InputDecoration(labelText: 'Victoires'), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _lossesController, decoration: const InputDecoration(labelText: 'Défaites'), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 10),
              TextField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'URL de l\'image (peut être vide)')),
              const SizedBox(height: 10),
              TextField(controller: _poidsController, decoration: const InputDecoration(labelText: 'Poids (kg)'), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _tailleController, decoration: const InputDecoration(labelText: 'Taille (cm)'), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _longitudeController, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _latitudeController, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _addFighter, child: const Text('Ajouter le combattant')),
            ],
          ),
        ),
      ),
    );
  }
}
