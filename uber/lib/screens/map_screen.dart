import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart'; 
import '../models/fighter.dart';// Pour charger l'image

// Assure-toi que tu as la classe Fighter déjà définie comme mentionné

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  geo.Position? userPosition;
  StreamSubscription<geo.Position>? userPositionStream;
  StreamSubscription<List<Fighter>>? fighterStreamSubscription;
  List<Fighter> fighters = [];

  final geo.LocationSettings locationSetting = geo.LocationSettings(
    accuracy: geo.LocationAccuracy.high,
    distanceFilter: 10, // Met à jour la position tous les 10 mètres
  );

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Récupère la position initiale

    // Écoute les changements de position en temps réel
    userPositionStream = geo.Geolocator.getPositionStream(locationSettings: locationSetting).listen((geo.Position? position) {
      if (position != null) {
        debugPrint("Nouvelle position reçue: ${position.latitude}, ${position.longitude}");

        if (!mounted) return; // Empêche le setState si le widget est supprimé

        setState(() {
          userPosition = position;
        });

        if (mapboxMap != null) {
          mapboxMap!.setCamera(CameraOptions(
            center: Point(coordinates: Position(position.longitude, position.latitude)),
            zoom: 14,  // Zoom de la caméra pour mieux suivre l'utilisateur
          ));
        }
      }
    });

    // Écoute les combattants en temps réel depuis Supabase
    fighterStreamSubscription = Fighter.streamFighters().listen((updatedFighters) {
      if (!mounted) return;
      setState(() {
        fighters = updatedFighters;
      });
      _updateAnnotations();  // Met à jour les annotations sur la carte
    });
  }

  @override
  void dispose() {
    userPositionStream?.cancel(); // Annule l'écouteur lors de la suppression du widget
    fighterStreamSubscription?.cancel(); // Annule l'écouteur des combattants
    super.dispose();
  }

  /// Demande les permissions et obtient la position de l'utilisateur
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Les services de localisation sont désactivés.');
      return;
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        debugPrint('Permissions de localisation refusées.');
        return;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      debugPrint('Permissions de localisation définitivement refusées.');
      return;
    }

    // Récupère la position actuelle
    geo.Position position = await geo.Geolocator.getCurrentPosition();

    if (!mounted) return; // Vérifie si le widget est toujours actif avant setState

    setState(() {
      userPosition = position;
    });

    // Met à jour la caméra si la carte est déjà chargée
    if (mapboxMap != null) {
      mapboxMap!.setCamera(CameraOptions(
        center: Point(coordinates: Position(position.longitude, position.latitude)),
        zoom: 14,
      ));
    }
  }

  /// Fonction appelée lorsque la carte est prête
  void _onMapCreated(MapboxMap map) async {
    mapboxMap = map;
    pointAnnotationManager = await map.annotations.createPointAnnotationManager();
    _updateAnnotations();  // Appelle la méthode pour ajouter les annotations des combattants

    // Active la localisation sur la carte
    mapboxMap!.location.updateSettings(LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
    ));
  }

  /// Met à jour les annotations des combattants sur la carte
  Future<void> _updateAnnotations() async {
    if (pointAnnotationManager == null || mapboxMap == null) return;

    // Supprimer toutes les annotations existantes
    await pointAnnotationManager!.deleteAll();

    // Charger l'icône une seule fois
    final ByteData bytes = await rootBundle.load('assets/test.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Ajouter une annotation pour chaque combattant
    for (var fighter in fighters) {
      PointAnnotationOptions annotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(fighter.longitude, fighter.latitude)),
        image: imageData,
        iconSize: 0.125,
        textField: fighter.name,  // Afficher le nom du combattant
        textColor: Colors.black.value,
        textSize: 14.0,
        textOffset: [0, 2],
      );

      await pointAnnotationManager!.create(annotationOptions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Carte")),
      body: userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : MapWidget(
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(userPosition!.longitude, userPosition!.latitude)),
                zoom: 14,
              ),
              onMapCreated: _onMapCreated,
            ),
    );
  }
}
