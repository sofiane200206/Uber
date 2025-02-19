import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo; // Import pour gérer la géolocalisation
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  // Fonction pour déterminer la position de l'utilisateur
  Future<geo.Position> _determinePosition() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    // Test si les services de localisation sont activés
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    // Vérifie les permissions
    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        return Future.error('Les permissions de localisation sont refusées');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      return Future.error('Les permissions de localisation sont définitivement refusées');
    }

    // Retourne la position actuelle de l'utilisateur
    return await geo.Geolocator.getCurrentPosition();
  }

  /// Fonction appelée lorsque la carte est prête
  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    mapboxMap.location.updateSettings(LocationComponentSettings(enabled: true,pulsingEnabled: true),);
    pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();

    // Charger l'image de l'annotation depuis les assets
    final ByteData bytes = await rootBundle.load('assets/test.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Créer un point avec une icône personnalisée
    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(coordinates: Position(4.8357, 45.7640)), // Coordonnées de Lyon par défaut
      image: imageData,
      iconSize: 0.1,
    );

    // Ajouter l'annotation sur la carte
    pointAnnotationManager?.create(pointAnnotationOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Carte")),
      body: FutureBuilder<geo.Position>(
        future: _determinePosition(), // Attente de la position
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            geo.Position position = snapshot.data!;

            // Paramètres de la caméra avec la position de l'utilisateur
            CameraOptions cameraOptions = CameraOptions(
              center: Point(coordinates: Position(position.longitude, position.latitude)),
              zoom: 12,
              bearing: 0,
              pitch: 0,
            );

            return MapWidget(
              cameraOptions: cameraOptions,
              onMapCreated: _onMapCreated,
            );
          } else {
            return Center(child: Text('Aucune donnée de position disponible.'));
          }
        },
      ),
    );
  }
}
