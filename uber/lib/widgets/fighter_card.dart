import 'package:flutter/material.dart';
import '../models/fighter.dart';
import '../screens/detail_screen.dart';

class FighterCard extends StatelessWidget {
  final Fighter fighter;

  const FighterCard({super.key, required this.fighter});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: Image.network(
          fighter.image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
      'assets/perso.png', // Image locale par défaut
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
          },
        ),
        title: Text(fighter.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("🏆 ${fighter.wins} | ❌ ${fighter.losses}"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Action quand on clique sur un combattant
          debugPrint("Combattant sélectionné : ${fighter.name}");

          // Navigation vers DetailScreen avec le combattant
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(fighter: fighter),
            ),
          );
        },
      ),
    );
  }
}
