import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  geo.Position? userPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Récupère la position au lancement
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

    // Active la localisation sur la carte
    mapboxMap!.location.updateSettings(LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
    ));

    // Crée un gestionnaire d'annotations pour les marqueurs
    pointAnnotationManager = await mapboxMap!.annotations.createPointAnnotationManager();

    // Charge l'image du marqueur depuis les assets
    final ByteData bytes = await rootBundle.load('assets/test.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Ajoute un marqueur à la position de l'utilisateur
    if (userPosition != null) {
      PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(userPosition!.longitude, userPosition!.latitude)),
        image: imageData,
        iconSize: 0.1,
      );

      pointAnnotationManager?.create(pointAnnotationOptions);
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
