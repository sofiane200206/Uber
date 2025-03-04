import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:async';

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
        setState(() {
          userPosition = position;
        });
        if (mapboxMap != null) {
        mapboxMap!.setCamera(CameraOptions(
          center: Point(coordinates: Position(position.longitude, position.latitude)),
          zoom: 14,  // Zoom de la caméra pour mieux suivre l'utilisateur
        ));
        } else {
          debugPrint("Position reçue est null");
        }
      }
    });
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
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
