import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Fighter {
  final String id;
  final String name;
  final String image;
  final String wins;
  final String losses;
  final String distance;
  final double longitude;
  final double latitude;
  final double poids;
  final double taille;
  final String description;

  Fighter({
    required this.id,
    required this.name,
    required this.image,
    required this.distance,
    required this.wins,
    required this.losses,
    required this.longitude,
    required this.latitude,
    required this.poids,
    required this.taille,
    required this.description,
  });

  // Convertir une ligne Supabase en Fighter avec gestion des valeurs nulles
  factory Fighter.fromJson(Map<String, dynamic> json) {
    return Fighter(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Inconnu',
      wins: json['wins']?.toString() ?? '0',
      losses: json['losses']?.toString() ?? '0',
      distance: json['distance'] ?? 'Non précisé',
      image: json['image_url'] ?? 'https://png.pngtree.com/element_our/20200702/ourmid/pngtree-cartoon-character-icon-free-button-image_2291930.jpg',
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      poids: (json['poids'] as num?)?.toDouble() ?? 0.0,
      taille: (json['taille'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? 'Pas de description',
    );
  }

  // Stream pour récupérer les combattants en temps réel
  static Stream<List<Fighter>> streamFighters() {
    final supabase = Supabase.instance.client;
    return supabase.from('Fighters').stream(primaryKey: ['id']).map((data) {
      if (data.isEmpty) {
        debugPrint("⚠ Aucun combattant trouvé dans la base de données !");
      } else {
        debugPrint("✅ Combattants récupérés : ${data.length}");
      }
      return data.map<Fighter>((fighter) => Fighter.fromJson(fighter)).toList();
    });
  }
}
