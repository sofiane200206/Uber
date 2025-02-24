import 'package:flutter/material.dart';
import '../models/fighter.dart';
import '../widgets/fighter_card.dart';
import 'map_screen.dart';
import 'authenfication_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Fighter> filteredFighters = Fighter.getFighters();
  final TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;

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
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
        HomeContent(
          fighters: filteredFighters,
          searchController: searchController,
        ),
        const MapScreen(),
        const AuthPage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des bagarreurs")),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Authentification'),
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

class HomeContent extends StatelessWidget {
  final List<Fighter> fighters;
  final TextEditingController searchController;

  const HomeContent({
    super.key,
    required this.fighters,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Rechercher un combattant...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: fighters.length,
              itemBuilder: (context, index) {
                return FighterCard(fighter: fighters[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
