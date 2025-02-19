import 'package:flutter/material.dart';
import '../models/fighter.dart';
import '../screens/detail_screen.dart';

class FighterCard extends StatelessWidget {
  final Fighter fighter;

  const FighterCard({super.key, required this.fighter});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(fighter.image),
        ),
        title: Text(fighter.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(fighter.role),
        trailing: Text(fighter.distance, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailScreen(fighter: fighter)),
          );
        },
      ),
    );
  }
}
