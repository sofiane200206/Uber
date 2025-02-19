import 'package:flutter/material.dart';
import '../models/fighter.dart';



class DetailScreen extends StatelessWidget {
  final Fighter fighter;

  const DetailScreen({super.key, required this.fighter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fighter.name)),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(fighter.image),
            ),
            const SizedBox(height: 20),
            Text(fighter.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(fighter.role, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Distance : ${fighter.distance}", style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
