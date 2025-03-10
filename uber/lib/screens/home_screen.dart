import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fighter.dart';
import '../widgets/fighter_card.dart';
import 'map_screen.dart';
import 'authenfication_screen.dart';
import 'addfighter_screen.dart'; // Ajoute l'import de la page AddFighterScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;
  Stream<List<Fighter>> fightersStream = Fighter.streamFighters();

  @override
  void initState() {
    super.initState();
    testFightersQuery(); // Vérifie si la table est bien accessible
  }

  /// Vérifie si l'utilisateur est connecté
  bool _isUserLoggedIn() {
    final user = Supabase.instance.client.auth.currentUser;
    return user != null;
  }

  /// Teste la requête Supabase et affiche les résultats dans la console
  void testFightersQuery() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('Fighters').select();

    debugPrint("📊 Résultat de la requête SQL brute : $response");

    if (response.isEmpty) {
      debugPrint("⚠ Aucun combattant trouvé dans la table !");
    } else {
      debugPrint("✅ Données trouvées : ${response.length} combattants");
    }
  }

  /// Gère la navigation via la barre du bas
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
        _isUserLoggedIn()
            ? HomeContent(fightersStream: fightersStream, searchController: searchController)
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Connectez-vous pour voir les combattants !"),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 2; // Redirige vers la page d'authentification
                        });
                      },
                      child: const Text("Se connecter"),
                    ),
                  ],
                ),
              ),
        const MapScreen(),
        const AuthPage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uber bagarre")),
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
}

class HomeContent extends StatelessWidget {
  final Stream<List<Fighter>> fightersStream;
  final TextEditingController searchController;

  const HomeContent({
    super.key,
    required this.fightersStream,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Fighter>>(
      stream: fightersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Erreur : ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucun combattant trouvé !"));
        }

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
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return FighterCard(fighter: snapshot.data![index]);
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddFighterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text("Ajouter un combattant"),
              ),
            ],
          ),
        );
      },
    );
  }
}
