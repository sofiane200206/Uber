import 'package:flutter/material.dart';
import '../models/fighter.dart';
import '../widgets/fighter_card.dart';
import 'map_screen.dart'; // Import de la page de carte

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Fighter> filteredFighters = Fighter.getFighters();
  final TextEditingController searchController = TextEditingController();
  int _currentIndex = 0; // Gère l'index de navigation

  final List<Widget> _screens = [
    const HomeContent(), // Contenu principal
    const MapScreen(),   // Page de la carte
    const Center(child: Text("Profil")), // Page Profil (à modifier selon tes besoins)
  ];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterFighters);
  }

  void _filterFighters() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredFighters = Fighter.getFighters()
          .where((fighter) => fighter.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Met à jour la page affichée
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des bagarreurs")),
      body: _screens[_currentIndex], // Affiche la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

// Séparation du contenu principal
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Rechercher un combattant...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: Fighter.getFighters().length,
              itemBuilder: (context, index) {
                return FighterCard(fighter: Fighter.getFighters()[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
