import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../models/fighter.dart';

class DetailScreen extends StatefulWidget {
  final Fighter fighter;

  const DetailScreen({super.key, required this.fighter});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  double userDistance = -1; // Distance utilisateur initiale

  @override
  void initState() {
    super.initState();
    _getUserDistance(); // Calculer la distance dès l'initialisation
  }

  /// Fonction appelée quand la carte est prête
  void _onMapCreated(MapboxMap map) async {
    mapboxMap = map;

    // Crée l'annotation manager pour gérer les annotations
    final annotationManager = await map.annotations.createPointAnnotationManager();
    setState(() {
      pointAnnotationManager = annotationManager;
    });

    _addFighterMarker();
  }

  /// Ajoute un marqueur pour le combattant
  void _addFighterMarker() async {
    if (pointAnnotationManager == null || mapboxMap == null) return;

    // Crée un marqueur sur la carte à l'emplacement du combattant
    await pointAnnotationManager!.create(PointAnnotationOptions(
      geometry: Point(coordinates: Position(widget.fighter.longitude, widget.fighter.latitude)),
      iconSize: 1.5,
      textField: widget.fighter.name, // Affiche le nom du combattant sur le marqueur
      textColor: Colors.black.value,
      iconImage: "assets/test.png", // Image du marqueur (assure-toi qu'elle soit dans les assets)
    ));

    // Centre la caméra sur le combattant
    mapboxMap!.setCamera(CameraOptions(
      center: Point(coordinates: Position(widget.fighter.longitude, widget.fighter.latitude)),
      zoom: 12,
    ));
  }

  // Fonction pour calculer la distance entre l'utilisateur et le combattant
  Future<void> _getUserDistance() async {
    double distance = await calculateDistance(widget.fighter);
    setState(() {
      userDistance = distance;
    });
  }

  // Fonction pour calculer la distance en km
  Future<double> calculateDistance(Fighter fighter) async {
    try {
      // Obtenir la position de l'utilisateur
      gl.Position position = await gl.Geolocator.getCurrentPosition(
        desiredAccuracy: gl.LocationAccuracy.high,
      );

      // Calculer la distance entre l'utilisateur et le combattant
      double distanceMeters = gl.Geolocator.distanceBetween(
        position.latitude, // Position de l'utilisateur
        position.longitude, // Position de l'utilisateur
        fighter.latitude, // Latitude du combattant
        fighter.longitude, // Longitude du combattant
      );

      return distanceMeters / 1000; // Convertir en km
    } catch (e) {
      print("Erreur distance: $e");
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.fighter.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(widget.fighter.image),
                ),
                const SizedBox(height: 20),
                Text(widget.fighter.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Distance : ${userDistance == -1 ? 'Calcul en cours...' : '${userDistance.toStringAsFixed(2)} km'}", 
                     style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                Text("Poids: ${widget.fighter.poids} kg", style: const TextStyle(fontSize: 16)),
                Text("Taille: ${widget.fighter.taille} cm", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Text("Description: ${widget.fighter.description}", style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),

          // 📌 Carte Mapbox avec le marqueur du combattant
          Expanded(
            child: MapWidget(
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(widget.fighter.longitude, widget.fighter.latitude)),
                zoom: 12,
              ),
              onMapCreated: _onMapCreated,
            ),
          ),
        ],
      ),
    );
  }
}
